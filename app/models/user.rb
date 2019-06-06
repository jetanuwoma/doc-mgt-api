

class User < ApplicationRecord
  has_secure_password

  has_many :documents, dependent: :destroy
  has_many :comments, through: :documents, dependent: :destroy

  validates_presence_of :first_name, :last_name, :email, :role, :password_digest
  validates_uniqueness_of :email

  enum role: %w[member admin]
end
