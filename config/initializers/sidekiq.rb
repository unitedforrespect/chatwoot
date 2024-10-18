require Rails.root.join('lib/redis/config')

schedule_file = 'config/schedule.yml'

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
end

Sidekiq.configure_server do |config|
  config.logger.formatter = Sidekiq::Logger::Formatters::JSON.new
  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
  config.cache_store = :redis_cache_store, {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
  # skip the default start stop logging
  config[:skip_default_job_logging] = true
  config.logger.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'info').upcase.to_s)
end

# https://github.com/ondrejbartas/sidekiq-cron
Rails.application.reloader.to_prepare do
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
end
