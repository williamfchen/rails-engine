class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end

  def create
    item = Item.new(item_params)
    
    if item.save
      render json: ItemSerializer.new(item), status: :created
    else
      render json: { error: 'Invalid item parameters' }, status: :not_found
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item)
    else
      render json: { error: 'Invalid item parameters' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  
        
  def destroy
    Item.find(params[:id]).destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end

  # def merchant
  #   render json: MerchantSerializer.new(Item.find(params[:id]).merchant)
  # rescue ActiveRecord::RecordNotFound
  #   render json: { error: 'Item not found' }, status: :not_found
  # end

  def find
    if params[:name]
      item = Item.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name).first
      return render json: { error: 'Item not found' }, status: :not_found unless item
      render json: ItemSerializer.new(item)
    elsif params[:min_price] || params[:max_price]
      item = Item.where('unit_price >= ?', params[:min_price].to_f).where('unit_price <= ?', params[:max_price].to_f).order(:name).first
      return render json: { error: 'Item not found' }, status: :not_found unless item
      render json: ItemSerializer.new(item)
    else
      render json: { error: 'Invalid search parameters' }, status: :bad_request
    end
  end
  
  def find_all
    if params[:name]
      items = Item.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name)
      if items.empty?
        return render json: { error: 'No items found' }, status: :not_found
      end
      render json: ItemSerializer.new(items)
    elsif params[:min_price] || params[:max_price]
      items = Item.where('unit_price >= ?', params[:min_price].to_f).where('unit_price <= ?', params[:max_price].to_f).order(:name)
      if items.empty?
        return render json: { error: 'No items found within price range' }, status: :not_found
      end
      render json: ItemSerializer.new(items)
    else
      render json: { error: 'Invalid search parameters' }, status: :bad_request
    end
  end

  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id)
  end
end