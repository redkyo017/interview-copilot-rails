class AddIndexToEmbedding < ActiveRecord::Migration[7.1]
  def change
    # Add vector column with dimensions if it doesn't exist or has no dimensions
    unless column_exists?(:embeddings, :vector)
      add_column :embeddings, :vector, :vector, limit: 1536
    else
      # If column exists but has no dimensions, recreate it
      execute "ALTER TABLE embeddings DROP COLUMN IF EXISTS vector;"
      add_column :embeddings, :vector, :vector, limit: 1536
    end

    # Create index on vector column
    execute "CREATE INDEX index_embeddings_on_vector ON embeddings USING ivfflat (vector vector_cosine_ops) WITH (lists = 100);"
    add_index :embeddings, [:document_id, :chunk_index], unique: true
  end
end
