class CreateEtfTypes < ActiveRecord::Migration
  def change
    create_table :etf_types do |t|
      t.string
      t.timestamps
    end
  end
end
