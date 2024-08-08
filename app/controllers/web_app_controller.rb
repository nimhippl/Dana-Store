class WebAppController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :products]

  def index
    @categories = Category.all
    @chat_id = params[:chat_id]
    @category = Category.find_by(id: params[:category_id]) || @categories.first
    @products = @category.products if @category
  end

  def products
    @category = Category.find(params[:category_id])
    @categories = Category.all
    @chat_id = params[:chat_id]
    @products = @category.products
    render 'index'
  end
end
