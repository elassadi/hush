# frozen_string_literal: true

class PdfDocument < Document
  validates :file, attached: true, content_type: ['application/pdf']
end
