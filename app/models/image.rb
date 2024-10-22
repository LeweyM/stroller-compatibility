class Image < ApplicationRecord
  belongs_to :product

  validates :url, presence: true

  def attribution_required?
    attribution_url.present? || attribution_text.present?
  end
end
