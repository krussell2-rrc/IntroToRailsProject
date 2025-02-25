class Author < ApplicationRecord
  validates :title, presence: true
end
