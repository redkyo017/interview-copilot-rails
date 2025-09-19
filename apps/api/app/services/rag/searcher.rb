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
        # 
        # select("embeddings.*, 1 - (embeddings.vector <=> $1::vector) AS sim", q_vec)
        # .order(Arel.sql("embeddings.vector <=> $1::vector ASC"), q_vec)
        # .nearest_neighbors(:vector, q_vec, distance: "cosine")
        # .limit(TOP_K)
        .select(
          "embeddings.*, " \
          "1 - (embeddings.vector <=> $1::vector) AS cosine, " \
          "documents.title AS doc_title, documents.kind AS doc_kind, documents.chunks_json"
        )
        .order(Arel.sql("embeddings.vector <=> $1::vector ASC"), q_vec)
        .limit(TOP_K)
        .bind([nil, q_vec])  # parameter binding (ActiveRecord >=7 supports bind)

      candidates = rows.map do |e|
        chunk_txt = (e.chunks_json || [])[e.chunk_index] || ""
        {
          doc_id: e.document_id,
          title:  e.doc_title,
          kind:   e.doc_kind,
          chunk_index: e.chunk_index,
          chunk_text: chunk_txt,
          cosine: e.attributes["cosine"].to_f
        }
      end

      reranked = Rag::Reranker.rescore(question:, candidates:)

      # sources = rows.map do |e|
      #   { doc_id: e.document_id, chunk_index: e.chunk_index, title: e.document.title, kind: e.document.kind }
      # end
      {
        answer: "Stubbed synthesis over #{sources.size} chunks.",
        # sources: sources
        sources: reranked.map { |c|
          { doc_id: c[:doc_id], title: c[:title], kind: c[:kind], chunk_index: c[:chunk_index],
            cosine: c[:cosine].round(3), keyword: c[:keyword_overlap].round(3), score: c[:rerank_score].round(3) }
        }
      }
    end
  end
end