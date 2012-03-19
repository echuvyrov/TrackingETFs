class AddNameToEtfTypes < ActiveRecord::Migration
  def up
    change_table :etf_types do |t|
      t.string :etftype_name
    end
  end

  def down
    change_table :etf_types do |t|
      t.remove :etftype_name
    end
  end
end
