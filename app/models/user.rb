class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :auth_token, :name, :phone_number, :id
  validates :phone_number, :allow_blank => true, :length => { :is => 12 }, :format => { :with => /^[+]\d+\z/,
    :message => "should include your country code. A US number would be +1##########." }
  validates_uniqueness_of :phone_number, :allow_blank => true, :message => "is already tied to an account."
  has_many :auctions, dependent: :destroy
end