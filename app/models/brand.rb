class Brand < ApplicationRecord
  has_many :strollers, dependent: :destroy
end
