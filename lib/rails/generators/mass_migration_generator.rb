class MassMigrationGenerator < Rails::Generators::NamedBase
  desc 'Creates a mass migration with a given name'
  argument :migrations_folder, :type => :string, :default => 'db/mass_migrate'
  def create_migration
    @migration_name = file_name.classify
    inside migrations_folder do
      template File.expand_path("../templates", __FILE__) + '/mass_migration.erb', "#{file_name}.rb"
    end
  end
end
