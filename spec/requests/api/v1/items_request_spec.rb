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

  describe 'GET /api/v1/items/:id/merchant' do
    it "returns the merchant for an item" do
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)

      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to have_http_status :ok

      merchant_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchant_response[:data][:id]).to eq("#{merchant.id}")
    end

    it "returns a 404 if the item is not found" do
      get "/api/v1/items/999999999/merchant"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/items/find" do
    it "returns the first item that matches the search criteria" do
      item1 = create(:item, name: 'apple')
      item2 = create(:item, name: 'pear')
      item3 = create(:item, name: 'pearssss')

      get "/api/v1/items/find?name=#{item2.name}"

      expect(response).to have_http_status :ok

      item_response = JSON.parse(response.body, symbolize_names: true)
      expect(item_response[:data][:id]).to eq("#{item2.id}")
    end

    it "returns a 404 if no item matches the search criteria" do
      get "/api/v1/items/find?name=apple"

      expect(response).to have_http_status :not_found
    end

    it "finds an item by min_price" do
      item1 = create(:item, unit_price: 1.99)
      item2 = create(:item, unit_price: 2.99)

      get "/api/v1/items/find?min_price=2.00"

      expect(response).to have_http_status :ok

      item_response = JSON.parse(response.body, symbolize_names: true)
      expect(item_response[:data][:id]).to eq("#{item2.id}")
    end

    it "returns a 404 if no item matches the min_price" do
      get "/api/v1/items/find?min_price=2.00"

      expect(response).to have_http_status :not_found
    end

    it "finds an item by max_price" do
      item1 = create(:item, unit_price: 1.99)
      item2 = create(:item, unit_price: 2.99)

      get "/api/v1/items/find?max_price=2.00"

      expect(response).to have_http_status :ok

      item_response = JSON.parse(response.body, symbolize_names: true)
      expect(item_response[:data][:id]).to eq("#{item1.id}")
    end

    it "returns a 404 if no item matches the max_price" do
      get "/api/v1/items/find?max_price=2.00"

      expect(response).to have_http_status :not_found
    end
  end

  describe "GET /api/v1/items/find_all" do
    it "returns all items that match the search criteria" do
      item1 = create(:item, name: 'apple')
      item2 = create(:item, name: 'pear')
      item3 = create(:item, name: 'pearssss')

      get "/api/v1/items/find_all?name=#{item2.name}"

      expect(response).to have_http_status :ok

      items_response = JSON.parse(response.body, symbolize_names: true)
      expect(items_response[:data].length).to eq 2
    end

    it "returns a 404 if no item matches the search criteria" do
      get "/api/v1/items/find_all?name=apple"

      expect(response).to have_http_status :not_found
    end

    it "finds all items by min_price" do
      item1 = create(:item, unit_price: 1)
      item2 = create(:item, unit_price: 3)
      item3 = create(:item, unit_price: 4)

      get "/api/v1/items/find_all?min_price=2.00"

      expect(response).to have_http_status :ok

      items_response = JSON.parse(response.body, symbolize_names: true)
      expect(items_response[:data].length).to eq 2
      returned_ids = items_response[:data].map { |item| item[:id] }
      expect(returned_ids).to include("#{item2.id}", "#{item3.id}")
    end

    it "returns a 404 if no item matches the min_price" do
      get "/api/v1/items/find_all?min_price=2.00"

      expect(response).to have_http_status :not_found
    end

    it "finds all items by max_price" do
      item1 = create(:item, unit_price: 1)
      item2 = create(:item, unit_price: 3)
      item3 = create(:item, unit_price: 4)

      get "/api/v1/items/find_all?max_price=2.00"

      expect(response).to have_http_status :ok

      items_response = JSON.parse(response.body, symbolize_names: true)
      expect(items_response[:data].length).to eq 1
      expect(items_response[:data].first[:id]).to eq("#{item1.id}")
    end

    it "returns a 404 if no item matches the max_price" do
      get "/api/v1/items/find_all?max_price=2.00"

      expect(response).to have_http_status :not_found
    end

    it "finds all items by min_price and max_price" do
      item1 = create(:item, unit_price: 1)
      item2 = create(:item, unit_price: 3)
      item3 = create(:item, unit_price: 4)

      get "/api/v1/items/find_all?min_price=2.00&max_price=4.00"

      expect(response).to have_http_status :ok

      items_response = JSON.parse(response.body, symbolize_names: true)
      expect(items_response[:data].length).to eq 2
      returned_ids = items_response[:data].map { |item| item[:id] }
      expect(returned_ids).to include("#{item2.id}", "#{item3.id}")
    end

    it "returns a 400 if min_price is greater than max_price" do
      get "/api/v1/items/find_all?min_price=4.00&max_price=2.00"

      expect(response).to have_http_status :bad_request
    end

    it "returns a 404 if no item matches the min_price and max_price" do
      get "/api/v1/items/find_all?min_price=2.00&max_price=4.00"

      expect(response).to have_http_status :not_found
    end
  end
end
