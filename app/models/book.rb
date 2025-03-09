class Book < ApplicationRecord
  validates :title, :work_key, :description, :subject, :first_publish_year, :edition_count, :cover_identifier, presence: true
end
