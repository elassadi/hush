# frozen_string_literal: true

module Avo
  module Fields
    module PriceField
      class EditComponent < Avo::Fields::EditComponent
        def subfield_stimulus_attributes(subfield)
          attributes = {}

          if @resource.present? && @field.show_tax?
            @resource.get_stimulus_controllers.split.each do |controller|
              attributes["#{controller}-target"] =
                "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_#{subfield}".camelize(:lower)
              attributes["price-field-target"] = "price_field_#{subfield}".camelize(:lower)
              attributes["price-field-id"] = @field.id.to_s.underscore.to_s.camelize(:lower)
              # attributes["action"] = "article-resource#onTaxSelectChange"
            end
          end
          attributes.map { |k, v| "data-#{k}=\"#{v}\"" }.join(' ')
        end

        def with_extra_data(data)
          data[:action] = "focus->price-field#onFocus price-field#onPriceInputChanged #{data[:action]} "
          data.merge!(
            {
              'price-field-id': @field.id.to_s.underscore.camelize(:lower),
              'tax-value': @field.tax,
              'input-mode': @field.input_mode,
              'price-field-target': "priceFieldInput"
            }
          )
          data
        end
        def hidden_field_data
          attributes = {
            'price-field-id': @field.id.to_s.underscore.camelize(:lower),
            'tax-value': @field.tax,
            'input-mode': @field.input_mode,
            'price-field-target': "hiddenPriceFieldInput"
          }
          if @resource.present?
            @resource.get_stimulus_controllers.split.each do |controller|
              attributes["#{controller}-target"] =
                "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_hidden".camelize(:lower)
            end
          end
          attributes
        end

      end
    end
  end
end
