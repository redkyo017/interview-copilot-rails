# frozen_string_literal: true
require "pdf/reader"

module Rag
  class PdfExtractor
    # Returns a single UTF-8 string
    def self.extract(io_or_path)
      text = +""
      reader =
        if io_or_path.respond_to?(:read)
          PDF::Reader.new(io_or_path)
        else
          PDF::Reader.new(io_or_path.to_s)
        end
      reader.pages.each { |p| text << normalize(p.text) << "\n" }
      text.encode!("UTF-8", invalid: :replace, undef: :replace, replace: " ")
      text.strip
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
      raise ArgumentError, "Failed to read PDF: #{e.message}"
    end

    def self.normalize(s)
      s.gsub(/\r\n?/, "\n").gsub(/\u00A0/, " ").squeeze(" ")
    end
  end
end
