class UuidField < Avo::Fields::BaseField
  attr_reader :shorten, :link_to_resource

  def initialize(name, **args, &)
    @shorten = args[:shorten].nil? ? false : args[:shorten]
    @link_to_resource = args[:link_to_resource].nil? ? true : args[:link_to_resource]
    super(name, **args, &)
    hide_on %i[forms]
  end
end
