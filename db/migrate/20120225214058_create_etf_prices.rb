class CreateEtfPrices < ActiveRecord::Migration
  def change
    create_table :etf_prices do |t|
      t.date :pricedate
      t.decimal :price
      t.integer :fund_id

      t.timestamps
    end
  end
end
