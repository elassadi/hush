# frozen_string_literal: true

module Devices
  class CleanJob < ApplicationJob
    def perform
      dangling_devices.find_in_batches(batch_size: 1000) do |batch|
        Device.where(id: batch.map(&:id)).delete_all
      end
    end

    def dangling_devices
      ::Device.where('devices.created_at <= ?', 1.hour.ago)
              .where.missing(:issues)
    end
  end
end
