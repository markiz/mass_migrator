require 'spec_helper'

describe MassMigrator::Migration do
  def table_columns(table_name)
    $db.schema(table_name, :reload => true).map {|(column, data)| column }
  end

  let(:migration_class) do
    Class.new(described_class) do
      def self.name
        "AddCreatedAtToMentions"
      end

      def up
        alter_table table_name do
          add_column :created_at, DateTime
        end
      end

      def down
        alter_table table_name do
          drop_column :created_at, DateTime
        end
      end
    end
  end

  before(:each) { $db.create_table!(:mentions_client_2) { Integer :id, :primary_key => true } }
  subject { migration_class.new($db, :mentions_client_2) }

  it "has a hook on inherited" do
    klass = Class.new(described_class)
    described_class.list.should include(klass)
  end

  it "is pending by default" do
    subject.should be_pending
  end

  it "can be marked as passed" do
    subject.passed
    subject.should_not be_pending
    subject.should be_passed
  end

  it "has a name" do
    subject.name.should == "AddCreatedAtToMentions"
  end

  it "has table name" do
    subject.table_name.should == :mentions_client_2
  end

  it "can be run" do
    table_columns(:mentions_client_2).should_not include(:created_at)
    subject.run
    table_columns(:mentions_client_2).should include(:created_at)
  end

end
