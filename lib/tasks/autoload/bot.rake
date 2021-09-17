namespace :bot do
  desc 'Schedule all cron jobs'
  namespace :tink do
    task job: :environment do
      # Need to load all jobs definitions in order to find subclasses
      glob = Rails.root.join('app', 'delayed_jobs', '**', '*.rb')
      Dir.glob(glob).each { |file| require file }
      Bot.subclasses.each(&:schedule)
    end
  end
end
