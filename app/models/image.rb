class Image < ApplicationRecord
  belongs_to :product

  def attribution_required?
    attribution_url.present? || attribution_text.present?
  end
end
