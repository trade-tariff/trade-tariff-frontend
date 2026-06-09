require 'English'

if ENV['PARALLEL_RSPEC_CHILD'] != 'true' && !ENV.key?('TEST_ENV_NUMBER')
  if ARGV.any?
    ENV['PARALLEL_RSPEC_CHILD'] = 'true'
  else
    workers = Integer(ENV.fetch('PARALLEL_TEST_PROCESSORS', 5))

    unless ENV['SKIP_PARALLEL_TEST_PREPARE'] == 'true'
      system('bin/rails', 'assets:precompile')
      exit($CHILD_STATUS.exitstatus || 1) unless $CHILD_STATUS.success?
    end

    exec(
      { 'PARALLEL_RSPEC_CHILD' => 'true' },
      'bundle',
      'exec',
      'parallel_test',
      '-n',
      workers.to_s,
      '--type',
      'rspec',
      '--serialize-stdout',
      'spec',
    )
  end
end
