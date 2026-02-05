# frozen_string_literal: true

class KvaDocument < Document
  validates :file, attached: true, content_type: ['application/pdf']
  DOCUMENT_PREFIX = 'KVA'
end
