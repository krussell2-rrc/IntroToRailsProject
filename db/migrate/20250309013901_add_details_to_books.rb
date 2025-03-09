class AddDetailsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :work_key, :string
    add_column :books, :description, :string
  end
end
