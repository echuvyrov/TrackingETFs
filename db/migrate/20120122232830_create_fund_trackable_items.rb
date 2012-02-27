class CreateFundTrackableItems < ActiveRecord::Migration
  def change
    create_table :fund_trackable_items do |t|
      t.integer :FundId
      t.integer :TrackableItemId

      t.timestamps
    end
  end
end
