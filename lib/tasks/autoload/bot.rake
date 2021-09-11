namespace :bot do
  desc 'Schedule all cron jobs'
  task jobs: :environment do
    # Need to load all jobs definitions in order to find subclasses
    glob = Rails.root.join('app', 'jobs', '**', '*.rb')
    Dir.glob(glob).each { |file| require file }
    Bot.subclasses.each(&:schedule)
  end
end

# invoke jobs automatically after every migration and schema load
%w[db:migrate db:schema:load].each do |task|
  Rake::Task[task].enhance do
    Rake::Task['bot:jobs'].invoke
  end
end
