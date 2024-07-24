class StrollersController < ProductsController
  before_action :set_stroller, only: %i[ show edit update destroy ]

  # GET /strollers or /strollers.json
  def index
    @strollers = Stroller.all

    # group by brand
    @strollers_by_brand = @strollers.group_by(&:brand)
    puts @strollers_by_brand
  end

  # GET /strollers/1 or /strollers/1.json
  def show
  end

  # GET /strollers/new
  def new
    @stroller = Stroller.new
  end

  # GET /strollers/1/edit
  def edit
  end

  # POST /strollers or /strollers.json
  def create
    brand_name = params["stroller"]["brand_name"]
    brand = Brand.find_by(name: brand_name)

    # if brand does not exist, throw error
    if brand.nil?
      raise ActiveRecord::RecordNotFound
    end
    # create stroller, using brand_id from brand object
    @stroller = Stroller.new(brand_id: brand.id, name: params[:name])

    respond_to do |format|
      if @stroller.save
        format.html { redirect_to stroller_url(@stroller), notice: "Stroller was successfully created." }
        format.json { render :show, status: :created, location: @stroller }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stroller.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /strollers/1 or /strollers/1.json
  def update
    respond_to do |format|
      if @stroller.update(stroller_params)
        format.html { redirect_to stroller_url(@stroller), notice: "Stroller was successfully updated." }
        format.json { render :show, status: :ok, location: @stroller }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stroller.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /strollers/1 or /strollers/1.json
  def destroy
    @stroller.destroy!

    respond_to do |format|
      format.html { redirect_to strollers_url, notice: "Stroller was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stroller
    @stroller = Product.where(productable_id: params[:id], productable_type: 'Stroller').first.productable
  end

  # Only allow a list of trusted parameters through.
  def stroller_params
    params.require(:stroller).permit(:brand_id, :name)
  end
end
