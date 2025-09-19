class AddIndexToEmbedding < ActiveRecord::Migration[7.1]
  def change
    # Choose one supported by your pgvector version: :ivfflat or :hnsw
    # For ivfflat you must set a list count; hnsw has params too.
    execute "CREATE INDEX index_embeddings_on_vector ON embeddings USING ivfflat (vector vector_cosine_ops) WITH (lists = 100);"
    add_index :embeddings, [:document_id, :chunk_index], unique: true
  end
end
