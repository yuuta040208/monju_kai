class Race < ApplicationRecord
  has_many :predicts, dependent: :destroy
end
