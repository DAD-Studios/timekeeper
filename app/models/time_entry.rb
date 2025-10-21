class TimeEntry < ApplicationRecord
  SECONDS_PER_HOUR = 3600.0
  STATUS_RUNNING = 'running'
  STATUS_COMPLETED = 'completed'

  belongs_to :project
  belongs_to :client
  has_one :invoice_line_item, dependent: :nullify
  has_one :invoice, through: :invoice_line_item

  has_rich_text :notes

  validates :task, presence: true
  validate :no_other_running_timer, if: :running?

  scope :running, -> { where(status: STATUS_RUNNING) }
  scope :unbilled, -> { where.missing(:invoice_line_item).where(status: STATUS_COMPLETED) }
  scope :completed, -> { where(status: STATUS_COMPLETED) }

  before_save :calculate_totals_if_completed

  def stop!
    update(end_time: Time.current, status: STATUS_COMPLETED)
  end

  def duration_in_hours
    return 0 unless duration_seconds.present?
    duration_seconds / SECONDS_PER_HOUR
  end

  def running?
    status == STATUS_RUNNING
  end

  def paid?
    invoice&.paid?
  end

  def invoiced?
    invoice.present?
  end

  def rounded_start_time
    round_to_5_minutes(start_time)
  end

  def rounded_end_time
    round_to_5_minutes(end_time)
  end

  private

  def no_other_running_timer
    running_timers = TimeEntry.running
    running_timers = running_timers.where.not(id: id) if persisted?
    if running_timers.exists?
      errors.add(:base, 'A timer is already running. Please stop it before starting a new one.')
    end
  end

  def completed?
    status == STATUS_COMPLETED && end_time.present? && start_time.present?
  end

  def calculate_totals_if_completed
    return unless completed?

    assign_rate_from_project
    calculate_duration
    calculate_earnings
  end

  def assign_rate_from_project
    self.rate ||= project&.rate
  end

  def calculate_duration
    rounded_start = round_to_5_minutes(start_time)
    rounded_end = round_to_5_minutes(end_time)
    self.duration_seconds = (rounded_end - rounded_start).to_i
  end

  def round_to_5_minutes(time)
    return time unless time.present?

    # Get the number of seconds since the start of the minute
    seconds = time.sec + (time.min * 60)

    # Round to nearest 5 minutes (300 seconds)
    rounded_seconds = (seconds / 300.0).round * 300

    # Create a new time with rounded minutes/seconds
    time.change(min: 0, sec: 0) + rounded_seconds.seconds
  end

  def calculate_earnings
    self.earnings = rate.present? ? (duration_in_hours * rate).round(2) : 0
  end
end
