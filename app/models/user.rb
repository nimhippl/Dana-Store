class User < ApplicationRecord
  acts_as_paranoid
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:telegram_chat_id]

  validates :telegram_chat_id, presence: true, uniqueness: true
  validates :username, presence: true

  has_many :users_roles
  has_many :roles, through: :users_roles
  has_many :orders, dependent: :destroy

  scope :with_role, -> (role_name) { joins(:roles).where(roles: { name: role_name }) }

  enum status: { pending: 0, active: 1, archived: 2 }

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  def total_deposit
    deposit || 0.0
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    telegram_chat_id = conditions.delete(:telegram_chat_id)
    where(conditions).where(["telegram_chat_id = :value", { value: telegram_chat_id }]).first
  end
end
