class StatusBadgeField < Avo::Fields::BaseField
  attr_reader :options, :field_id, :shorten, :i18n_scope, :i18n_field_id, :show_on_edit

  DEFAULT_OPTIONS = { info: :info, success: :success, danger: :danger, warning: :warning }.freeze

  def initialize(id, **args, &)
    super(id, **args, &)
    @field_id = id
    @shorten = args[:shorten].nil? ? true : args[:shorten]
    @i18n_scope = args[:i18n_scope]
    @i18n_field_id = args[:i18n_field_id]
    @show_on_edit = args[:show_on_edit].nil? ? false : args[:show_on_edit]

    hide_on %i[edit new] unless @show_on_edit

    @options_proc = args[:options] if args[:options].respond_to?(:call)

    if args[:link_to].respond_to?(:call)
      @link_to_proc = args[:link_to]
    else
      @link_to = args[:link_to]
    end
    options = (args[:options] if args[:options].present? && !@options_proc)

    @options = DEFAULT_OPTIONS.merge(options || {})
    # @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
  end

  def i18n_value
    ((view != :show) && short_translation(value)) ||
      long_translation(value) ||
      fallback_translation(value) ||
      value
  end

  def i18n_value_tooltip
    long_translation(value)
  end

  def link_to
    return @link_to if @link_to.present?

    return @link_to_proc.call(resource:, model:) if @link_to_proc.present?
  end

  def dynamic_options
    return @options if @options_proc.blank?

    DEFAULT_OPTIONS.merge(@options_proc.call(resource:, model:) || {})
  end

  private

  def short_translation(enum_value)
    return if @shorten.blank?

    scope = i18n_scope || "activerecord.attributes.#{model.class.model_name.i18n_key}"
    short_translation_key = "#{scope}.#{(i18n_field_id || field_id).to_s.pluralize}.short.#{enum_value}"

    return I18n.t(short_translation_key) if I18n.exists?(short_translation_key)
  end

  def long_translation(enum_value)
    scope = i18n_scope || "activerecord.attributes.#{model.class.model_name.i18n_key}"
    translation_key =  "#{scope}.#{(i18n_field_id || field_id).to_s.pluralize}.#{enum_value}"

    I18n.t(translation_key) if I18n.exists?(translation_key)
  end

  def fallback_translation(enum_value)
    translation_key = "shared.#{i18n_field_id || field_id}.#{enum_value}"
    return I18n.t(translation_key) if I18n.exists?(translation_key)
  end
end
