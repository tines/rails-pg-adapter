# frozen_string_literal: true

RSpec.describe(RailsPgAdapter::Configuration) do
  after :each do
    RailsPgAdapter.reset_configuration
  end

  describe "new" do
    it "initializes with the passed attributes" do
      c =
        described_class.new({ add_failover_patch: true, add_reset_column_information_patch: true })

      expect(c.add_failover_patch).to be(true)
      expect(c.add_reset_column_information_patch).to be(true)
    end

    it "initializes with the defaults" do
      c = RailsPgAdapter.configuration

      expect(c.add_failover_patch).to be(false)
      expect(c.add_reset_column_information_patch).to be(false)
    end
  end

  describe "yields" do
    it "correctly with the passed attributes" do
      RailsPgAdapter.configure do |c|
        c.add_failover_patch = true
        c.add_reset_column_information_patch = true
      end

      config = RailsPgAdapter.configuration

      expect(config.add_failover_patch).to be(true)
      expect(config.add_reset_column_information_patch).to be(true)
    end
  end

  describe ".failover_patch?" do
    it "returns false" do
      expect(RailsPgAdapter.failover_patch?).to be(false)
    end

    it "returns true" do
      RailsPgAdapter.configure { |c| c.add_failover_patch = true }
      expect(RailsPgAdapter.failover_patch?).to be(true)
    end
  end

  describe ".reset_column_information_patch?" do
    it "returns false" do
      expect(RailsPgAdapter.reset_column_information_patch?).to be(false)
    end

    it "returns true" do
      RailsPgAdapter.configure { |c| c.add_reset_column_information_patch = true }
      expect(RailsPgAdapter.reset_column_information_patch?).to be(true)
    end
  end
end
