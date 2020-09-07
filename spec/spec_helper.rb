# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  load_profile "test_frameworks"

  enable_coverage :branch
  minimum_coverage 90
end

require "bundler/setup"
require "ecs_oneshot"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Aws.config.update({
   credentials: Aws::Credentials.new("access_key_id", "secret_access_key"),
   region: "us-west-1"
})
