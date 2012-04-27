# mass_migrator

Tool for making life easier with migrations on multiple tables. For example, you have a lot of sharded tables with names like `mentions_client_XXX`, where XXX is a client id. And you want to simultaneously change all of the tables and remember the changes. That's where mass_migrator kicks in.

## Dependencies

* Sequel
  * Sequel-based adapter for your db

## Usage

Create a migrations, for example:

```
class AddUpdatedAt < MassMigrator::Migration
  def up
    add_column table_name, :updated_at, DateTime
  end

  def down
    drop_column table_name, :updated_at
  end
end
```

Notice that your `up` and `down` methods have access to all the standard sequel data modification methods, as well as currently migrated table_name.

Then you need to perform a migration.

### Via command-line tool

`mass_migrate up -c 'mysql2://localhost/test_db' -t "mentions_client_\\d+" -m 'directory/with/migrations' --verbose`

### Via ruby API

```
require 'mass_migrator'
db = Sequel.mysql2 "test_db"
MassMigrator.new(/mentions_client_\d+/, :db => db, :migrations => "path/to/migrations").run_pending_migrations
```

### Where is info about run migrations kept?

Schema info table (configurable, default name is `mm_schema_info`) is created prior to running migrations.
