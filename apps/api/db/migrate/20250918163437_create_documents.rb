class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.string :kind, null: false # "cv" | "jd"
      t.text :text, null: false
      t.jsonb :chunks_json, null: false, default: []

      t.timestamps
    end
  end
end
