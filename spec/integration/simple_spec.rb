require 'spec_helper'

describe MassMigrator do
  def table_columns(table_name)
    $db.schema(table_name, :reload => true).map {|(column, data)| column }
  end

  context "migrating over one table" do
    it "alters schema" do
      $db.create_table!(:mentions_client_1) { Integer :id, :primary_key => true }
      migration = Class.new(MassMigrator::Migration) do
        def up
          alter_table table_name do
            add_column :created_at, :datetime
          end
        end
      end
      MassMigrator.new(/^mentions_client_1$/, :db => $db).run_pending_migrations
      table_columns(:mentions_client_1).should include(:created_at)
    end

    it "can be reverted" do
      $db.create_table!(:mentions_client_1) { Integer :id, :primary_key => true }
      migration = Class.new(MassMigrator::Migration) do
        def up
          alter_table table_name do
            add_column :created_at, :datetime
          end
        end

        def self.name
          'AddCreatedAt'
        end
      end

      MassMigrator.new(/^mentions_client_1$/, :db => $db).run_pending_migrations
      table_columns(:mentions_client_1).should include(:created_at)
    end
  end
end
