class Author < ApplicationRecord
  has_many :author_books
  has_many :books, through: :author_books
  validates :author_name, :author_key, :biography, presence: true
end
