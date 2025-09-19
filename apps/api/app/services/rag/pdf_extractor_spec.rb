require "rails_helper"

RSpec.describe Rag::PdfExtractor do
  it "extracts normalized text from a simple pdf" do
    File.open(Rails.root.join("spec/fixtures/files/sample.pdf"), "rb") do |io|
      text = described_class.extract(io)
      expect(text).to include("Sample")
      expect(text.encoding).to eq(Encoding::UTF_8)
    end
  end
end