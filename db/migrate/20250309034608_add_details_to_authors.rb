class AddDetailsToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :author_key, :string
    add_column :authors, :biography, :string
  end
end
