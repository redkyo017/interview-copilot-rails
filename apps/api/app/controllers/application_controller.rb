class ApplicationController < ActionController::API
  def index
    docs = Document.order(created_at: :desc).limit(50)
    render json: docs.map { |d|
      # N+1 on Embedding.where(...).count for each doc
      { id: d.id, title: d.title, kind: d.kind, embeddings_count: Embedding.where(document_id: d.id).count }
    }
  end
end
