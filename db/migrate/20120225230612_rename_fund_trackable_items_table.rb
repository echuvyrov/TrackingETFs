class RenameFundTrackableItemsTable < ActiveRecord::Migration
  def up
    rename_table :fund_trackable_items, :funds_trackable_items 
  end

  def down
    rename_table :funds_trackable_items, :fund_trackable_items
  end
end
