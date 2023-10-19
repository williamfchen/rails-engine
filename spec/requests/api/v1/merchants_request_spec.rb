require 'rails_helper'

RSpec.describe "Merchants API", type: :request do
  describe "GET /api/v1/merchants" do
    before do
      create_list(:merchant, 3)
      get '/api/v1/merchants'
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "returns a status code of 200" do
      expect(response.status).to eq 200
    end

    it "returns a list of merchants" do
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants).to be_a Hash
      expect(merchants[:data].length).to eq 3
    end
  end

  describe "GET /api/v1/merchants/:id" do
    let(:merchant) { create(:merchant) }

    before do
      get "/api/v1/merchants/#{merchant.id}"
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "returns a single merchant" do
      merchant_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchant_response).to be_a(Hash)
      expect(merchant_response[:data][:id]).to eq("#{merchant.id}")
      expect(merchant_response[:data][:attributes][:name]).to eq("#{merchant.name}")
    end
  end
end