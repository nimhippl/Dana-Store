class Product < ApplicationRecord
  acts_as_paranoid
  has_one_attached :image
  belongs_to :category

  validates :name, presence: true
  validates :price, presence: true
  validates :quantity, presence: true

  scope :available, -> { where("quantity > 0") }

  def decrement_quantity!(amount)
    if quantity >= amount
      update!(quantity: quantity - amount)
    else
      raise "Недостаток количества"
    end
  end

end
