require 'spec_helper'

describe MassMigrator do
  subject { MassMigrator.new(/^mentions_client_3$/, :db => $db) }

  def table_columns(table_name)
    $db.schema(table_name, :reload => true).map {|(column, data)| column }
  end

  let!(:migration_class) do
    Class.new(MassMigrator::Migration) do
      def up
        add_column table_name, :created_at, DateTime
      end

      def down
        drop_column table_name, :created_at
      end

      def self.name
        "AddCreatedAt"
      end
    end
  end

  before(:each) do
    $db.create_table!(:mentions_client_3) { primary_key :id }
    $db.drop_table(:mm_schema_info) if $db.table_exists?(:mm_schema_info)
  end

  it "initializes schema info table unless it exists" do
    $db.drop_table(:mm_schema_info) if $db.table_exists?(:mm_schema_info)
    subject
    $db.tables.should include(:mm_schema_info)
  end

  it "doesn't recreate schema info table if it exists" do
    $db.create_table!(:mm_schema_info) { primary_key :id }
    $db[:mm_schema_info] << {}
    subject
    $db.tables.should include(:mm_schema_info)
    $db[:mm_schema_info].count.should > 0
  end

  it "instantiates migrations" do
    migration = subject.migrations.detect {|m| m.table_name == :mentions_client_3 && m.name.should == "AddCreatedAt" }
    migration.should_not be_nil
    migration.should be_pending
  end

  it "runs migrations" do
    subject.run_pending_migrations
    described_class.new(/^mentions_client_3$/, :db => $db).pending_migrations.should be_empty
    table_columns(:mentions_client_3).should include(:created_at)
  end

  it "creates records about run migrations" do
    subject.run_pending_migrations
    migration_record = $db[:mm_schema_info].
                          filter(:table_name     => 'mentions_client_3',
                                 :migration_name => 'AddCreatedAt').
                          first
    migration_record.should_not be_nil
  end

  it "preloads migrations from given path" do
    MassMigrator::Migration.list.clear
    migrator = MassMigrator.new(/^mentions_client_3$/, :db => $db, :migrations => "spec/fixtures/migrations")
    migrator.migrations.size.should > 0
  end

  it "can revert migrations" do
    subject.run_pending_migrations
    table_columns(:mentions_client_3).should include(:created_at)
    subject.revert_migrations("AddCreatedAt")
    table_columns(:mentions_client_3).should_not include(:created_at)
  end

  it "removes records from schema info table upon reverting" do
    subject.run_pending_migrations
    $db[:mm_schema_info].filter(:table_name     => 'mentions_client_3',
                                :migration_name => 'AddCreatedAt').
                         first.should_not be_nil
    subject.revert_migrations("AddCreatedAt")
    $db[:mm_schema_info].filter(:table_name     => 'mentions_client_3',
                                :migration_name => 'AddCreatedAt').
                         first.should be_nil
  end
end
