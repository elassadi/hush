class Privilege
  attr_reader :user, :permissions, :aliased_actions

  class AccessDenied < StandardError
    attr_reader :message, :action

    def initialize(message, action)
      @message = message
      @action = action
    end
  end

  READ_ONLY_RESOURCE_CLASSES = [
    PaperTrail::Version, WebhookRequest, WebhookRequestJob, EventJob
  ].freeze

  def initialize(user)
    @user = user
    @aliased_actions = {}

    alias_action :view, :index, :show, to: :read
    # used in devices controller to api list colors
    # we tie them to read access
    alias_action :default_stock, :areas, :list_colors, :fetch_by_imei, :preview,
                 to: :read

    alias_action :new, to: :create
    alias_action :edit, to: :update

    @permissions = Rails.cache.fetch(cache_key_for_user_abilities_records, expires_in: 5.minutes) do
      @permissions = {}
      setup_user_abilities
      setup_basic_abilities
      setup_readonly_models
      setup_readonly_but_destroyable_models
      setup_basic_permissions
      setup_basic_restrictions
      @permissions
    end
  end

  def can(actions, klass, args: nil, proc_klass: nil)
    define_permission(:can, actions, klass, args:, proc_klass:)
  end

  def cannot(actions, klass, args: nil, proc_klass: nil)
    define_permission(:cannot, actions, klass, args:, proc_klass:)
  end

  def may?(action, model)
    model.can_be?(action) && can?(action.to_sym, model)
  end

  def authorize!(action, record)
    result = can?(action, record)
    return true if result

    raise AccessDenied.new("Action #{action} denied", action)
  end

  def can?(action, record)
    return true if can_manage_all?

    can_manage = can_permission_exists?(:manage, record)
    can = can_permission_exists?(action, record)
    cannot_missing = cannot_permission_missing?(action, record)

    final_result = (can_manage || can) && cannot_missing

    CoreLogger.info("can? action: #{action}, " \
                    "record: #{record}, can: #{can}, cannot_missing: #{cannot_missing} final_result: #{final_result}")

    final_result
  end

  def cannot?(...)
    !can?(...)
  end

  def permission_granted?(action, klass)
    permissions.dig(:can, action, klass.to_s).present?
  end

  def permission_denied?(action, klass)
    permissions.dig(:cannot, action, klass.to_s).present?
  end

  def any_permission_granted?(actions, klass)
    actions.any? { |action| permission_granted?(action, klass) }
  end

  def all_permissions_granted?(actions, klass)
    actions.all? { |action| permission_granted?(action, klass) }
  end

  private

  def find_aliased_action(action)
    entry = aliased_actions.find do |_k, v|
      v.include?(action)
    end
    entry ? entry.first : action
  end

  def find_can_permission(action, klass)
    action = find_aliased_action(action)
    permissions.dig(:can, action.to_sym, "all") || permissions.dig(:can, action.to_sym, klass.to_s)
  end

  def find_cannot_permission(action, klass)
    action = find_aliased_action(action)
    permissions.dig(:cannot, action.to_sym, klass.to_s)
  end

  def can_manage_all?
    find_can_permission(:manage, :all)
  end

  def can_permission_exists?(action, record)
    klass = record.is_a?(Class) ? record : record.class
    permission = find_can_permission(action, klass)

    return false if permission.blank?
    return true if record.is_a?(Class)
    return true if permission == true

    if permission[:proc_klass].present?
      result = permission[:proc_klass].constantize.call(
        user:, record:, args: permission[:args], action:, effect: :can
      )
      return false unless result
    end

    true
  end

  def cannot_permission_missing?(action, record) # rubocop:todo Metrics/CyclomaticComplexity
    klass = record.is_a?(Class) ? record : record.class

    permission = find_cannot_permission(action, klass)

    return true if permission.blank? || record.is_a?(Class)
    return false if permission == true

    if permission[:proc_klass].present?
      cannot_result = begin
        permission[:proc_klass].constantize.call(
          user:, record:, args: permission[:args], action:, effect: :cannot
        )
      rescue StandardError => e
        CoreLogger.info("Error in cannot permission: #{e}")
      end
      return true unless cannot_result
    end

    false
  end

  def define_permission(permission_type, actions, klass, args: nil, proc_klass: nil)
    Array(actions).each do |action|
      action = find_aliased_action(action)
      @permissions[permission_type] ||= {}
      @permissions[permission_type][action.to_sym] ||= {}
      @permissions[permission_type][action.to_sym][klass.to_s] = proc_klass.present? ? { args:, proc_klass: } : true
    end
  end

  def cache_key_for_user_abilities_records
    [
      "abilities",
      "account",
      user.account_id,
      "user",
      user.id,
      "abilities",
      user.role.cache_key_with_version
    ].join("::")
  end

  def setup_readonly_models
    READ_ONLY_RESOURCE_CLASSES.each do |resource|
      cannot %i[update create destroy attach detach], resource
    end
  end

  def setup_readonly_but_destroyable_models
    [WebhookRequest, WebhookRequestJob].each do |resource|
      cannot %i[update create attach detach], resource
    end
  end

  def setup_basic_abilities
    can :edit, User, proc_klass: "ResourcesAbilities::UserAbility"
    cannot :destroy, User, proc_klass: "ResourcesAbilities::UserAbility"
    can :act_on, :all
    can :keep_alive, User
  end

  def setup_basic_restrictions
    BaseAccess.new(user, self).apply_restrictions
  end

  def setup_basic_permissions
    BaseAccess.new(user, self).apply_permissions
  end

  def setup_super_admin_abilities
    can :manage, :all
  end

  def setup_user_abilities
    return setup_super_admin_abilities if user.super_admin?

    # abilities = Rails.cache.fetch(cache_key_for_user_abilities_records, expires_in: 1.hour) do
    #   user.role.abilities.to_a
    # end
    user.role.abilities.each do |ability|
      setup_abilities(ability)
    end
  end

  def setup_abilities(ability)
    setup_ability(ability, allow: ability.effect == "allow")
  end

  def setup_ability(ability, allow: false)
    method = allow ? :can : :cannot

    ability.action_tags.each do |action|
      action = find_aliased_action(action.to_sym)
      klasses = resource_klass(ability)
      klasses.each do |klass|
        if klass.column_names.include?('account_id')
          send method, action, klass, proc_klass: "ResourcesAbilities::AccountAbility", args: { action: }
        else
          send method, action, klass
        end
      end
    end
  end

  def resource_klass(ability)
    # if ability.resource == "*"
    return ApplicationPolicy::AVAILABLE_RESOURCES_EXCEPT_ADMIN.map(&:constantize) if ability.resources.include?("*")

    ability.resources.map(&:constantize)
  end

  def alias_action(*args)
    target = args.pop[:to]
    @aliased_actions[target] ||= []
    @aliased_actions[target] += args
  end
end
