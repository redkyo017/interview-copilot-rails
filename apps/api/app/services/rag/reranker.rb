module Rag
  class Reranker
    # Mix cosine similarity (0..1) with keyword overlap (0..1)
    # weights: e.g., {cosine: 0.7, keyword: 0.3}
    def self.rescore(question:, candidates:, weights: { cosine: 0.7, keyword: 0.3 })
      q_terms = terms(question)
      candidates.map do |c|
        kw = jaccard(q_terms, terms(c[:chunk_text]))
        score = (weights[:cosine] * c[:cosine]) + (weights[:keyword] * kw)
        c.merge(rerank_score: score, keyword_overlap: kw)
      end.sort_by { |c| -c[:rerank_score] }
    end

    def self.terms(s)
      s.downcase.scan(/[a-z0-9]+/).reject { |t| t.size < 2 }.uniq
    end

    def self.jaccard(a, b)
      a = a.to_set; b = b.to_set
      return 0.0 if a.empty? || b.empty?
      (a & b).size.to_f / (a | b).size
    end
  end
end