class Numeric
  def to_netto(object = nil, tax: nil, round_by: 2)
    tax = AppConfig::GLOBAL_TAX if tax.blank?
    tax = object.tax if object.present?
    (self / (1 + (tax / 100.0).to_f).to_f).round(round_by)
  end

  def to_brutto(object = nil, tax: nil, round_by: 2)
    tax = AppConfig::GLOBAL_TAX if tax.blank?
    tax = object.tax if object.present?
    (self * (1 + (tax / 100.0).to_f).to_f).round(round_by)
  end

  def to_tax(object = nil, tax: nil, round_by: 2)
    tax = AppConfig::GLOBAL_TAX if tax.blank?
    tax = object.tax if object.present?
    (self * (tax / 100.0).to_f.to_f).round(round_by)
  end

  def brutto_to_tax(object = nil, tax: nil, round_by: 2)
    tax = AppConfig::GLOBAL_TAX if tax.blank?
    tax = object.tax if object.present?
    self - to_netto(tax:, round_by:)
  end

  def to_brutto_currency(object = nil)
    to_brutto(object).to_currency
  end

  def to_netto_currency(object = nil)
    to_netto(object).to_currency
  end

  def to_tax_currency(object = nil)
    to_tax(object).to_currency
  end

  def to_currency
    ActionController::Base.helpers.number_to_currency(self)
  end

  def beautify
    Price::Beautifier.perform(self)
  end
end

class String
  def to_boolean
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

class NilClass
  def to_boolean
    false
  end
end

class TrueClass
  def to_boolean
    true
  end

  def to_i
    1
  end
end

class FalseClass
  def to_boolean
    false
  end

  def to_i
    0
  end
end

class Integer
  delegate :to_boolean, to: :to_s
end
