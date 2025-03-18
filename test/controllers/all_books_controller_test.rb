require "test_helper"

class AllBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get all_books_index_url
    assert_response :success
  end

  test "should get show" do
    get all_books_show_url
    assert_response :success
  end
end
