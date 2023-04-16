# frozen_string_literal: true

module RailsPgAdapter
  class Configuration
    attr_accessor :add_failover_patch, :add_reset_column_information_patch, :reconnect_with_backoff

    def initialize(attrs)
      self.add_failover_patch = attrs[:add_failover_patch]
      self.add_reset_column_information_patch = attrs[:add_reset_column_information_patch]
      self.reconnect_with_backoff = attrs[:reconnect_with_backoff]
    end
  end

  def self.configuration
    @configuration ||= Configuration.new({
      add_failover_patch: false,
      add_reset_column_information_patch: false,
      reconnect_with_backoff: [],
    })
  end

  def self.configure
    yield(configuration)
  end

  def self.failover_patch?
    RailsPgAdapter.configuration.add_failover_patch || false
  end

  def self.reconnect_with_backoff?
    !RailsPgAdapter.configuration.reconnect_with_backoff.empty?
  end

  def self.reset_column_information_patch?
    RailsPgAdapter.configuration.add_reset_column_information_patch || false
  end

  def self.reset_configuration
    @configuration = Configuration.new({
      add_failover_patch: false,
      add_reset_column_information_patch: false,
      reconnect_with_backoff: [],
    })
  end
end
