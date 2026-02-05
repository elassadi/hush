# frozen_string_literal: true

class CsvDocument < Document
  validates :file, attached: true, content_type: ['text/csv']
end
