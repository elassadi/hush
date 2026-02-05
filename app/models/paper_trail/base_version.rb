# frozen_string_literal: true

module PaperTrail
  class BaseVersion < ::ApplicationRecord
    include PaperTrail::VersionConcern

    self.abstract_class = true

    belongs_to :whodunnit,
               foreign_type: :whodunnit_type, foreign_key: :whodunnit, polymorphic: true

    def flatten_object_changes
      flattened_changes = {}

      object_changes.each do |key, value|
        if array_of_hashes?(value)
          flatten_nested_array(flattened_changes, key, value)
        else
          add_if_different(flattened_changes, key, value)
        end
      end

      flattened_changes
    end

    private

    def array_of_hashes?(value)
      value.is_a?(Array) && value.all?(Hash)
    end

    def flatten_nested_array(flattened_changes, key, nested_array)
      nested_keys = nested_array.map(&:keys).flatten.uniq
      nested_keys.each do |nested_key|
        nested_values = nested_array.map { |entry| entry[nested_key] || "--" }
        add_if_different(flattened_changes, "#{key}_#{nested_key}", nested_values)
      end
    end

    def add_if_different(flattened_changes, key, values)
      flattened_changes[key] = values if values.is_a?(Array) && values.uniq.size > 1
    end
  end
end
