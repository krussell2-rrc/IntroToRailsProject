class Book < ApplicationRecord
  validates :title, :primary_language, :first_publish_year, :edition_count, :cover_identifier, presence: true
end
