class EmbeddingsWorker
  include Sidekiq::Worker

  def perform(document_id)
    doc = Document.find(document_id)
    vectors = Rag::Embedder.embed(doc.chunks_json)
    Embedding.where(document_id: doc.id).delete_all
    vectors.each_with_index do |vec, i|
      Embedding.create!(document_id: doc.id, chunk_index: i, vector: vec)
    end
  end
end