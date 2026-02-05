# frozen_string_literal: true

class BaseService < ::RecloudCore::DryBase
  class << self
    def call_later(options = nil)
      call(options)
    end
  end
end
