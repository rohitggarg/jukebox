Airbrake.configure do |config|
  config.host = ENV['AIRBRAKE_URL']
  config.project_id = 1
  config.project_key = ENV['AIRBRAKE_KEY']

  # Uncomment for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end