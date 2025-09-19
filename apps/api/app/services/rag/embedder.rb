# frozen_string_literal: true
require "net/http"
require "json"

module Rag
  class Embedder
    DIM = Rails.configuration.x.embeddings.dim

    class << self
      # texts: Array<String> -> Array<Array<Float>>
      def embed(texts)
        provider = Rails.configuration.x.embeddings.provider

        case provider
        when "mock"   then mock_embed(texts)
        when "openai" then openai_embed(texts)
        else
          raise ArgumentError, "Unknown EMBEDDINGS_PROVIDER=#{provider.inspect}"
        end
      end

      private

      # Deterministic, fast, test-friendly mock; retains interface stability.
      def mock_embed(texts)
        texts.map { |t| pseudo_vec(t, DIM) }
      end

      def pseudo_vec(text, dim)
        seed = text.bytes.sum % 97
        base = 0.05 + (seed % 9) * 0.1
        Array.new(dim, base).tap do |arr|
          # add a tiny pattern so different texts aren’t identical
          (0...dim).step(127).each { |i| arr[i] = (base + 0.03) % 1.0 }
        end
      end

      # Minimal OpenAI embeddings call using Net::HTTP (no extra gem needed).
      def openai_embed(texts)
        api_key = Rails.configuration.x.embeddings.openai_api_key or
          raise "OPENAI_API_KEY missing"
        model = Rails.configuration.x.embeddings.openai_model
        max_b = Rails.configuration.x.embeddings.max_batch

        texts.each_slice(max_b).flat_map do |batch|
          body = { model:, input: batch }.to_json
          uri = URI("https://api.openai.com/v1/embeddings")
          res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            req = Net::HTTP::Post.new(uri)
            req["Authorization"] = "Bearer #{api_key}"
            req["Content-Type"]  = "application/json"
            req.body = body
            http.request(req)
          end
          raise "OpenAI error: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
          json = JSON.parse(res.body)
          json.fetch("data").map { |d| d.fetch("embedding") }
        end
      end
    end
  end
end