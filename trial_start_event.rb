class TrialStartEvent < UserEvent
  ACTION_NAME = 'trial-start'.freeze

  def self.build_events(user, window_start, window_end)
    return [] unless sub = user.subscription

    trial_start_events = sub.attribute_timeline('state').select do |event|
      event.first >= event.first && event.first <= window_end && event.last == 'trial'
    end

    trial_start_events.map do |trial_start|
      new(user: user, seed_record: sub, occurred_at: trial_start.first)
    end
  end
end
