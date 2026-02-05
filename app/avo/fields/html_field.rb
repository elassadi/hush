class HtmlField < Avo::Fields::BaseField
  def initialize(name, **args, &)
    super(name, **args, &)
    @computed = false
  end

  def parsed_value
    return value if resource&.model.blank?

    value.gsub('{{resource_model_id}}', resource.model.id.to_s)
  end
end
