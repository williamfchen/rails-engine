require 'rails_helper'

describe "Merchant Items API" do
  describe "GET /api/v1/merchants/:id/items" do
    it "returns the merchant" do
      merchant = create(:merchant)
      item1 = create(:item, merchant: merchant)
      item2 = create(:item, merchant: merchant)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to have_http_status :ok

      items_response = JSON.parse(response.body, symbolize_names: true)

      item_ids = items_response[:data].map { |item| item[:id].to_i }
      expect(item_ids).to include(item1.id, item2.id)
    end

    it "returns a 404 if the merchant is not found" do
      get "/api/v1/merchants/999999/items"

      expect(response).to have_http_status :not_found
      expect(response.body).to include('Merchant not found')
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
end
