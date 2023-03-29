# RailsPgAdapter

This project allows you to monkey patch `ActiveRecord` (PostgreSQL) and auto-heal applications in production when PostgreSQL database fails over or when a cached column (in `ActiveRecord` schema cache) is removed from the database from a migration in another process.

## How does it work

During a database failover in production, the `ActiveRecord` connection pool can become exhausted as queries are made against the database during the failover process. This can leave the `ActiveRecord` connection pools with stale or bad connections, even after the database has successfully recovered. Recovering from this issue usually requires a rolling restart of the application processes or containers.

`RailsPgAdapter` addresses this problem by resetting the connection pool and re-raises the original exception from an `ActiveRecord` monkey patch. This allows the application to auto-heal from stale connections on its own (after database recovery) when performing queries for a new request, without requiring manual intervention.

Another issue with `ActiveRecord` queries is `PG::UndefinedColumn`, which occurs when an `ActiveRecord` model includes a `SELECT` query with the name of a column that has been dropped from a Rails migration. This can happen even if the column isn't being referenced anywhere in the code. It occurs when a model is using `ignored_columns`, which prompts `ActiveRecord` to perform a dedicated lookup of the allowed columns in a select, such as `SELECT "users".name, "users".template_id...."`, instead of `SELECT "users".*`. When a column like `template_id` is dropped, PostgreSQL throws an undefined column error, which is bubbled up by `ActiveRecord` into `PG::UndefinedColumn`. Recovering from this issue also usually requires a rolling restart of the application processes or containers.

`RailsPgAdapter` solves this second issue by resetting the `ActiveRecord` schema cache and memoized model column information when it detects a `PG::UndefinedColumn` raised from a monkey patch. Resetting the column information forces `ActiveRecord` to refresh its schema cache by loading the table information from the database and no longer reference the dropped column for new queries, without requiring manual intervention.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rails-pg-adapter

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rails-pg-adapter

## Usage

### Auto healing connections when PostgreSQL database fails over

```ruby
# config/initializer/rails_pg_adapter.rb

RailsPgAdapter.configure do |c|
  c.add_failover_patch = true
end
```

This will add the monkey patch which resets the `ActiveRecord` connections in the connection pool when the database fails over. The patch will reset the connection and re-raise the error each time it detects that an exception related to a database failover is detected.

### Refresh model column information on the fly after an existing column is dropped

```ruby
# config/initializer/rails_pg_adapter.rb

RailsPgAdapter.configure do |c|
  c.add_reset_column_information_patch = true
end
```

This will clear the `ActiveRecord` schema cache and reset the `ActiveRecord` column information memoized on the model. The patch will reset the relevant information and re-raise the error each time it detects that an exception related to a dropped column is raised.

## Development

- Install ruby 3.0

```
\curl -sSL https://get.rvm.io | bash

rvm install 3.0.0

rvm use 3.0.0
```

- `docker compose up -d` - to spin up postgres locally
- `bundle exec rspec` to run the tests.
- You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tines/rails-pg-adapter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tines/rails-pg-adapter/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `RailsPgAdapter` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tines/rails-pg-adapter/blob/main/CODE_OF_CONDUCT.md).

## Releasing a new version

- Bump version in `version.rb`
- Update `CHANGELOG.md`
- Push the changes to `main`
- Run the release script with the new version `./bin/release.sh 0.2.0`
  - Note: It will ask for MFA.
- Create a new release - https://github.com/tines/rails-pg-adapter/releases/new
