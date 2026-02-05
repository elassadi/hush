module Authorization
  class Client
    attr_reader :user, :action, :record, :args

    ACTION_PREFIXES = %w(view show attach detach create edit destroy).freeze

    def initialize(user, action, record, **args)
      @user = user
      @action = action
      @record = record
      @args = args
    end

    def can?
      if user.ability.permissions[:cannot][args[:parent_action]].present?
        return user.can?(args[:parent_action], args[:parent_model])
      end

      record_class = record.is_a?(Class) ? record : record.class
      if calculated_action == :new
        user.can?(calculated_action, record_class)
      else
        user.can?(calculated_action, record)
      end

      # debug(result:, filter: { action: %i[attach detach reorder] })
      # debug(result:, filter: { action: %i[attach detach reorder] })
    end

    private

    def calculated_action
      return args[:parent_action].to_sym if args[:parent_model] == record

      action.to_sym
    end

    def debug(filter: {}, result: nil)
      class_name = record.is_a?(Class) ? record.to_s.downcase : record.class.name.downcase

      filter_by_action = filter && Array(filter[:action]).include?(action.to_sym)
      filter_by_class = filter && Array(filter[:class_name]).include?(class_name.to_sym)

      return if filter_by_action || filter_by_class

      CoreLogger.info("[#{class_name}] \taction: '#{action.to_sym}' " \
                      "\tcalculated_action: #{calculated_action} " \
                      "\tparent_action: #{args[:parent_action]} \tResult:[#{result}]")
    end

    class << self
      def can?(user, action, record, **args)
        new(user, action, record, **args).can?
      end
    end
  end
end
