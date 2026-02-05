module ServiceResponseSchemaHelper
  extend ActiveSupport::Concern

  def response_schema(schema_class:)
    schema_class = schema_class.to_s.camelcase
    schema(type: :object,
           properties: {
             status: { type: :string },
             message: {
               type: :array,
               items: { type: :string }
             },
             data: {
               '$ref': "#/components/schemas/#{schema_class}"
             }
           })
  end
end
