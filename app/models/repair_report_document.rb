# frozen_string_literal: true

class RepairReportDocument < Document
  validates :file, attached: true, content_type: ['application/pdf']
  DOCUMENT_PREFIX = 'REPORT'

  def template_attributes
    {
      id:,
      sequence_id:,
      uuid:,
      created_at:
    }
  end
end
