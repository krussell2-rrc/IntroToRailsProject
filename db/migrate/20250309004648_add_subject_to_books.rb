class AddSubjectToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :subject, :string
  end
end
