require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_dry_run = true
  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}:3000',
          variables: {
            defaultHost: {
              default: 'localhost'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            description: "Authorization bearer token",
            type: :apiKey,
            name: 'Authorization',
            in: :header
          }
        },
        schemas: {
          AddressResponse: {
            type: :object,
            properties: {
              status: { type: :string },
              uuid: { type: :string },
              street: { type: :string },
              house_number: { type: :string },
              post_code: { type: :string },
              city: { type: :string },
              country: { type: :string }
            }, required: %w[uuid status street house_number post_code city country]
          },
          AddressRequest: {
            type: :object,
            properties: {
              street: { type: :string },
              house_number: { type: :string },
              post_code: { type: :string },
              city: { type: :string }
            }, required: %w[street house_number post_code city]
          },
          CreateClientRequest: {
            type: :object,
            properties: {
              birthdate: { type: :string },
              email: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              phone: { type: :string },
              remote_client_id: { type: :string },
              addresses: {
                type: :array,
                items: {
                  '$ref': '#/components/schemas/AddressRequest'
                }
              }
            }, required: %w[birthdate email first_name last_name phone addresses]
          },
          ClientResponse: {
            type: :object,
            properties: {
              uuid: { type: :string },
              status: { type: :string },
              birthdate: { type: :string },
              email: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              phone: { type: :string },
              remote_client_id: { type: %i[string null] },
              updated_at: { type: :integer },
              addresses: {
                type: :array,
                items: {
                  '$ref': '#/components/schemas/AddressResponse'
                }
              }
            }, required: %w[uuid status birthdate email first_name last_name phone remote_client_id updated_at addresses]
          },
          ClientsListResponse: {
            type: :object,
            properties: {
              Clients: {
                type: :array,
                items: {
                  '$ref': '#/components/schemas/ClientResponse'
                }
              },
              clients_total_count: {
                type: :integer
              },
              limit: { type: :integer },
              offset: { type: :integer }
            }, required: %w[clients_total_count limit offset]
          },
          ErrorResponse: {
            type: :object,
            properties: {
              message: {
                type: :object
              }
            }
          },
          AuthorizationFailedResponse: {
            type: :object,
            properties: {
              message: { type: :string }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
