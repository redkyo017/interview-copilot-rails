class AddIndexToDocumentsKind < ActiveRecord::Migration[7.1]
  def change
    add_index :documents, :kind
  end
end
