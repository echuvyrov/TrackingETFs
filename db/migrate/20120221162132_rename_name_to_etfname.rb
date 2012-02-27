class RenameNameToEtfname < ActiveRecord::Migration
  def up
    rename_column :funds, :name, :etfname
  end

  def down
    rename_column :funds, :etfname, :name
  end
end
