class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :auth_token, :username, :phone_number, :id
  has_many :auctions, dependent: :destroy
  validates :phone_number, :allow_blank => true, :length => { :is => 12 }, :format => { :with => /^[+]\d+\z/,
    :message => "should include your country code. A US number would be +1##########." }
  validates_uniqueness_of :phone_number, :allow_blank => true, :message => "is already tied to an account."
  validate :auth_token_exp, :nil => false
  
  def self.currently_online
    online_ids = $redis.keys("ebaysniper:online_users:*").map { |v| v.gsub("ebaysniper:online_users:", "") }
    User.where(:id => online_ids)
  end
  
  def online?
    if self.id
      return $redis.get("ebaysniper:online_users:#{self.id}") == "1"
    end
    return false
  end
  
end