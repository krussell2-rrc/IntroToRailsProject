class RemovePrimaryLanguageFromBooks < ActiveRecord::Migration[8.0]
  def change
    remove_column :books, :primary_language, :string
  end
end
