# frozen_string_literal: true

class PreviewDocument < Document
  validates :file, attached: true, content_type: ['application/pdf']
  DOCUMENT_PREFIX = 'PRE'
end
