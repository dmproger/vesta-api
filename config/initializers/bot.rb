require_relative '../../app/jobs/bot'
require_relative '../../app/delayed_jobs/bot/tink_job'

Delayed::Job.enqueue(Bot::TinkJob.new, cron: '*/3 * * * *')
