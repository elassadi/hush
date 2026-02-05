class ChangeColation < ActiveRecord::Migration[7.0]

    def up
      execute <<-SQL
        ALTER TABLE device_model_categories CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      SQL
    end

    def down
    end

end
