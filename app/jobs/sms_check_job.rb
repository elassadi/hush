# frozen_string_literal: true

class SmsCheckJob < ApplicationJob
  CHECK_TARGET_SMS_NUMBER = "017681764859"
  MIN_DELAY = 10.minutes
  MAX_DELAY = 20.minutes
  PERMITTED_OPERATION_HOURS = { from: 8, to: 23 }.freeze

  def perform(**_args)
    @stats = read_stats
    Current.user = User.system_user

    # .read SMS ID from Redis
    sms_id = Rails.cache.read("SmsCheck:last_sms_id")

    if sms_id.present?
      # Check if SMS has been received
      sms = SmsQueue.find_by(id: sms_id)
      @stats[:successful_checks] += 1 if sms&.status == "delivered"
    end

    # Increment checks count
    @stats[:checks_done] += 1

    # Send a new SMS
    text = random_120char_text
    result = Sms::Gateway.call(text:, to: CHECK_TARGET_SMS_NUMBER, provider: "recloud")

    new_sms = result.value! if result.success?

    # Save SMS ID and stats in Redis
    Rails.cache.write("SmsCheck:last_sms_id", new_sms&.id)
    Rails.cache.write("SmsCheck:stats", @stats.to_json)

    # Requeue the job
    requeue_job

    # Send stats via email
    AdminMailer.sms_check_job_mail(@stats).deliver_now
  end

  private

  def random_120char_text
    Array.new(120) { ("a".."z").to_a.sample }.join
  end

  def read_stats
    stats = begin
      JSON.parse(Rails.cache.read("SmsCheck:stats") || '{}').symbolize_keys
    rescue StandardError
      { checks_done: 0,
        successful_checks: 0 }
    end
    stats[:checks_done] ||= 0
    stats[:successful_checks] ||= 0
    stats
  end

  def _requeue_job
    self.class.set(wait: rand(MIN_DELAY..MAX_DELAY)).perform_later
  end

  def requeue_job
    now = Time.current

    if now.hour >= PERMITTED_OPERATION_HOURS[:from] && now.hour < PERMITTED_OPERATION_HOURS[:to]
      # Requeue immediately if within the allowed time
      self.class.set(wait: rand(MIN_DELAY..MAX_DELAY)).perform_later
    else
      # Calculate delay until the next allowed window
      next_start_time = if now.hour >= PERMITTED_OPERATION_HOURS[:to]
                          now.tomorrow.beginning_of_day + PERMITTED_OPERATION_HOURS[:from].hours
                        else
                          now.beginning_of_day + PERMITTED_OPERATION_HOURS[:from].hours
                        end
      delay = next_start_time - now
      self.class.set(wait: delay).perform_later
    end
  end
end
