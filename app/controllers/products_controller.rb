class ProductsController < ApplicationController
  before_action :load_categories, only: [:new, :create, :edit, :update]

  def index
    @products = Product.without_deleted
  end


  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to products_path
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
  end

  def archived
    @products = Product.only_deleted.order(created_at: :desc)
  end

  def archived_show
    @product = Product.only_deleted.find(params[:id])
  end

  def restore
    @product = Product.only_deleted.find(params[:id])
    @product.restore
    redirect_to archived_products_products_path
  end

  def really_destroy
    @product = Product.only_deleted.find(params[:id])
    Order.where(product_id: @product.id).destroy_all
    @product.really_destroy!
    redirect_to archived_products_products_path
  end

  private

  def product_params
    params.require(:product).permit(:name, :category_id, :price, :quantity, :image)
  end

  def load_categories
    @categories = Category.all
  end

end
