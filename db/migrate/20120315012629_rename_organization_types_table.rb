class RenameOrganizationTypesTable < ActiveRecord::Migration
  def up
    rename_table :organization_type, :organization_types
  end

  def down
    rename_table :organization_types, :organization_type
  end
end
