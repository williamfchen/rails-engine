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

  def find
    return render_invalid_parameters if invalid_parameters?
    item = search_item
    render_result(item)
  end

  def find_all
    return render_invalid_parameters if invalid_parameters?
    items = search_items
    render_items(items)
  end
  
  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id)
  end
  
  def invalid_parameters?
    (params[:name].blank? && params[:min_price].blank? && params[:max_price].blank?) ||
    (params[:name] && (params[:min_price] || params[:max_price])) ||
    params[:min_price].to_f < 0 || params[:max_price].to_f < 0
  end

  def render_invalid_parameters
    render json: { errors: 'Cannot provide both name and price parameters' }, status: :bad_request
  end

  def search_item
    if params[:name]
      Item.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name).first
    elsif params[:min_price]
      return nil if params[:min_price].to_f < 0
      Item.where('unit_price >= ?', params[:min_price].to_f).order(:name).first
    elsif params[:max_price]
      return nil if params[:max_price].to_f < 0
      Item.where('unit_price <= ?', params[:max_price].to_f).order(:name).first
    end
  end
  
  def render_result(item)
    if item
      render json: ItemSerializer.new(item)
    else
      render json: { data: {} }, status: :not_found
    end
  end

  def invalid_parameters?
    (params[:name].blank? && params[:min_price].blank? && params[:max_price].blank?) ||
    (params[:name] && (params[:min_price] || params[:max_price])) ||
    params[:min_price].to_f < 0 || params[:max_price].to_f < 0 ||
    (params[:min_price] && params[:max_price] && params[:min_price].to_f > params[:max_price].to_f)
  end

  def render_invalid_parameters
    render json: { errors: 'Invalid search parameters' }, status: :bad_request
  end

  def search_items
    if params[:name]
      Item.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name)
    else
      items_query = Item.order(:name)
      items_query = items_query.where('unit_price >= ?', params[:min_price].to_f) if params[:min_price].present?
      items_query = items_query.where('unit_price <= ?', params[:max_price].to_f) if params[:max_price].present?
      items_query
    end
  end

  def render_items(items)
    if items.any?
      render json: ItemSerializer.new(items)
    else
      render json: { data: [] }, status: :not_found
    end
  end
end