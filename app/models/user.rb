class User < ApplicationRecord
  has_many :predicts, dependent: :destroy
end
