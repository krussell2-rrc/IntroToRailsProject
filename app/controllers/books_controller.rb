class BooksController < ApplicationController
  def index
    @books = Book.includes(:authors).all
  end

  def show
    @book = Book.find(params[:id])
  end
end
