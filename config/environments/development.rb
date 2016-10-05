require 'pusher'
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # config.FACEBOOK_FRIENDS = [{}]
  # config.OSM_FRIENDS = [{}]
  # config.OSM_LOCATIONS = [{}]
  # config.ALL_USERS = [{}]
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # config.LACTIC_SESSIONS = Array.new
  # config.LACTIC_SESSIONS_HASH = {}

  # Precompile additional assets
  config.assets.precompile += %w( .svg .eot .woff .ttf )
  # config.middleware.insert_before 0, 'Rack::Cors', logger: (-> { Rails.logger }) do
  #   allow do
  #     origins 'https://warm-citadel-1598.herokuapp.com'
  #
  #     resource '*',
  #              headers: :any,
  #              methods: [:get, :post, :delete, :put, :patch, :options, :head],
  #              max_age: 0
  #   end
  # end
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => 'lacticinc@gmail.com',
      :password             => 'sharon1107',
      :authentication       => 'plain',
      :enable_starttls_auto => true
  }



  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: "lacticinc@gmail.com" }

  # config.action_mailer.delivery_method = :smtp
  Pusher.app_id = '201737'
  Pusher.key = '5806b3cc65c341de1bcb'
  Pusher.secret = '25d424f8ccec9aa5a358'

end
