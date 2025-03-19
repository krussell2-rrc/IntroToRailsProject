class Book < ApplicationRecord
  has_many :author_books
  has_many :authors, through: :author_books
  validates :title, :work_key, :description, :subject, :first_publish_year, :edition_count, :cover_identifier, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "title", "subject" ]
  end
end
