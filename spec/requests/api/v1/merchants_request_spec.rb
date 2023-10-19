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

  describe "GET /api/v1/merchants/find" do
    it "finds a single merchant by name" do
      merchant1 = create(:merchant, name: "Apple")
      merchant2 = create(:merchant, name: "Pear")

      get "/api/v1/merchants/find", params: { name: "pear" }

      expect(response).to have_http_status :ok

      merchant_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchant_response[:data][:id]).to eq("#{merchant2.id}")
    end

    it "returns a 404 if no merchant matches the name" do
      get "/api/v1/merchants/find", params: { name: "SKLDJEmlksmd" }

      expect(response).to have_http_status :not_found

      error_response = JSON.parse(response.body, symbolize_names: true)
      expect(error_response[:data][:error]).to eq('No merchants found')
    end
  end

  describe "GET /api/v1/merchants/find_all" do
    it "finds all merchants by name" do
      merchant1 = create(:merchant, name: "Apple")
      merchant2 = create(:merchant, name: "Pear")
      merchant3 = create(:merchant, name: "Pearsss")

      get "/api/v1/merchants/find_all", params: { name: "pear" }

      expect(response).to have_http_status :ok

      merchants_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_response[:data].length).to eq 2
      expect(merchants_response[:data].first[:id]).to eq("#{merchant2.id}")
      expect(merchants_response[:data].last[:id]).to eq("#{merchant3.id}")
    end

    it "returns an empty array if no merchants match the name" do
      get "/api/v1/merchants/find_all", params: { name: "SKLDJEmlksmd" }

      expect(response).to have_http_status :ok

      merchants_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_response[:data]).to eq([])
    end
  end
end