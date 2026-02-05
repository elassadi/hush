class CanCanAbility
  include CanCan::Ability
  attr_reader :user, :record

  READ_ONLY_RESOURCE_CLASSES = [
    PaperTrail::Version, WebhookRequest, WebhookRequestJob, EventJob
  ].freeze

  RESOURCES_ABILITIES_CLASSES = [
    ResourcesAbilities::IssueEntryAbility
  ].freeze

  def initialize(user)
    # =======
    alias_action :view, :index, :show, to: :read
    # used in devices controller to api list colors
    # we tie them to read access
    alias_action :default_stock, :areas, :list_colors, :fetch_by_imei, :preview,
                 to: :read

    alias_action :new, to: :create
    alias_action :edit, to: :update

    @user = user
    @record = record

    setup_user_abilities
    setup_basic_abilities
    setup_readonly_models
    setup_readonly_but_destroyable_models
    setup_basic_permissions
    setup_basic_restrictions

    apply_resource_abilities
  end

  def may?(action, model)
    model.can_be?(action) && can?(action.to_sym, model)
  end

  private

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

  def apply_restrictions
    RESTRICTION_KLASSES.each do |klass|
      klass.call(user:, record:, ability: self, restrict: true)
    end
  end

  def apply_resource_abilities
    RESOURCES_ABILITIES_CLASSES.each do |klass|
      klass.call(user:, record:, ability: self)
    end
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
    can :read, User, id: user.id
    can :update, User, id: user.id
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

    abilities = Rails.cache.fetch(cache_key_for_user_abilities_records, expires_in: 1.hour) do
      user.role.abilities.to_a
    end

    abilities.each do |ability|
      setup_abilities(ability)
    end
  end

  def setup_abilities(ability)
    return allow_ability(ability) if ability.effect == "allow"

    deny_ability(ability)
  end

  def allow_ability(ability)
    setup_ability(ability, allow: true)
  end

  def deny_ability(ability)
    setup_ability(ability, allow: false)
  end

  def setup_ability(ability, allow: false)
    method = allow ? :can : :cannot
    # account_args = user.account_id ? { account_id: user.account_id } : {}
    account_args = {}

    ability.action_tags.each do |action|
      klasses = resource_klass(ability)
      klasses.each do |klass|
        args = klass.column_names.include?('account_id') ? account_args : {}
        send method, action.to_sym, klass, **args do |local_record|
          next true unless local_record.respond_to?(:account_id)
          next true unless local_record.persisted?

          next true if user.access_level_global?

          local_record.account_id == user.current_account.id || shared_read_access?(action, local_record)
        end
      end
    end
  end

  def shared_read_access?(action, record)
    action.to_sym == :read && Constants::SHARED_DATA_MODELS.include?(record.class) &&
      record.account_id == recloud_id
  end

  def recloud_id
    @recloud_id ||= Account.recloud.id
  end

  def resource_klass(ability)
    # if ability.resource == "*"
    return ApplicationPolicy::AVAILABLE_RESOURCES_EXCEPT_ADMIN.map(&:constantize) if ability.resources.include?("*")

    # ability.resource.constantize
    ability.resources.map(&:constantize)
  end
end
