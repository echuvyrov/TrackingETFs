class AddFundTypeAndOrganization < ActiveRecord::Migration
  def up
    change_table :funds do |t|
      t.string :etftype
      t.string :etforganization_type
    end
  end

  def down
    change_table :funds do |t|
      t.remove :etftype, :etforganizatintype
    end
  end
end
