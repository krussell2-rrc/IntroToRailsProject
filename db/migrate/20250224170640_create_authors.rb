class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :author_name
      t.string :top_work
      t.integer :work_count

      t.timestamps
    end
  end
end
