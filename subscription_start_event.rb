class SubscriptionStartEvent < UserEvent
  ACTION_NAME = 'subscription-start'.freeze

  def self.build_events(user, window_start, window_end)
    return [] unless sub = user.subscription

    first_sub_payment = sub.subscription_payments.first

    if first_sub_payment && first_sub_payment.created_at >= window_start && first_sub_payment.created_at <= window_end
      [new(user: user, seed_record: first_sub_payment)]
    else
      []
    end
  end
end
