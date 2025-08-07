require 'swagger_helper'

RSpec.describe 'Follows API', type: :request do
  let!(:user) { User.create!(name: "Alice") }
  let!(:target_user) { User.create!(name: "Bob") }
  let!(:follower1) { User.create!(name: "Charlie") }
  let!(:follower2) { User.create!(name: "Diana") }
  let!(:following1) { User.create!(name: "Evan") }
  let!(:following2) { User.create!(name: "Fiona") }

  before do
    follower1.following << user
    follower2.following << user
    user.following << following1
    user.following << following2
  end

  path '/api/v1/follow/{followed_id}' do
    post 'Follow a user' do
      tags 'Follows'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-User-ID', in: :header, type: :string, required: true
      parameter name: :followed_id, in: :path, type: :integer, required: true

      response '201', 'followed successfully' do
        let(:'X-User-ID') { user.id.to_s }
        let(:followed_id) { target_user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Followed successfully')
        end
      end

      response '404', 'user to follow not found' do
        let(:'X-User-ID') { user.id.to_s }
        let(:followed_id) { 999_999 }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        let(:followed_id) { target_user.id }
        run_test!
      end
    end
  end

  path '/api/v1/unfollow/{followed_id}' do
    delete 'Unfollow a user' do
      tags 'Follows'
      produces 'application/json'
      parameter name: :'X-User-ID', in: :header, type: :string, required: true
      parameter name: :followed_id, in: :path, type: :integer, required: true

      response '200', 'unfollowed successfully' do
        let(:'X-User-ID') { user.id.to_s }
        let(:followed_id) { following1.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Unfollowed successfully')
        end
      end

      response '404', 'user to unfollow not found' do
        let(:'X-User-ID') { user.id.to_s }
        let(:followed_id) { 999_999 }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        let(:followed_id) { following1.id }
        run_test!
      end
    end
  end

  path '/api/v1/followers' do
    get 'Get list of followers for current user' do
      tags 'Follows'
      produces 'application/json'
      parameter name: :'X-User-ID', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer
      parameter name: :per_page, in: :query, type: :integer

      response '200', 'followers list returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       created_at: { type: :string }
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
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(2)
          expect(data['data'].map { |u| u['name'] }).to include('Charlie', 'Diana')
          expect(data['metadata']['current_page']).to eq(1)
        end
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        let(:page) { 1 }
        let(:per_page) { 10 }
        run_test!
      end
    end
  end

  path '/api/v1/following' do
    get 'Get list of users current user is following' do
      tags 'Follows'
      produces 'application/json'
      parameter name: :'X-User-ID', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer
      parameter name: :per_page, in: :query, type: :integer

      response '200', 'following list returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       created_at: { type: :string }
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
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(2)
          expect(data['data'].map { |u| u['name'] }).to include('Evan', 'Fiona')
          expect(data['metadata']['total_count']).to eq(2)
        end
      end

      response '401', 'unauthorized' do
        let(:'X-User-ID') { nil }
        let(:page) { 1 }
        let(:per_page) { 10 }
        run_test!
      end
    end
  end
end
