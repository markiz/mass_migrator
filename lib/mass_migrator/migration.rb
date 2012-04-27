class MassMigrator
  class Migration
    def self.list
      @list ||= []
    end

    def self.inherited(migration)
      list << migration
    end

    attr_reader :db, :table_name

    def initialize(db, table_name)
      @db         = db
      @table_name = table_name
      @pending    = true
    end

    def pending?
      @pending
    end

    def passed?
      !pending?
    end

    def mark_as_passed
      @pending = false
    end

    def mark_as_pending
      @pending = true
    end

    def name
      self.class.name
    end

    def run
      logger.info "Starting migration #{name} on #{table_name}"
      up
      mark_as_passed
      logger.info "Finished migration #{name} on #{table_name}"
      self
    end

    def revert
      logger.info "Reverting migration #{name} on #{table_name}"
      down
      mark_as_pending
      logger.info "Reverted migration #{name} on #{table_name}"
      self
    end

    def method_missing(method, *args, &block)
      if db.respond_to?(method)
        db.send(method, *args, &block)
      else
        super
      end
    end

    def logger
      @logger = MassMigrator.logger
    end

    def inspect
      "<#{name} @table_name=#{table_name} @pending=#{pending?}>"
    end
  end
end
