module Api
  module V1
    class SleepRecordsController < ApplicationController
      include CurrentUser

      # POST /api/v1/sleep_records
      def create
        _record = @current_user.sleep_records.create!(sleep_record_params)
        render json: @current_user.sleep_records.recent_first, status: :created
      end

      private

      def sleep_record_params
        params.require(:sleep_record).permit(:sleep_at, :wake_at)
      end
    end
  end
end
