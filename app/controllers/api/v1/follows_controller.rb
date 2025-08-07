module Api
  module V1
    class FollowsController < ApplicationController
      include CurrentUser

      before_action :check_filtered_followed_user, only: %i[create destroy]

      # POST /api/v1/follow/:followed_id
      def create
        followed_user = filtered_followed_user
        @current_user.following << followed_user unless @current_user.following.exists?(followed_user.id)
        render json: { message: "Followed successfully" }, status: :created
      end

      # DELETE /api/v1/unfollow/:followed_id
      def destroy
        followed_user = filtered_followed_user
        @current_user.following.destroy(followed_user)
        render json: { message: "Unfollowed successfully" }, status: :ok
      end

      # GET /api/v1/followers
      def followers
        followers = @current_user.followers.select(:id, :name, :created_at)
        render json: followers
      end

      # GET /api/v1/following
      def following
        following_users = @current_user.following.select(:id, :name, :created_at)
        render json: following_users
      end

      private

      def filtered_followed_user
        @filtered_followed_user ||= User.find_by(id: params[:followed_id])
      end

      def check_filtered_followed_user
        render json: { error: "User not found" }, status: :not_found and return if filtered_followed_user.nil?
      end
    end
  end
end
