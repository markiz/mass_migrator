class AddUpdatedAt < MassMigrator::Migration
  def up
    add_column table_name, :updated_at, DateTime
  end

  def down
    drop_column table_name, :updated_at
  end
end
