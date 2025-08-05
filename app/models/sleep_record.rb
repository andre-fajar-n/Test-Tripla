class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :sleep_at, presence: true
  validate :wake_after_sleep, if: -> { wake_at.present? }

  scope :recent_first, -> { order(created_at: :desc) }

  private

  def wake_after_sleep
    errors.add(:wake_at, "must be after sleep_at") if wake_at <= sleep_at
  end
end
