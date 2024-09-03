class Admin::TagsController < ApplicationController
  def create
    brand = Brand.find(tag_params[:brand_id])
    raise "Brand not found" unless brand
    @tag = Tag.create!(tag_params.merge(brand: brand))
    redirect_to edit_admin_brand_path(brand), notice: 'Tag was successfully created.'
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy!
  end

  private

  def tag_params
    params.require(:tag).permit(:label, :brand_id)
  end
end
