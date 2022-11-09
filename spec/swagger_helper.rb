require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.to_s + '/swagger'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      consumes: ['application/json'],
      produces: ['application/json'],
      securityDefinitions: {
        accessToken: {
          type: :apiKey,
          name: 'access-token',
          in: :header
        },
        tokenType: {
          type: :apiKey,
          name: 'token-type',
          in: :header
        },
        client: {
          type: :apiKey,
          name: 'client',
          in: :header
        },
        expiry: {
          type: :apiKey,
          name: 'expiry',
          in: :header
        },
        uid: {
          type: :apiKey,
          name: 'uid',
          in: :header
        },
        masterKey: {
          type: :apiKey,
          name: 'master-key',
          in: :header
        },
      },
      security: [
        { accessToken: [], tokenType: [], client: [], expiry: [], uid: [], masterKey: [] }
      ]
    }
  }

  config.after do |example|
    if example.metadata[:response].present? && response.body.present?
      example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
    end
  end

  config.include_context 'token auth'
end
