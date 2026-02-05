module StringEnumHelper
  extend ActiveSupport::Concern

  def defines_string_enum(name:, values:, prefix: nil)
    values_hash = values.zip(values).to_h

    expectation = define_enum_for(name).with_values(values_hash).backed_by_column_of_type(:string)
    expectation = expectation.with_prefix(prefix) if prefix.present?

    expect(subject).to expectation
  end

  def defines_string_enum_with_prefix(name:, values:)
    defines_string_enum(name:, values:, prefix: name)
  end
end
