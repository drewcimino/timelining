class SubscriptionStateChangeEvent < UserEvent
  def populate_action
    self.action = "#{seed_record.field_changes[:state].first}-#{self.class::ACTION_NAME}"
  end

  def self.build_events(user, window_start, window_end)
    return [] unless sub = user.subscription

    log_items = sub.log_items.where(created_at: window_start..window_end).select do |li|
      li.field_changes[:state] && li.field_changes[:state].last == self::LOG_ITEM_FINAL_STATE
    end

    log_items.map { |li| new(user: user, seed_record: li) }
  end
end
