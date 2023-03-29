# frozen_string_literal: true

require "active_record"
require "pry"

class Dummy
  private

  def exec_no_cache; end
  def disconnect!; end
end

EXCEPTION_MESSAGE = "PG::ReadOnlySqlTransaction: ERROR:  cannot execute UPDATE in a read-only transaction"
COLUMN_EXCEPTION_MESSAGE = "PG::UndefinedColumn: ERROR:  column users.template_id does not exist"

RSpec.describe(RailsPgAdapter::Patch) do
  before do
    RailsPgAdapter.configure do |c|
      c.add_failover_patch = true
      c.add_reset_column_information_patch = true
    end
  end

  describe "#exec_cache" do
    it "clears connection when a PG::ReadOnlySqlTransaction exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_cache).and_raise(
        ActiveRecord::StatementInvalid.new(EXCEPTION_MESSAGE)
      )

      allow_any_instance_of(Object).to receive(:sleep)
      expect(ActiveRecord::Base.connection_pool).to receive(:remove)
      expect_any_instance_of(Dummy).to receive(:disconnect!)
      expect { Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_cache) }.to raise_error(
        ActiveRecord::StatementInvalid,
        "PG::ReadOnlySqlTransaction: ERROR:  cannot execute UPDATE in a read-only transaction"
      )
    end

    it "does not call clear_all_connections when a general exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_cache).and_raise("Exception")
      expect(ActiveRecord::Base).not_to receive(:clear_all_connections!)
      expect { Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_cache) }.to raise_error(
        "Exception"
      )
    end

    it "clears schema cache when a PG::UndefinedColumn exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_cache).and_raise(
        ActiveRecord::StatementInvalid.new(COLUMN_EXCEPTION_MESSAGE)
      )

      expect(ActiveRecord::Base).to receive(:descendants).at_least(:once).and_call_original

      expect { Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_cache) }.to raise_error(
        ActiveRecord::StatementInvalid,
        "PG::UndefinedColumn: ERROR:  column users.template_id does not exist"
      )
    end
  end

  describe "#exec_no_cache" do
    it "calls clear_all_connections when a PG::ReadOnlySqlTransaction exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_no_cache).and_raise(
        ActiveRecord::StatementInvalid.new(EXCEPTION_MESSAGE)
      )

      allow_any_instance_of(Object).to receive(:sleep)
      expect(ActiveRecord::Base.connection_pool).to receive(:remove)
      expect_any_instance_of(Dummy).to receive(:disconnect!)

      expect do
        Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_no_cache)
      end.to raise_error(
        ActiveRecord::StatementInvalid,
        "PG::ReadOnlySqlTransaction: ERROR:  cannot execute UPDATE in a read-only transaction"
      )
    end

    it "does not call clear_all_connections when a general exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_no_cache).and_raise("Exception")
      expect(ActiveRecord::Base).not_to receive(:clear_all_connections!)
      expect do
        Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_no_cache)
      end.to raise_error("Exception")
    end

    it "clears schema cache when a PG::UndefinedColumn exception is raised" do
      allow_any_instance_of(Dummy).to receive(:exec_no_cache).and_raise(
        ActiveRecord::StatementInvalid.new(COLUMN_EXCEPTION_MESSAGE)
      )

      expect(ActiveRecord::Base).to receive(:descendants).at_least(:once).and_call_original

      expect do
        Dummy.new.extend(RailsPgAdapter::Patch).send(:exec_no_cache)
      end.to raise_error(
        ActiveRecord::StatementInvalid,
        "PG::UndefinedColumn: ERROR:  column users.template_id does not exist"
      )
    end
  end
end
