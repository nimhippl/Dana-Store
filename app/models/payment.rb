class Payment < ApplicationRecord
  belongs_to :order
  has_one :user, through: :order

  enum state: { unpaid: 0, paid: 1 }
end
