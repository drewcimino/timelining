# TimelineBuilder is a service PORO that builds arrays of UserEvent
# objects. This class should need limited modification - namely the addition
# of new UserEvent subclasses to TIMELINE_EVENT_TYPES when we have new
# business events that need to be constructed. The rest of the class
# should handle the addition without any further modification.

# As of the prototype, there are methods for building a timeline in memory
# for a specific user, and timeline writing methods for the entire cohort
# of users passed into the builder. Any other functionality (i.e. destroy
# and rebuild for a single user) required can be built on an as-need basis.
# This class isn't complex, it won't be hard.

class TimelineBuilder
  attr_accessor :users
  attr_accessor :window_start
  attr_accessor :window_end

  TIMELINE_EVENT_TYPES = [
    TrialStartEvent,
    TrialEndEvent,
    SubscriptionStartEvent,
    SubscriptionEndEvent,
    CancellationEvent,
    ReactivationEvent
  ].freeze

  DAWN_OF_TIME = Date.new(2008,4,12).freeze

  def initialize(users: [], window_start: DAWN_OF_TIME.beginning_of_day, window_end: Date.today.end_of_day)
    @users        = users
    @window_start = window_start
    @window_end   = window_end
  end

  def create_user_timelines
    @users.each { |user| build_timeline(user).map(&:save) }
  end

  def destroy_user_timelines
    @users.each { |user| destroy_timeline(user) }
  end

  def build_timeline(user)
    TIMELINE_EVENT_TYPES.map { |event_type| event_type.build_events(user, window_start, window_end) }.flatten.compact
  end

  def destroy_timeline(user)
    UserEvent.where(user: user).destroy_all
  end
end
