require 'swagger_helper'

RSpec.describe 'Feeds API', type: :request do
  let!(:user) { User.create!(name: "Alice") }
  let!(:friend1) { User.create!(name: "Bob") }
  let!(:friend2) { User.create!(name: "Charlie") }
  let!(:friend3) { User.create!(name: "Evan") }  # followed but don't have record this week
  let!(:friend4) { User.create!(name: "Fiona") } # followed and have record but not set wake_at
  let!(:other_user) { User.create!(name: "Diana") }

  before do
    # Alice follow Bob, Charlie, Evan, Fiona
    user.following << friend1
    user.following << friend2
    user.following << friend3
    user.following << friend4

    # Bob has sleep record this week
    friend1.sleep_records.create!(
      sleep_at: 2.days.ago,
      wake_at: 2.days.ago + 8.hours
    )

    # Charlie has sleep record this week
    friend2.sleep_records.create!(
      sleep_at: 1.day.ago,
      wake_at: 1.day.ago + 6.hours
    )

    # Diana has sleep record, but Alice doesn't follow
    other_user.sleep_records.create!(
      sleep_at: 1.day.ago,
      wake_at: 1.day.ago + 7.hours
    )

    # Bob has sleep record but more than a week ago
    friend1.sleep_records.create!(
      sleep_at: 10.days.ago,
      wake_at: 10.days.ago + 5.hours
    )

    # Fiona followed and has sleep record this week, but no wake_at
    friend4.sleep_records.create!(
      sleep_at: 3.days.ago,
      wake_at: nil
    )
  end

  path '/api/v1/feeds' do
    get 'Get sleep records from followed users (last week, sorted by duration)' do
      tags 'Feeds'
      produces 'application/json'
      parameter name: :'X-User-ID', in: :header, type: :string, required: true, description: 'Current user ID'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'feed returned successfully' do
        schema type: :object,
             properties: {
               data: {
                 type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     user_id: { type: :integer },
                     user_name: { type: :string },
                     sleep_at: { type: :string },
                     wake_at: { type: :string, nullable: true },
                     duration_seconds: { type: :integer }
                   }
                 }
               },
               metadata: {
                 type: :object,
                 properties: {
                   current_page: { type: :integer },
                   total_pages: { type: :integer },
                   total_count: { type: :integer }
                 }
               }
             }

        let(:'X-User-ID') { user.id.to_s }

        run_test! do |response|
          response_body = JSON.parse(response.body)
          data = response_body['data']
          names = data.map { |r| r['user_name'] }

          # ✅ Only Bob and Charlie should appear
          expect(names).to match_array([ 'Bob', 'Charlie' ])

          # ✅ Sorting by duration_seconds descending (Bob > Charlie)
          durations = data.map { |r| r['duration_seconds'] }
          expect(durations).to eq(durations.sort.reverse)

          # ✅ Evan (no records) and Fiona (no wake_at) should not appear
          expect(names).not_to include('Evan', 'Fiona')

          # ✅ make sure all records have wake_at (not nil)
          expect(data.all? { |r| !r['wake_at'].nil? }).to be true

          metadata = response_body['metadata']
          expect(metadata['current_page']).to eq(1)
          expect(metadata['total_pages']).to eq(1)
          expect(metadata['total_count']).to eq(2)
        end
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        run_test!
      end
    end
  end
end
