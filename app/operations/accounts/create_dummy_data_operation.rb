module Accounts
  class CreateDummyDataOperation < BaseOperation
    attributes :account

    def call
      result = create_dummy_data
      return Success(account) if result.success?

      Failure(result.failure)
    end

    private

    def create_dummy_data
      yield validate_statuses
      ids_cache = {}

      ActiveRecord::Base.transaction do
        dummy_data.each do |model_name, data_collection|
          model = model_name.classify.constantize
          model.where(account:).delete_all
          data_collection.each_with_index do |model_data, i|
            model_data.transform_values! { |v| ids_cache.include?(v) ? ids_cache[v] : v }
            model_data.transform_values! { |v| v.is_a?(Hash) ? run_method(v) : v }
            setup_account(model, model_data)
            setup_owner(model, model_data)
            setup_merchant(model, model_data)
            record = model.create(**model_data)
            ids_cache["#{model_name}_#{i}"] = record.id
          end
        end
      end
      Success(true)
    end

    def run_method(hash)
      model = hash["model"].classify.constantize
      record = model.send(hash["method"], hash["args"] || {})
      record.send(hash["pluck"])
    end

    def setup_merchant(model, model_data)
      return unless model.column_names.include? 'merchant_id'

      model_data.merge!(merchant_id: account.merchant.id)
    end

    def setup_owner(model, model_data)
      return unless model.column_names.include? 'owner_id'

      model_data.merge!(owner_id: account.users.first.id)
    end

    def setup_account(model, model_data)
      return unless model.column_names.include? 'account_id'

      model_data.merge!(account_id: account.id)
    end

    def dummy_data
      YAML.load(
        Rails.root.join("config/dummy_data.yaml").read
      )["de"]
    end

    def validate_statuses
      # unless account.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved account_id: #{account.id} ")
      # end

      Success(true)
    end
  end
end
