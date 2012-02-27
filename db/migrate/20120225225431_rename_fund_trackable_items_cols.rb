class RenameFundTrackableItemsCols < ActiveRecord::Migration
  def up
    rename_column :fund_trackable_items, :FundId, :fund_id
    rename_column :fund_trackable_items, :TrackableItemId, :trackable_item_id
  end

  def down
    rename_column :fund_trackable_items, :fund_id, :FundId
    rename_column :fund_trackable_items, :trackable_item_id, :TrackableItemId
  end
end
