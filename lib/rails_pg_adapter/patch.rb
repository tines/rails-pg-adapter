# frozen_string_literal: true
require "active_record/connection_adapters/postgresql_adapter"

module RailsPgAdapter
  module Patch
    CONNECTION_ERROR = [
      "Lost connection",
      "gone away",
      "read-only",
      "PG::ReadOnlySqlTransaction",
      "PG::UnableToSend",
      "PG::ConnectionBad",
      "the database system is starting up",
      "connection is closed",
      "could not connect",
    ].freeze
    CONNECTION_ERROR_RE = /#{CONNECTION_ERROR.map { |w| Regexp.escape(w) }.join("|")}/.freeze

    CONNECTION_SCHEMA_ERROR = ["PG::UndefinedColumn"].freeze
    CONNECTION_SCHEMA_RE = /#{CONNECTION_SCHEMA_ERROR.map { |w| Regexp.escape(w) }.join("|")}/.freeze

    private

    def exec_cache(*args)
      super(*args)
    rescue ::ActiveRecord::StatementInvalid, ::ActiveRecord::ConnectionNotEstablished => e
      raise unless supported_errors?(e)

      try_reconnect?(e) ? retry : handle_error(e)
    end

    def exec_no_cache(*args)
      super(*args)
    rescue ::ActiveRecord::StatementInvalid, ::ActiveRecord::ConnectionNotEstablished => e
      raise unless supported_errors?(e)

      try_reconnect?(e) ? retry : handle_error(e)
    end

    def try_reconnect?(e)
      return false if in_transaction?
      return false unless failover_error?(e.message)
      return false unless RailsPgAdapter.reconnect_with_backoff?

      begin
        reconnect!
        true
      rescue ::ActiveRecord::ConnectionNotEstablished
        false
      end
    end

    def handle_error(e)
      if failover_error?(e.message) && RailsPgAdapter.failover_patch?
        warn("clearing connections due to #{e} - #{e.message}")
        disconnect_and_remove_conn!
        raise(e)
      end

      return unless missing_column_error?(e.message) && RailsPgAdapter.reset_column_information_patch?

      warn("clearing column information due to #{e} - #{e.message}")

      internal_clear_schema_cache!
      raise
    end

    def failover_error?(error_message)
      CONNECTION_ERROR_RE.match?(error_message)
    end

    def missing_column_error?(error_message)
      CONNECTION_SCHEMA_RE.match?(error_message)
    end

    def disconnect_and_remove_conn!
      disconnect!
      ::ActiveRecord::Base.connection_pool.remove(::ActiveRecord::Base.connection)
    end

    def internal_clear_schema_cache!
      ::ActiveRecord::Base.connection_pool.connections.each { |conn| conn.schema_cache.clear! }
      ::ActiveRecord::Base.descendants.each(&:reset_column_information)
    end

    def warn(msg)
      return unless defined?(Rails)
      return if Rails.logger.nil?
      ::Rails.logger.warn("[RailsPgAdapter::Patch] #{msg}")
    end

    def supported_errors?(e)
      return true if failover_error?(e.message) && RailsPgAdapter.failover_patch?
      if missing_column_error?(e.message) && RailsPgAdapter.reset_column_information_patch?
        return true
      end
      false
    end
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(RailsPgAdapter::Patch)

# Override new client connection to bake in retries
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      class << self
        old_new_client_method = instance_method(:new_client)

        define_method(:new_client) do |args|
          sleep_times = RailsPgAdapter.configuration.reconnect_with_backoff.dup
          begin
            old_new_client_method.bind(self).call(args)
          rescue ::ActiveRecord::ConnectionNotEstablished => e
            raise(e) unless RailsPgAdapter.failover_patch? && RailsPgAdapter.reconnect_with_backoff?

            sleep_time = sleep_times.shift
            raise unless sleep_time
            warn( "Could not establish a connection from new_client, retrying again in #{sleep_time} sec.")
            sleep(sleep_time)
            retry
          end
        end
      end
    end
  end
end
