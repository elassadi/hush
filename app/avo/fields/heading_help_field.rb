class HeadingHelpField < Avo::Fields::BaseField
  attr_reader :href, :target

  def initialize(name, **args, &)
    super(name, **args, &)

    @href = args[:href] || docs_href(args[:path])
    @target = args[:target] || "_blank"
    @i18n_key = args[:i18n_key]
    @title = args[:title]

    hide_on args[:hide_on] || :index
  end

  def i18n_name
    return name unless @i18n_key

    I18n.t(:name, scope: translation_key.gsub(".#{id}", ".#{@i18n_key}"))
  end

  def i18n_title
    return @title unless @i18n_key

    I18n.t(:title, scope: translation_key.gsub(".#{id}", ".#{@i18n_key}"))
  end

  private

  def docs_href(path)
    return unless path

    host = ENV.fetch("REDOCS_URL", "")
    locale = I18n.locale == :de ? nil : "/#{I18n.locale}"

    [host, locale, path].compact.join
  end
end
