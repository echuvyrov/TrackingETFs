class AddOrganizationTypeTable < ActiveRecord::Migration
  def up
    create_table :organization_type do |t|
      t.string  :etforganization_type
    end
    change_table :funds do |t|
      t.text :tax_consequences
    end
  end

  def down
    remove_table :organization_type
    change_table :funds do |t|
      t.remove :tax_consequences
    end    
  end
end
