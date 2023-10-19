require 'rails_helper'

RSpec.describe "Items API", type: :request do
  describe "GET /api/v1/items" do
    it "returns a list of items" do
      create_list(:item, 3)

      get '/api/v1/items'

      expect(response).to have_http_status :ok

      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data].length).to eq 3
    end
  end

  describe "GET /api/v1/items/:id" do
    it "returns a single item" do
      item = create(:item)

      get "/api/v1/items/#{item.id}"

      expect(response).to have_http_status :ok

      item_response = JSON.parse(response.body, symbolize_names: true)
      expect(item_response[:data][:id]).to eq("#{item.id}")
    end

    it "returns a 404 if the item is not found" do
      get "/api/v1/items/999999999"

      expect(response).to have_http_status(:not_found)

    end
  end

  describe "POST /api/v1/items" do
    it "creates a new item" do
      merchant = create(:merchant)
      item_params = {
        name: 'test item',
        description: 'test description',
        unit_price: 10.99,
        merchant_id: merchant.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

      expect(response).to have_http_status :created

      created_item = Item.last
      expect(created_item.name).to eq(item_params[:name])
    end

    it "returns a 404 if the item is invalid" do
      merchant = create(:merchant)
      item_params = {
        name: '',
        description: 'test description',
        unit_price: 10.99,
        merchant_id: merchant.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

      expect(response).to have_http_status :not_found
    end
  end

  describe "PUT /api/v1/items/:id" do
    it "updates an existing item" do
      item = create(:item)
      item_params = { name: 'test item' }
      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item_params)

      expect(response).to have_http_status :ok

      item_response = JSON.parse(response.body, symbolize_names: true)
      expect(item_response[:data][:attributes][:name]).to eq(item_params[:name])
    end

    it "returns a 404 if the item is not found" do
      put "/api/v1/items/9999999999"

      expect(response).to have_http_status :not_found
    end

    it "returns a 404 if the merchant id is invalid" do
      item = create(:item)
      item_params = { merchant_id: 999999999 }
      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item_params)

      expect(response).to have_http_status :not_found      
    end
  end

  describe "DELETE /api/v1/items/:id" do
    it "deletes an item" do
      item = create(:item)

      expect {
        delete "/api/v1/items/#{item.id}"
      }.to change(Item, :count).by(-1)

      expect(response).to have_http_status :no_content
    end

    it "returns a 404 if the item is not found" do
      delete "/api/v1/items/999"

      expect(response).to have_http_status(:not_found)
    end
  end
end
