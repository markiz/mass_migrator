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

    def passed
      @pending = false
    end

    def name
      self.class.name
    end

    def run
      up
      passed
      self
    end

    def method_missing(method, *args, &block)
      if db.respond_to?(method)
        db.send(method, *args, &block)
      else
        super
      end
    end

    def inspect
      "<#{name} @table_name=#{table_name} @pending=#{pending?}>"
    end
  end
end
