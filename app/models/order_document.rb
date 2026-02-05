# frozen_string_literal: true

class OrderDocument < Document
  validates :file, attached: true, content_type: ['application/pdf']
  DOCUMENT_PREFIX = 'AUF'
end
