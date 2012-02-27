class CreateFunds < ActiveRecord::Migration
  def change
    create_table :funds do |t|
      t.string :tickersymbol
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
