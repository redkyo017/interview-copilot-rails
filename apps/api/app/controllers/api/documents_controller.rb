class Api::DocumentsController < ApplicationController
  def index
    # Case 1 facing N+1 issue
    # docs = Document.order(created_at: :desc).limit(50)
    # render json: docs.map { |d|
    #   # N+1 on Embedding.where(...).count for each doc
    #   { id: d.id, title: d.title, kind: d.kind, embeddings_count: Embedding.where(document_id: d.id).count }
    # }
    #
    # Case 2 - Fix N+1 create a counter_cache
    # # db/migrate/003_add_embeddings_count_to_documents.rb
    # class AddEmbeddingsCountToDocuments < ActiveRecord::Migration[7.1]
    #   def change
    #     add_column :documents, :embeddings_count, :integer, null: false, default: 0
    #   end
    # end
    # # app/models/embedding.rb
    # class Embedding < ApplicationRecord
    #   belongs_to :document, counter_cache: true
    # end
    # (no more N+1):
    # def index
    # docs = Document.order(created_at: :desc).limit(50)
    #   render json: docs.as_json(only: [:id, :title, :kind, :embeddings_count])
    # end
    #
    # Case 3 using join
    docs = Document
    .left_joins(:embeddings)
    .select("documents.*, COUNT(embeddings.id) AS ecount")
    .group("documents.id")
    .order(created_at: :desc).limit(50)

    render json: docs.map { |d| { id: d.id, title: d.title, kind: d.kind, embeddings_count: d.attributes["ecount"].to_i } }
  end
end
