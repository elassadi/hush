class DummyAction < ::ApplicationBaseAction
  self.name = "Dummy"

  self.visible = lambda {
    true
  }

  def handle(**_args)
    succeed "Modal closed!!"
  end
end
