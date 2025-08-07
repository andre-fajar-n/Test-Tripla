module Api
  module V1
    class FeedsController < ApplicationController
      include CurrentUser

      # GET /api/v1/feed
      def index
        one_week_ago = Time.current - 1.week

        sleep_records = SleepRecord
                          .joins(:user)
                          .where(user: { id: @current_user.following.select(:id) })
                          .where("sleep_at >= ?", one_week_ago)
                          .where.not(wake_at: nil)
                          .select("sleep_records.*, EXTRACT(EPOCH FROM (wake_at - sleep_at)) AS duration_seconds")
                          .order("duration_seconds DESC")

        render json: sleep_records.map { |record| sleep_record_json(record) }
      end

      private

      def sleep_record_json(record)
        {
          id: record.id,
          user_id: record.user_id,
          user_name: record.user.name,
          sleep_at: record.sleep_at,
          wake_at: record.wake_at,
          duration_seconds: record.duration_seconds.to_i
        }
      end
    end
  end
end
