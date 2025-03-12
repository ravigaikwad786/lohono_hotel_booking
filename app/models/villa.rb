class Villa < ApplicationRecord
  has_many :villa_schedules, dependent: :destroy
end
