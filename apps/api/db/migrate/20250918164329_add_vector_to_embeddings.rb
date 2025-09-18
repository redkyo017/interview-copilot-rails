class AddVectorToEmbeddings < ActiveRecord::Migration[7.1]
  def change
    add_column :embeddings, :vector, :vector, limit: 1536
  end
end
