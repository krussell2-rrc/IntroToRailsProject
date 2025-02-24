class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :primary_language
      t.integer :first_publish_year
      t.integer :edition_count
      t.integer :cover_identifier

      t.timestamps
    end
  end
end
