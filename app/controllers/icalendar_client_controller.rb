require 'icalendar'
class IcalendarClientController < ApplicationController



  def self.event_to_ical(lactic_session)
    cal = Icalendar::Calendar.new

    event = Icalendar::Event.new
    event.dtstart =  lactic_session.start_date_time
    event.dtend =  lactic_session.end_date_time
    event.summary = lactic_session.title.titleize
    event.description = lactic_session.description
    event.url = "https://warm-citadel-1598.herokuapp.com/lactic_sessions/#{lactic_session.redirect_id}.html"
    event.location = lactic_session.location
    cal.add_event(event)

    cal_string = cal.to_ical
    puts cal_string
    cal.publish
    cal_string = cal.to_ical

    cal.to_ical

  end


  def to_ics
    event = Icalendar::Event.new
    event.start = self.date.strftime("%Y%m%dT%H%M%S")
    event.end = self.end_date.strftime("%Y%m%dT%H%M%S")
    event.summary = self.title
    event.description = self.summary
    event.location = 'Here !'
    event.klass = "PUBLIC"
    event.created = self.created_at
    event.last_modified = self.updated_at
    event.uid = event.url = "#{PUBLIC_URL}events/#{self.id}"
    event.add_comment("AF83 - Shake your digital, we do WowWare")
    event
  end

end
