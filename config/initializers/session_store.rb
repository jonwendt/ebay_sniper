# Be sure to restart your server when you modify this file.

EbaySniper::Application.config.session_store :redis_store, :expire_after => 86400, :redis_server => 'redis://127.0.0.1:6379/0/ebay_sniper:session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# EbaySniper::Application.config.session_store :active_record_store
