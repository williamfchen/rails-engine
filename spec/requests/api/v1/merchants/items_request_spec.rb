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
end
