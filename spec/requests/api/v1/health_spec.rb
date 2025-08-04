require 'swagger_helper'

RSpec.describe 'Health API', type: :request do
  path '/api/v1/health' do
    get 'Health check endpoint' do
      tags 'Health'
      produces 'application/json'
      
      response '200', 'successful' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 timestamp: { type: :string },
                 version: { type: :string },
                 database: { type: :string }
               }
        
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('ok')
          expect(data['database']).to be_in(['connected', 'disconnected'])
        end
      end
    end
  end
end