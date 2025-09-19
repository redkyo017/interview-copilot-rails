class Document < ApplicationRecord
  has_many :embeddings, dependent: :delete_all
  KINDS = %w[cv jd].freeze
  validates :title, :text, presence: true
  validates :kind, inclusion: { in: KINDS }
end
