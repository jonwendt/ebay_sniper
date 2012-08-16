require 'devise/strategies/base'
require 'devise'

module Devise
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists. Must be called *before*
    # authenticatable.
    class EbayAuthenticatable < Authenticatable
      
      def valid?
        if params and params.is_a?(Hash) and params[:user] and params[:user].is_a?(Hash) and params[:user][:email] and not (params[:user][:email].to_s =~ /@/)
          params_authenticatable? && valid_params_request? &&
                    valid_params? && with_authentication_hash(:params_auth, params_auth_hash)
          return true
        else
          return false
        end
      end
      
      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!        
        resource = mapping.to.where(:username => authentication_hash[:email]).first if authentication_hash
        resource ||= mapping.to.new if resource.nil?
        
        username = authenticate_against_ebay(authentication_hash[:email], password)
        
        if username
         resource.username = username
         resource.password = password
         resource.password_confirmation = password
         resource.save if resource.changed?
        end

        return fail(:invalid) unless username and resource

        if validate(resource) { not resource.nil? }
          success!(resource)
        end
      end
      
      def authenticate_against_ebay(username, password)
        m = Mechanize.new
        lp = m.get "https://signin.sandbox.ebay.com/ws/eBayISAPI.dll?SignIn"
        f = lp.form_with(:name => "SignInForm")
        f.field_with(:name => "userid").value = username
        f.field_with(:name => "pass").value = password
        np = f.submit

        if np.body =~ /password is incorrect/
          return false
        end

        myebay = m.get "http://my.sandbox.ebay.com/ws/eBayISAPI.dll?MyeBay"
        return myebay.search("[class='mbg-nw']").text
      end
      
      private

      def decorate(resource)
        super
        # resource.extend_remember_period = mapping.to.extend_remember_period if resource.respond_to?(:extend_remember_period=)
      end

    end
  end
end

module Devise
  module Models
    module EbayAuthenticatable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
      end
    end


    module Validatable
      # All validations used by this module.
      # VALIDATIONS = [ :validates_presence_of, :validates_uniqueness_of, :validates_format_of,
      # :validates_confirmation_of, :validates_length_of ].freeze

      def self.included(base)
        base.extend ClassMethods
        assert_validations_api!(base)

        base.class_eval do
          validates_presence_of   :email, :if => :email_required?
          validates_uniqueness_of :email, :case_sensitive => (case_insensitive_keys != false), :allow_blank => false, :if => :email_changed?
          validates_format_of     :email, :with => email_regexp, :allow_blank => false, :if => :email_changed?

          validates_presence_of     :password, :if => :password_required?
          validates_confirmation_of :password, :if => :password_required?
          validates_length_of       :password, :within => password_length, :allow_blank => true
        end
      end
    end
  end
end

Warden::Strategies.add(:ebay_authenticatable, Devise::Strategies::EbayAuthenticatable)
Devise.add_module(:ebay_authenticatable,
  :strategy => true,
  :model => "app/models/user.rb")

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :ebay_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :auth_token, :username, :phone_number, :id, :preferred_status, :preferred_sort
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
  
  def email_required?
    return false
  end
end