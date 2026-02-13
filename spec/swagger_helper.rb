require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Taskflow API V1",
        version: "v1",
        description: "A Trello-like task management API with boards, lists, tasks, and comments."
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        }
      ],
      components: {
        securitySchemes: {
          access_token: {
            type: :apiKey,
            name: "access-token",
            in: :header,
            description: "Access token from sign in response"
          },
          client: {
            type: :apiKey,
            name: "client",
            in: :header,
            description: "Client token from sign in response"
          },
          uid: {
            type: :apiKey,
            name: "uid",
            in: :header,
            description: "User email used for authentication"
          },
          token_type: {
            type: :apiKey,
            name: "token-type",
            in: :header,
            description: "Should always be 'Bearer'"
          }
        },
        schemas: {
          errors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            },
            required: %w[errors]
          }
        }
      },
      security: [
        { access_token: [], client: [], uid: [], token_type: [] }
      ]
    }
  }

  config.openapi_format = :yaml
end
