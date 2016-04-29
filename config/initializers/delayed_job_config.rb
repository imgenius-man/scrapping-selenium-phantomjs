Delayed::Worker.max_attempts = 2
Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
