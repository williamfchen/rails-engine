class Api::V1::Merchants::ItemsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: ItemSerializer.new(merchant.items)
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'Merchant not found' }, status: :not_found
  end

  def show
    render json: MerchantSerializer.new(Item.find(params[:id]).merchant)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end
end
