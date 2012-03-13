class AddFundSubType < ActiveRecord::Migration
  def up
    change_table :funds do |t|
      t.string :etfsubtype
    end
  end

  def down
    change_table :funds do |t|
      t.remove :etfsubtype
    end
  end
end
