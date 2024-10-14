class SalesController < ApplicationController
  # before_action :authenticate_request!, except: [:index, :show]  # Only authenticated users can create, update, or delete
  # before_action :set_sale, only: %i[show update destroy]

  # GET /sales
  def index
    @sales = Sale.all
    render json: @sales, status: :ok
  end

  # GET /sales/1
  def show
    render json: @sale, status: :ok
  end

  # POST /sales
  def create
    @sale = Sale.new(sale_params)
    if @sale.save
      render json: @sale, status: :created
    else
      render json: @sale.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sales/1
  def update
    if @sale.update(sale_params)
      render json: @sale, status: :ok
    else
      render json: @sale.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sales/1
  def destroy
    if @sale.destroy
      render json: { message: 'Sale deleted' }, status: :ok
    else
      render json: { errors: 'Sale could not be deleted' }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sale
    @sale = Sale.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sale_params
    params.require(:sale).permit(:event_id, :ticket_id, :revenue)
  end
end
