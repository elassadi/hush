class PriceField < Avo::Fields::NumberField
  attr_reader :min, :max, :tax, :as_percent, :input_mode

  def initialize(name, **args, &)
    super(name, **args, &)

    @min = args[:min].present? ? args[:min].to_f : nil
    @max = args[:max].present? ? args[:max].to_f : nil
    @as_percent = args[:as_percent].present? ? true : false
    @input_mode = (%i[netto brutto].include?(args[:input_mode]) && args[:input_mode]) || :netto
    @show_tax = args[:input_mode].present?
    @tax = tax_value(args[:tax])
  end

  def show_tax?
    @show_tax
  end

  def tax_value(tax_input)
    return AppConfig::GLOBAL_TAX if tax_input.nil?

    return if tax_input.blank?

    tax_input
  end

  def initial_value
    value_by(input_mode)
  end

  def initial_value_toggled
    value_by(input_mode == :netto ? :brutto : :netto)
  end

  def value_by(mode)
    return "0.00" unless value

    taxed_value = value.to_f + (value.to_f * tax / 100)
    return format("%.2f", value.to_f.to_s.to_f.round(2)) if mode == :netto

    format("%.2f", taxed_value.to_s.to_f.round(2))
  end

  def netto_brutto_label
    input_mode == :netto ? "btto" : "ntto"
  end
end
