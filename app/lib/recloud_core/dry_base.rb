# frozen_string_literal: true

module RecloudCore
  class DryBase
    include Dry::Monads[:result, :do]

    class << self
      def attributes(*attributes)
        @attributes = *attributes
      end

      def optional_attributes(*attributes)
        @optional_attributes = *attributes
      end

      def call(options = nil)
        new(options).call
      end

      def perform_later(options = nil)
        GenericJob.perform_later(klass: self, params: options)
        Dry::Monads::Success(true)
      end

      def perform_at(_at, options = nil)
        ScheduledJob.perform_at(klass: self, params: options, perform_at:)
        Dry::Monads::Success(true)
      end
    end

    def __initialize(args = {})
      args.symbolize_keys!
      attributes = self.class.instance_variable_get(:@attributes) || []
      optional_attributes = self.class.instance_variable_get(:@optional_attributes) || []

      optional_attributes.each do |attribute|
        instance_variable_set("@#{attribute}", args[attribute])
        self.class.send(:attr_reader, attribute)
      end

      attributes.each do |attribute|
        raise ArgumentError, "missing keyword: #{attribute}" if
          args.keys.exclude?(attribute) && args.keys.exclude?(attribute.to_s)

        instance_variable_set("@#{attribute}", args[attribute])
        self.class.send(:attr_reader, attribute)
      end
    end

    def initialize(args = {}) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      args = {} if args.blank?
      args.symbolize_keys!
      attributes = self.class.instance_variable_get(:@attributes) || []
      optional_attributes = self.class.instance_variable_get(:@optional_attributes) || []

      optional_attributes.each do |attribute|
        instance_variable_set("@#{attribute}", args[attribute])
        self.class.send(:attr_reader, attribute)
      end

      attributes.each do |attribute|
        raise ArgumentError, "missing keyword: #{attribute}" if
          args.keys.exclude?(attribute) && args.keys.exclude?(attribute.to_s)

        instance_variable_set("@#{attribute}", args[attribute])
        self.class.send(:attr_reader, attribute)
      end

      # write a loog to detect if args has any keys that are not in attributes
      # or in optional_attributes

      args.each do |key, _value|
        # skip private keys we inject __current_user_id while calling scheduled jobs
        next if key.to_s.start_with?("__")
        next if attributes.include?(key) || optional_attributes.include?(key)

        # raise ArgumentError, "unknown keyword: #{key}"
      end
    end

    def perform = call
  end
end
