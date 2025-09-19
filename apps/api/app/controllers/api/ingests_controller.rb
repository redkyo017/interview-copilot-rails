class Api::IngestsController < ApplicationController
  def create
    title = params.require(:title)
    kind  = params.require(:kind) # "cv"|"jd"
    # text  = params.require(:text) # keep simple: plain text for Day 1
    text =
      if params[:file].present?
        Rag::PdfExtractor.extract(params[:file].tempfile)
      else
        params.require(:text)
      end

    doc = Document.create!(title: title, kind: kind, text: text, chunks_json: chunk(text))

    vectors = Rag::Embedder.embed(doc.chunks_json)
    ActiveRecord::Base.transaction do
      vectors.each_with_index do |vec, i|
        Embedding.create!(document: doc, chunk_index: i, vector: vec)
      end
    end
    render json: { id: doc.id }, status: :created
  end

  private

  def chunk(text)
    # naive chunker by characters; swap later with token-based
    size = 800
    text.scan(/.{1,#{size}}/m)
  end
end
