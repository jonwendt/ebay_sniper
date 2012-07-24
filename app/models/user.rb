class User < ActiveRecord::Base
  attr_accessible :auth_token, :name
end
