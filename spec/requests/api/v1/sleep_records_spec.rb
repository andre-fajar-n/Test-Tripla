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
          expect(data.first["sleep_at"]).to be_present
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
  end
end
