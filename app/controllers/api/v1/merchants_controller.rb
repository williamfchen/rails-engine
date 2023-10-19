class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def find
    if params[:name].blank?
      return render_invalid_parameters
    end
    
    merchant = find_merchant_by_name(params[:name])
    
    if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: { data: { error: 'No merchants found' } }, status: :not_found
    end
  end

  def find_all
    if params[:name].blank?
      return render_invalid_parameters
    end
    
    merchants = find_merchants_by_name(params[:name])
    render json: merchants.any? ? MerchantSerializer.new(merchants) : { data: [] }, status: :ok
  end

  private

  def handle_not_found
    render json: { data: { error: 'No merchants found' } }, status: :not_found
  end

  def render_invalid_parameters
    render json: { data: { errors: 'Invalid search parameters' } }, status: :bad_request
  end

  def find_merchant_by_name(name)
    Merchant.where('LOWER(name) LIKE ?', "%#{name.downcase}%").order(:name).first
  end

  def find_merchants_by_name(name)
    Merchant.where('LOWER(name) LIKE ?', "%#{name.downcase}%").order(:name)
  end
end
