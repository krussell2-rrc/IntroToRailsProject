class Author < ApplicationRecord
  validates :author_name, :top_work, :work_count, presence: true
end
