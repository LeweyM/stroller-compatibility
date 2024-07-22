class Brand < ApplicationRecord
  has_many :strollers, dependent: :destroy
  has_many :seats, dependent: :destroy
end
