class CreateEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :embeddings do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :chunk_index

      t.timestamps
    end
  end
end
