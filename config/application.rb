require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# require "postgresql_lo_streamer"
module OsmParse
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("vendor","assets", "fonts")
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.precompile += %w( .svg .eot .woff .ttf )
    # config.assets.paths << "#{Rails}/vendor/assets/fonts"
    # Do not swallow errors in after_commit/after_rollback callbacks.

    config.active_record.raise_in_transactional_callbacks = true
    Koala.config.api_version = 'v2.0'
    config.action_mailer.default_url_options = { :host => ENV['APP_DOMAIN'] }
    config.assets.precompile += %w(fitness/main.js)
    config.assets.initialize_on_precompile = false
    # config.assets.precompile += ["Flaticon.woff",
    #                              "Flaticon.ttf",
    #                              "Flaticon.svg",
    #                              "Flaticon.eot"]
    # #
    Rails.application.config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    # initializer 'font-awesome-sass.assets.precompile', group: :all do |app|
    #   %w(stylesheets fonts).each do |sub|
    #     app.config.assets.paths << root.join('assets', sub).to_s
    #   end
    #
    #   %w(eot svg ttf woff woff2).each do |ext|
    #     app.config.assets.precompile << "font-awesome/fontawesome-webfont.#{ext}"
    #   end
    # end

  end
end