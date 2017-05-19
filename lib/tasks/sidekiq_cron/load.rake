namespace :sidekiq_cron do
  desc "Load Sidekiq Cron entries from file"
  task load: :environment do
    config = Sidekiq::Cron::Tasks.config

    next if config.schedule.empty?

    prefixed_hash = config.schedule.each_with_object({}) do |(name, options), new_hash|
      prefixed_name = name.sub(/\A(#{config.prefix} )?/, config.prefix + " ")
      new_hash[prefixed_name] = options
    end

    Sidekiq::Cron::Job.all.select { |job| job.name =~ /\A#{config.prefix} / }.each(&:destroy)
    Sidekiq::Cron::Job.load_from_hash prefixed_hash
  end
end
