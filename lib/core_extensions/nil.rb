class NilClass
  def to_netto(_tax = 19.0)
    self
  end

  def to_brutto(_tax = 19.0)
    self
  end

  def to_tax(_tax = 19.0)
    self
  end

  def brutto_to_tax(_tax = 19.0)
    self
  end

  def to_currency
    self
  end

  def to_brutto_currency(_object = nil)
    self
  end

  def to_netto_currency(_object = nil)
    self
  end

  def to_tax_currency(_object = nil)
    self
  end
end
