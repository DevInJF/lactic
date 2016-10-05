require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  # every(12.hours, 'Run a job', tz: 'UTC') { ExampleWorker.perform_async }
  every(1.week, 'weekly_unmatch_lactic', :at => 'Tuesday 10:30', :tz => 'UTC'){ UsersController.global_weekly_unmatch_lactic }

  error_handler do |error|

    puts "ERROR FROM CLOCKWORK #{error.message}"
    Airbrake.notify_or_ignore(error)
  end

end