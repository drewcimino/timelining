## Building flat tables for your analysts

This code is for translating information stored in your Rails application's logging tables into flat tables of conceptual business events for the data science and BI people. Papertrail et al. are great for reliable field-change tracking across your application, but people using that information outside the context of full ActiveRecord-based Ruby objects find it horrifying.

### The TimelineBuilder and basic concept

The TimelineBuilder class accepts a list of base records, currently coded out as users, and constructs a list of records that are are subclasses of UserEvent. Those event records can be written to a user_events inheritance table for consumption outside of the application.

### Defining the event superclass

Every table of events being written to should have a single corresponding abstract event superclass, which inherits from ActiveRecord::Base. It also names the database table that events of this type will be written to, along with maintaining any regular superclass responsiblities, such as table-wide validations. An example of this here is `seed_record`; all UserEvents record a polymorphic association to a record in the application that a given event record can be tied to for transparency and debugging. The business events you want to see in this particular table should all inherit from this class.

### Defining subclasses

Each event subclass should override the `.build_events` superclass method, which accepts a single record and the timeframe in which to search for occasions of that event. `.build_events` is where you define the business logic of what this event means, and have the freedom to use the whole of your application logic to define it. The method should return an array of new, but not saved, instances of the class. The TimelineBuilder can then perform broad-based validations and decide whether or not to write the events to the table.

For example: A SubscriptionStartEvent is defined by the timestamp of the first _payment_ made for a subscription. It could have been defined as when a customer first creates an account, consumes their first product, or anything else. But that's your decision to make here.

### Revising business logic

If (read: "when") you are humming along in your modeling and realize that you have a flawed definition of one of your events, fear not. You just open up that particular event class, change the logic living in `.build_events`, and re-run the builder with the same timeframe. You can clear the old events if they're not useful anymore, or very easily create a V2UserEvent abstract class, build another table, and run both timelines in parallel.

#### TODO

- Refactor TimelineBuilder to be base-record agnostic.
- Provide a directory structure to this library that reinforces the idea of versioned abstract table classes and event subclasses.
