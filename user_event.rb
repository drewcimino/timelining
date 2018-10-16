# UserEvent is an abstract parent class which all timeline events will inherit from. Objects of this class should
# never be instantiated, and it's build_events method that TimelineBuilder calls raises an exception to that effect.

# Each subclass contains both knowledge about what its own attributes should be, as well the the logic required
# to detect the occurance of itself in a customer's history, defined in an overriding #build_events class method.

# Common behavior between subclasses is factored out into this class. Any subclass with varying behavior can
# override the method defined here to achieve it's desired state (see SubscriptionStateChangeEvent#populate_action,
# SubscriptionEndEvent#populate_occurred_at). As we build additional event types, keep an eye out for repetition
# that could potentially be brought up into UserEvent. Keeping subclasses concise allows for easier construction
# of new events in the future.

class UserEvent < ActiveRecord::Base
  self.inheritance_column = :event_type

  belongs_to :user
  belongs_to :subscription
  belongs_to :subscription_plan
  belongs_to :seed_record, polymorphic: true

  validates :action, :user, :user_code, :seed_record, :subscription, :subscription_plan, :occurred_at, presence: true

  after_initialize :populate_fields, if: :new_record?

  def populate_fields
    populate_action
    populate_occurred_at
    populate_user_information
  end

  def populate_action
    self.action = self.class::ACTION_NAME
  end

  def populate_occurred_at
    self.occurred_at = seed_record.created_at
  end

  def populate_user_information
    self.user_code            = user.user_code
    self.subscription         = user.subscription
    self.subscription_plan_id = user.subscription && user.subscription.plan_at_time(self.occurred_at)
  end

  def self.build_events(user, window_start, window_end)
    raise 'UserEvent#build_events not implemented. You probably forgot to define it for your subclass.'
  end
end
