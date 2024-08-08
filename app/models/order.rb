class Order < ApplicationRecord
  acts_as_paranoid
  belongs_to :product
  belongs_to :user
  has_many :payments, dependent: :destroy


  enum state: { unpaid: 0, paid: 1 }

  before_create :process_payment_from_deposit
  scope :by_payment_status, ->(status) { where(state: status) if status.present? }

    private

    def process_payment_from_deposit
      if user.deposit >= product.price
        user.update(deposit: user.deposit - product.price)
        self.state = 'paid'
      end
    end
end
