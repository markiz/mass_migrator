require 'bundler/setup'
require 'mass_migrator'
require 'pry'

$db_connect_opts = ENV['MM_SPEC_CONNECT_OPTS'] || 'mysql2://localhost/mm_test'
$db = Sequel.connect $db_connect_opts
RSpec.configure do |c|
  c.before(:all) do
    [:mentions_1, :mentions_2, :mentions_3].each do |table|
      $db.drop_table(table) if $db.table_exists?(table)
    end
  end

  c.before(:each) do
    $db[:mm_schema_info].delete
    MassMigrator::Migration.list.clear
  end
end
