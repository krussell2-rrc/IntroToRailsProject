class RemoveDetailsFromAuthors < ActiveRecord::Migration[8.0]
  def change
    remove_column :authors, :top_work, :string
    remove_column :authors, :work_count, :integer
  end
end
