class CreateTrackableItems < ActiveRecord::Migration
  def change
    create_table :trackable_items do |t|
      t.string :name

      t.timestamps
    end
  end
end
