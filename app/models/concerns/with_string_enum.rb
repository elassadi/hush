# frozen_string_literal: true

module WithStringEnum
  def string_enum(key, values, **args)
    enum key => values.index_by(&:itself), **args.merge(_prefix: args[:_prefix] || key)
  end
end
