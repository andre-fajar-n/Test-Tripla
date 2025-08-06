module Api
  module V1
    class SleepRecordsController < ApplicationController
      include CurrentUser

      before_action :check_filtered_sleep_record, only: %i[update]

      # POST /api/v1/sleep_records
      def create
        _record = @current_user.sleep_records.create!(sleep_record_params)
        render json: @current_user.sleep_records.recent_first, status: :created
      end

      # PATCH /api/v1/sleep_records/:id
      def update
        record = filtered_sleep_record
        record.update!(wake_at: Time.current)
        render json: record
      end

      private

      def sleep_record_params
        params.require(:sleep_record).permit(:sleep_at, :wake_at)
      end

      def filtered_sleep_record
        @filtered_sleep_record ||= @current_user.sleep_records.find_by(id: params[:id])
      end

      def check_filtered_sleep_record
        render json: { error: "Data not found" }, status: :not_found and return if filtered_sleep_record.nil?
      end
    end
  end
end
