# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rails_pg_adapter/version"

Gem::Specification.new do |spec|
  spec.name = "rails-pg-adapter"
  spec.version = RailsPgAdapter::VERSION
  spec.summary = "Rails Postgres ActiveRecord patches for common production workloads"
  spec.description = "This project allows you to monkey patch ActiveRecord (PostgreSQL) and auto-heal applications in production when PostgreSQL database fails over or when a cached column (in ActiveRecord schema cache) is removed from the database from a migration in another process."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.authors = ["Tines Engineering"]
  spec.email = ["engineering@tines.com"]
  spec.homepage = "http://github.com/tines/rails-pg-adapter"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "http://github.com/tines/rails-pg-adapter/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency("rails", "~> 6", "<7")

  spec.metadata = { "rubygems_mfa_required" => "true" } if spec.respond_to?(:metadata=)
end
