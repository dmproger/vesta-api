glob = Rails.root.join('app', 'delayed_jobs', '**', '*.rb')
Dir.glob(glob).each { |file| require file }
Bot.subclasses.each(&:schedule)
