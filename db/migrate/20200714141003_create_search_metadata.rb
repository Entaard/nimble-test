class CreateSearchMetadata < ActiveRecord::Migration[6.0]
  def change
    create_table :search_metadata do |t|
      t.string :keyword
      t.references :user
      t.integer :num_of_ads
      t.integer :num_of_links
      t.string :num_of_all_results
      t.string :search_time

      t.timestamps
    end

    add_index :search_metadata, [:keyword, :user_id]
  end
end
