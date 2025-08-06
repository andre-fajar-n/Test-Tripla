require 'swagger_helper'

RSpec.describe 'Sleep Records API', type: :request do
  let!(:user) { User.create!(name: "Alice") }
  let!(:sleep_record1) { user.sleep_records.create!(sleep_at: 2.days.ago, wake_at: 1.day.ago) }
  let!(:sleep_record2) { user.sleep_records.create!(sleep_at: 1.day.ago, wake_at: Time.current) }

  path '/api/v1/sleep_records' do
    post 'Create a new sleep record (Clock In)' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'X-User-ID', in: :header, type: :string, required: true
      parameter name: :sleep_record, in: :body, schema: {
        type: :object,
        properties: {
          sleep_at: { type: :string, format: 'date-time' }
        },
        required: [ 'sleep_at' ]
      }

      response '201', 'sleep record created' do
        let(:'X-User-ID') { user.id.to_s }
        let(:sleep_record) { { sleep_at: (Time.current - 8.hours).iso8601 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["sleep_at"]).to be_present
          expect(data["wake_at"]).to be_nil
        end
      end

      response '400', 'bad request' do
        let(:'X-User-ID') { user.id.to_s }
        let(:sleep_record) { {} }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to eq({ "error"=>"param is missing or the value is empty or invalid: sleep_record" })
        end
      end
    end

    get 'List all sleep records for the current user' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: 'X-User-ID', in: :header, type: :string, required: true, description: 'Current user ID'

      response '200', 'successful' do
        let(:'X-User-ID') { user.id.to_s }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   user_id: { type: :integer },
                   sleep_at: { type: :string },
                   wake_at: { type: :string, nullable: true },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(2)
          expect(data.first["id"]).to eq(sleep_record2.id)
        end
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        run_test!
      end
    end
  end

  path '/api/v1/sleep_records/{id}' do
    patch 'Update a sleep record with wake time (Clock Out)' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'X-User-ID', in: :header, type: :string, required: true
      parameter name: :id, in: :path, required: true, schema: { type: :integer }, style: :simple

      response '200', 'wake_at updated' do
        let(:'X-User-ID') { user.id.to_s }
        let(:id) { sleep_record1.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["wake_at"]).to be_present
        end
      end

      response '404', 'not found' do
        let(:'X-User-ID') { user.id.to_s }
        let(:id) { 99999 }
        run_test!
      end
    end
  end
end
