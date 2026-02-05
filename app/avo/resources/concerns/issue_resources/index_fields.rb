module Concerns
  module IssueResources
    module IndexFields
      STATUS_OPTIONS = {
        light: %w[awaiting_device awaiting_approval],
        gray: %w[draft open],
        info: %w[in_progress ready_to_repair repairing],
        success: %w[done completed repairing_successfull repairing_successfull],
        warning: %w[awaiting_parts],
        danger: %w[canceld repairing_unsuccessfull]
      }.freeze

      extend ::Concerns::BaseFields

      def self.included(base)
        do_index_fields(base)
      end

      def self.do_index_fields(base)
        # if we want to show the locked record in the index page
        # index_field(:title, as: :uuid, base:)
        index_field(:sequence_id, as: :uuid, base:)
        index_field(:status, as: :status_badge, options: STATUS_OPTIONS, shorten: false, base:)
        index_field(:customer, as: :belongs_to, base:)
        index_field(:device, as: :belongs_to, base:)
        index_field :created_at, as: :date_time, base:
      end

      class << self
      end
    end
  end
end
