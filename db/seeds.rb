# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ebay = EbayAction.new(User.last)

response = ebay.add_item( { "Title" => "Harry Potter and the Something Something Something", "Description" => "This is a long description of the product. " * 30,
  "PrimaryCategory" => { "CategoryID" => "377" }, "StartPrice" => "1", "ConditionID" => "3000", "Currency" => "USD", "Country" => "US",
  "ListingDuration" => "Days_1", "Location" => "US", "PaymentMethods" => "PayPal", "PayPalEmailAddress" => "test@test.com",
  "PictureDetails" => { "PictureURL" => "http://www.levion.com/assets/themes/levion/images/IDN-silver-square-small.jpg" },
  "DispatchTimeMax" => "3", "ReturnPolicy" => { "ReturnsAcceptedOption" => "ReturnsAccepted", "RefundOption" => "MoneyBack",
  "ReturnsWithinOption" => "Days_30", "Description" => "Harry Potter book in bad condition", "ShippingCostPaidByOption" => "Buyer" },
  "ShippingDetails" => { "ShippingType" => "Flat", "ShippingServiceOptions" => { "ShippingServicePriority" => "1",
  "ShippingService" => "USPSMedia", "ShippingServiceCost" => "2.50" } } } )

# Adds the item to my user account
auction_id = Auction.last.id + 1
auction = Auction.new
auction.id = auction_id
auction.item_id = response.body[:add_item_response][:item_id].to_s
auction.user_id = User.first.id
auction.max_bid = 100
auction.save