require "rails_helper"

RSpec.describe "API::Queries", type: :request do
  # Helper: build a fixed-dim vector quickly
  def v(val, dim = 1536) = Array.new(dim, val.to_f)

  before do
    # Stub the embedder to return deterministic vectors
    allow(Rag::Embedder).to receive(:embed) do |texts|
      texts.map { |t|
        # simple hash-to-float: short texts closer to 0.1, long closer to 0.9
        val = [0.1 + (t.length % 8) * 0.1, 0.9].min
        v(val)
      }
    end
  end

  it "returns an answer with sources (Top-k vector search)" do
    # Seed one CV and one JD with embeddings
    cv = Document.create!(title: "My CV", kind: "cv", text: "aaa", chunks_json: ["aaa", "bbb"])
    jd = Document.create!(title: "JD", kind: "jd", text: "requirements rails react", chunks_json: ["rails", "react"])

    Rag::Embedder.embed(cv.chunks_json).each_with_index do |vec, i|
      Embedding.create!(document: cv, chunk_index: i, vector: vec)
    end
    Rag::Embedder.embed(jd.chunks_json).each_with_index do |vec, i|
      Embedding.create!(document: jd, chunk_index: i, vector: vec)
    end

    post "/api/queries", params: { question: "What should I emphasize for Rails and React?" }
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json["answer"]).to be_a(String)
    expect(json["sources"]).to be_an(Array)
    expect(json["sources"]).not_to be_empty

    # Ensure we get both kinds back among top hits
    kinds = json["sources"].map { |s| s["kind"] }.uniq
    expect(kinds).to include("cv").and include("jd")
  end
end
