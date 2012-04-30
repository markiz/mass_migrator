require 'logger'
require 'sequel'
require 'mass_migrator/version'
require 'mass_migrator/migration'

class MassMigrator
  class DatabaseError < StandardError
  end

  def self.logger
    @logger ||= verbose? ? Logger.new(STDOUT) : Logger.new('/dev/null')
  end

  def self.verbose?
    !!@verbose
  end

  def self.verbose=(value)
    @verbose = value
    @logger = nil
  end

  attr_reader :tables_pattern, :options

  def initialize(tables_pattern, options = {})
    @tables_pattern = tables_pattern
    @options        = options
    initialize_schema_info_table
    require_migration_files
  end

  def tables
    @tables ||= db.tables.select {|t| t.to_s =~ tables_pattern }
  end

  def run_pending_migrations
    pending_migrations.each do |migration|
      migration.run
      schema_info_table << {
        :table_name     => migration.table_name.to_s,
        :migration_name => migration.name
      }
    end
  end

  def revert_migrations(*migration_names)
    migrations = passed_migrations.select {|migration| migration_names.include?(migration.name) }
    migrations.each do |migration|
      migration.revert
      schema_info_table.filter({
        :table_name     => migration.table_name.to_s,
        :migration_name => migration.name
      }).delete
    end
  end

  def pending_migrations
    migrations.select(&:pending?)
  end

  def passed_migrations
    migrations.select(&:passed?)
  end

  def migrations
    @migrations ||= load_migrations
  end

  def logger
    self.class.logger
  end

  protected

  def load_migrations
    tables.map {|table| instantiate_migrations_for(table) }.compact.flatten
  end

  def require_migration_files
    migrations_path = options[:migrations]
    if migrations_path
      Dir["#{File.expand_path(migrations_path)}/*.rb"].each do |migration|
        require migration
      end
    end
  end

  def instantiate_migrations_for(table)
    Migration.list.map do |migration_class|
      migration = migration_class.new(db, table)
      migration.mark_as_passed if passed_migrations_records_for(table).include?(migration.name)
      migration
    end
  end

  def db
    @db ||= options[:db] || connect_to_db
  end

  def schema_info_table
    db[schema_info_table_name]
  end

  def schema_info_table_name
    @schema_info_table_name ||= options[:schema_info_table_name] || :mm_schema_info
  end

  def passed_migrations_records
    @migration_records ||= schema_info_table.all.inject({}) do |result, record|
      table = record[:table_name].to_sym
      result[table] ||= []
      result[table] << record[:migration_name]
      result
    end
  end

  def passed_migrations_records_for(table)
    passed_migrations_records[table] ||= []
  end

  def connect_to_db
    if options[:db_connect_options]
      Sequel.connect options[:db_connect_options]
    else
      raise DatabaseError, "You should provide connection options to MassMigrator"
    end
  end

  def initialize_schema_info_table
    unless db.table_exists?(schema_info_table_name)
      db.create_table :mm_schema_info do
        primary_key :id
        String :table_name
        String :migration_name
      end
    end
  end
end
