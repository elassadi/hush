class BasePolicy < ::RecloudCore::DryBase
  def resolve(options = nil)
    call(options)
  end

  class << self
    def resolve(options = nil)
      call(options)
    end
  end
end
