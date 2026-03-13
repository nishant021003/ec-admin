# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductImportService, type: :service do
  it "imports products from CSV" do
    create(:category, name: "Category 1")
    create(:category, name: "Category 2")
    csv = Tempfile.new(["products", ".csv"])
    csv.write("name,description,price,status,stock_quantity,slug,categories\n")
    csv.write("Imported Product,Desc,500,draft,10,imported-1,Category 1\n")
    csv.write("Another Product,More,1000,active,5,,Category 2\n")
    csv.rewind
    csv.close
    result = described_class.new(csv.path).call
    expect(result[:imported]).to eq(2)
    expect(result[:errors]).to be_empty
    expect(Product.find_by(name: "Imported Product")).to be_present
    csv.unlink
  end

  it "imports partial when some rows invalid" do
    create(:category, name: "Cat1")
    csv = Tempfile.new(["products", ".csv"])
    csv.write("name,description,price,status,stock_quantity,categories\n")
    csv.write("Valid Product,Desc,100,draft,5,Cat1\n")
    csv.write(",Invalid,0,draft,0,\n")
    csv.rewind
    csv.close
    result = described_class.new(csv.path).call
    expect(result[:imported]).to eq(1)
    expect(result[:errors]).not_to be_empty
    csv.unlink
  end

  it "returns errors for invalid rows" do
    csv = Tempfile.new(["products", ".csv"])
    csv.write("name,price\n,100\n")
    csv.rewind
    csv.close
    result = described_class.new(csv.path).call
    expect(result[:imported]).to eq(0)
    expect(result[:errors]).not_to be_empty
    csv.unlink
  end
end
