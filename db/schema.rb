# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_09_034608) do
  create_table "author_books", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_author_books_on_author_id"
    t.index ["book_id"], name: "index_author_books_on_book_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "author_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author_key"
    t.string "biography"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.integer "first_publish_year"
    t.integer "edition_count"
    t.integer "cover_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.string "work_key"
    t.string "description"
  end

  add_foreign_key "author_books", "authors"
  add_foreign_key "author_books", "books"
end
