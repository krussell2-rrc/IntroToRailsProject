class AllBooksController < ApplicationController
  def index
    @q = Book.ransack(params[:q])
    @books = @q.result(distinct: true).page(params[:page]).per(15)
  end

  def show
    @book = Book.find(params[:id])
  end
end
