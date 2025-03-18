class AllBooksController < ApplicationController
  def index
    @books = Book.page(params[:page]).per(15)
  end

  def show
    @book = Book.find(params[:id])
  end
end
