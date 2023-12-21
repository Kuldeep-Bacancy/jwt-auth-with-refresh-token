class User < ApplicationRecord
  require 'securerandom'
  include JsonWebToken

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  normalizes :email, with: ->(email) { email.strip.downcase } # normalizes email to downcase after update or create

  has_many :black_list_tokens, dependent: :destroy

  def generate_access_token
    jwt_encode({user_id: id, email:, first_name:, last_name: })
  end

  def generate_refresh_token
    new_token = jwt_encode({ user_id: id }, 7.days.from_now)
    self.update(refresh_token: new_token)
    new_token
  end
  
end
