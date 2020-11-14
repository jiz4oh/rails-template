Raven.configure do |config|
  return if Rails.env.development? || Rails.env.test?
  config.dsn = ENV['SENTRY_SECRET']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.timeout = 10
  config.open_timeout = 10
end
