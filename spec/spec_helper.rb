# frozen_string_literal: true

require "active_record/railtie"
require "rspec/rails"
require_relative "../lib/rails-pg-adapter"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      host: "localhost",
      port: 5434,
      user: "tines",
      password: "tines",
      database: "tines",
    )
  end
end
