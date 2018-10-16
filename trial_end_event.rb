class TrialEndEvent < UserEvent
  ACTION_NAME = 'trial-end'.freeze

  def self.build_events(user, window_start, window_end)
    return [] unless sub = user.subscription

    trial_end_events = sub.log_items.where(created_at: window_start..window_end).select do |li|
      li.field_changes['state'] && li.field_changes['state'].first == 'trial'
    end

    trial_end_events.map { |log_item| new(user: user, seed_record: log_item) }
  end
end
