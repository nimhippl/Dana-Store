class CategoriesController < ApplicationController
def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path
    else
      render :new
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.name == 'Прочее'
      redirect_to categories_path
    else
      @category.destroy
      redirect_to categories_path
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
