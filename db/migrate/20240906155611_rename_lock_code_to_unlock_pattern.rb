class RenameLockCodeToUnlockPattern < ActiveRecord::Migration[7.0]
  def up

    Device.find_in_batches(batch_size: 100) do |devices|
      devices.each do |device|
        if device.metadata && device.metadata['lock_code'].present?
          device.metadata['unlock_pattern'] = device.metadata.delete('lock_code')
          device.save(validate: false)
        end
      end
    end
  end

  def down
    # Rollback: rename unlock_pattern back to lock_code, again in batches
    Device.find_in_batches(batch_size: 10_000) do |devices|
      devices.each do |device|
        if device.metadata && device.metadata['unlock_pattern'].present?
          device.metadata['lock_code'] = device.metadata.delete('unlock_pattern')
          device.save(validate: false)
        end
      end
    end
  end
end