class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Merchant not found' }, status: :not_found
  end
  
  def find_all
    if params[:name]
      merchants = Merchant.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name)
      if merchants.empty?
        return render json: { error: 'No merchants found' }, status: :not_found
      end
      render json: MerchantSerializer.new(merchants)
    else
      render json: { error: 'Invalid search parameters' }, status: :bad_request
    end
  end
end