# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ebay = EbayAction.new

ebay.add_item( { "Title" => "Harry Potter", "Description" => "Test", "PrimaryCategory" => { "CategoryID" => "377" }, "StartPrice" => "1", "ConditionID" => "3000", "Currency" => "USD", "Country" => "US", "ListingDuration" => "Days_1", "Location" => "US", "PaymentMethods" => "PayPal", "PayPalEmailAddress" => "test@test.com", "DispatchTimeMax" => "3", "ShippingDetails" => { "ShippingType" => "Flat", "ShippingServiceOptions" => { "ShippingServicePriority" => "1", "ShippingService" => "USPSMedia", "ShippingServiceCost" => "2.50" } } } )