class ColorPickerField < Avo::Fields::BaseField
  def initialize(id, **args, &)
    super(id, **args, &)

    @allow_non_colors = args[:allow_non_colors]
  end
end
