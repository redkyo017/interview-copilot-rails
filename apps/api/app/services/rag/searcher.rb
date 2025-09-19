module Rag
  class Searcher
    TOP_K = 5

    def self.query(question:)
      q_vec = Rag::Embedder.embed([question]).first
      # Use neighbor gem for vector similarity search
      rows = Embedding
        .joins(:document)
        # raw SQL for cosine distance ordering
        # .select("embeddings.*, 1 - (embeddings.vector <=> '#{PG::Connection.escape_string(q_vec.pack('F*'))}'::vector) AS sim")
        # .order("embeddings.vector <=> '#{PG::Connection.escape_string(q_vec.pack('F*'))}'::vector ASC")
        .nearest_neighbors(:vector, q_vec, distance: "cosine")
        .limit(TOP_K)

      sources = rows.map do |e|
        { doc_id: e.document_id, chunk_index: e.chunk_index, title: e.document.title, kind: e.document.kind }
      end
      {
        answer: "Stubbed synthesis over #{sources.size} chunks.",
        sources: sources
      }
    end
  end
end