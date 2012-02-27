class RemoveIdFromFundTrackableItems < ActiveRecord::Migration
  def up
    remove_column :fund_trackable_items, :id
  end

  def down
    add_column :fund_trackable_items, :id, :integer
  end
end
