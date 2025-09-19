module Rag
  class Embedder
    # Replace later with real provider call; keep interface stable for tests
    def self.embed(texts)
      # return Array<Array<Float>>
      raise NotImplementedError
    end
  end
end