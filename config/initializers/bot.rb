require_relative '../../app/delayed_jobs/bot/tink_job'

INTERVAL_IN_MINUTS = 5

Delayed::Job.enqueue(Bot::TinkJob.new, cron: "*/#{ INTERVAL_IN_MINUTS } * * * *")
