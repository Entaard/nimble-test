class CreateResultItems < ActiveRecord::Migration[6.0]
  def change
    create_table :result_items do |t|
      t.references :search_metadata
      t.text :live_html
      t.text :cached_html

      t.timestamps
    end
  end
end
