# frozen_string_literal: true

module RecloudCore
  class BaseViewComponent < ViewComponent::Base
    class << self
      def attributes(*attributes)
        @attributes = *attributes
      end

      def optional_attributes(*attributes)
        @optional_attributes = *attributes
      end
    end

    def initialize(args = {})
      attributes = self.class.instance_variable_get(:@attributes) || []
      optional_attributes = self.class.instance_variable_get(:@optional_attributes) || []

      optional_attributes.first.each do |attribute, default_value|
        value = args.key?(attribute) ? args[attribute] : default_value
        instance_variable_set("@#{attribute}", value)
        self.class.send(:attr_reader, attribute)
      end

      attributes.each do |attribute|
        raise ArgumentError, "missing keyword: #{attribute}" if args.keys.exclude?(attribute)

        instance_variable_set("@#{attribute}", args[attribute])
        self.class.send(:attr_reader, attribute)
      end
    end
  end
end
