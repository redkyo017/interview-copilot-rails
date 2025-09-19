class AddVectorToEmbeddings < ActiveRecord::Migration[7.1]
  def up
    execute "ALTER TABLE embeddings ADD COLUMN vector vector(1536);"
  end

  def down
    remove_column :embeddings, :vector
  end
end
