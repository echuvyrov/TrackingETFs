class CreateLookups < ActiveRecord::Migration
  def change
    create_table :lookups do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
