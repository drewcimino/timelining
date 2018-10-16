class SubscriptionEndEvent < UserEvent
  ACTION_NAME = 'subscription-end'.freeze

  def populate_occurred_at
    # occurred_at must be passed in to SubscriptionEndEvent#new
  end

  def self.build_events(user, window_start, window_end)
    return [] unless sub = user.subscription

    pauses = sub.attribute_timeline('state').select do |change|
      change.first >= window_start && change.first <= window_end && change.last == 'paused'
    end

    sub_ends = pauses.each_with_object([]).with_index do |(pause, ends), i|
      possible_sub_end = sub.attribute_at_time('next_renewal_at', pause.first)
      ends << pause.first if pauses[i+1] && (possible_sub_end < pauses[i+1].first)
    end

    sub_ends.map { |sub_end| new(user: user, occurred_at: sub_end) }
  end
end
