module Accounts
  class PurgeOperation < BaseOperation
    attributes :account

    def call
      result = purge_account
      account = result.success
      if result.success?
        # Event.broadcast(:account_activated, account_id: account.id) if account.status_active?
        return Success(account)
      end

      Failure(result.failure)
    end

    private

    def purge_account
      yield validate_statuses

      yield purge_account_data

      Success(account)
    end

    def purge_account_data
      ActiveRecord::Base.connection.tables.each do |table|
        next unless ActiveRecord::Base.connection.column_exists?(table, :account_id)

        ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE account_id = #{account.id}")
      end
      account.delete
      Success(true)
    end

    def validate_statuses
      unless account.status_deleted?
        return Failure("#{self.class} invalid_status Must be deleted account_id: #{account.id} ")
      end

      Success(true)
    end
  end
end
