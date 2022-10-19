workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 3001
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Ensure we don't keep connections
  if defined?(Sequel)
    ::Sequel::Model.db.disconnect
    ::Sequel::DATABASES.each(&:disconnect)
  end
end

after_worker_boot do
  SequelRails.setup Rails.env if defined?(SequelRails)
end
