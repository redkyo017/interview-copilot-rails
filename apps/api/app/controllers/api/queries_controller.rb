class Api::QueriesController < ApplicationController
  def create
    q = params.require(:question)
    result = Rag::Searcher.query(question: q)
    render json: result
  end
end
