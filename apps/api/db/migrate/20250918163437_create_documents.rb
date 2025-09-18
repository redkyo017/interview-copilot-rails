class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :kind
      t.text :text
      t.jsonb :chunks_json

      t.timestamps
    end
  end
end
