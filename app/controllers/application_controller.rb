class ApplicationController < ActionController::Base
  protect_from_forgery
  $online_users ||= []
end
