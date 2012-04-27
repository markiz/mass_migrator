class AddUpdatedAt < MassMigrator::Migration
  def up
    add_column :updated_at, DateTime
  end
end
