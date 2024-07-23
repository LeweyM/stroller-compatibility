class ProductsController < ApplicationController
  def fits
    @product = get_product(params[:id])
    @other_products = Seat.all + Stroller.all
    @other_products.filter! { |p| p != @product and p.class != @product.class }
  end

  def compatible
    @productClass = case params[:type]
                    when "seats"
                      Seat
                    when "stroller"
                      Stroller
                    else
                      raise ActiveRecord::RecordNotFound
                    end
    puts @productClass.all
    puts params
  end

  private

  def get_product(id)
    throw ActiveRecord::RecordNotFound
  end
end
