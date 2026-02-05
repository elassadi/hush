module Issues
  module WorkflowConditions
    class Invoiced < ::RecloudCore::DryBase
      attributes :resource

      def call
        process_condition
      end

      def process_condition
        return Success(true) if
          resource.last_invoiced_at.present? &&
          (resource.last_invoice_canceld_at.blank? ||
            resource.last_invoiced_at > resource.last_invoice_canceld_at)

        Failure("Rechnung ist noch nicht erstellt worden.")
      end
    end
  end
end
