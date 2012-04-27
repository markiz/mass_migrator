require 'spec_helper'

describe MassMigrator do
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
      columns = $db.schema(:mentions_client_1, :reload => true).map {|(column, data)| column }
      columns.should include(:created_at)
    end
  end
end
