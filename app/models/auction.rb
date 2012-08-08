class Auction < ActiveRecord::Base
  attr_accessible :item_id, :max_bid, :user_id, :item, :picture, :user_notification, :id, :user, :auction_status, :lead_time
  belongs_to :user
  validates_uniqueness_of :item_id, :scope => :user_id, :message => "has already been added.", :on => :create#, :unless => :auction_deleted?
  validates_presence_of :max_bid, :message => "must be entered."
  validates_presence_of :item_id, :message => "must be entered."
  validates_presence_of :user
  
  validate :auction_exists?, :on => :save
  validate :user_has_phone_if_notify
  
  serialize :picture, Array
  validate :prepare
  
  def auction_exists?
    if item[:get_item_response][:ack] != "Success"
      errors.add :item_id, "does not exist. Please try adding the auction's Item ID or URL."
    end
  end
  
  # If the user specifies that they want to be notified on updates, but didn't provide a number, raise error.
  def user_has_phone_if_notify
    if user_notification != "Do not notify" && user.phone_number == ""
      errors.add :user_notification, "requires that you provide a phone number under the \"Edit Account\" page."
    end
  end
  
  def item=(value)
    super(Marshal.dump(value))
  end
  
  def item
    if super
      Marshal.load(super)
    else
      nil
    end
  end
  
  def prepare
    # Parse the eBay item URL for the item's ID, then get the item's info
    self.item_id = parse_url_for_item_id(self.item_id)
    self.item = EbayAction.new(self.user).get_item(self.item_id, "")

    # If the self is real
    if self.item[:get_item_response][:ack] == "Success"
      find_status(self)

      # Load the listing's pictures. If the item's seller didn't include a picture, load ebay's
      # default picture. Else, check if there are multiple pictures. If true, push them all into the
      # pictures array. If there's only one picture, then push that in.
      if self.item[:get_item_response][:item][:picture_details][:photo_display] == "None"
        self.picture.push "http://p.ebaystatic.com/aw/pics/nextGenVit/imgNoImg.gif"
      else
        @pictures = self.item[:get_item_response][:item][:picture_details][:picture_url]
        if @pictures.respond_to?(:each)
          @pictures.each do |picture|
            self.picture.push picture.to_s
          end
        else
          self.picture.push @pictures.to_s
        end
      end
    else  
      # The self does not exist. (For now, I'm just grabbing an item that I know exists. Fix with validation.)
      # self.item = EbayAction.new(self.user).get_item("110101276115", "")
      self.item = nil
      errors.add :item_id, "does not exist. Please try adding the auction's Item ID or URL."
    end
  end
  
  def enqueue_job(auction)
    # If the auction is still going, enqueue an AuctionBidder worker to bid on the auction
    if auction.auction_status == "Active"
      Resque.enqueue_at(get_enqueue_time(auction.item[:get_item_response][:item][:listing_details][:end_time],
                        auction.lead_time).seconds.from_now, AuctionBidder, auction.id)
    end
  end

  def update_auction(auction)
    if auction.auction_status == "Active"
      # Sadly, this doesn't work because of the nested hashes.
      # auction.item.merge! EbayAction.new.get_item(auction.item_id, "timeleft,bidcount,currentprice,userid")
      
      # Figure out how to update while only grabbing values needed
      @new_auction = EbayAction.new(auction.user).get_item(auction.item_id, "")
      auction.item = auction.item.merge @new_auction
      find_status(auction)
      auction.save
    end
  end
  
  # Returns the appropriate auctions based on the user's selected auction status preference.
  def self.sort_auctions(status, current_user)
    @auctions = []
    # If the status == "Ended" return all Won, Lost, and Ended
    if status == "Ended"
      status = %w[Won Lost Ended]
      current_user.auctions.each do |auction|
        if status.include? auction.auction_status
          @auctions.push auction
        end
      end
    elsif status == nil || status == "All"
      current_user.auctions.each do |auction|
        if auction.auction_status != "Deleted"
          @auctions.push auction
        end
      end
    else  
      # Else, just match the status
      current_user.auctions.each do |auction|
        if auction.auction_status == status.to_s
          @auctions.push auction
        end
      end
    end
    @auctions
  end
  
  # Calculates the time remaining on the auction minus 5 minutes
  def get_enqueue_time(auction_end_time, lead_time)
    auction_end_time = Time.parse(auction_end_time).localtime
    return auction_end_time - Time.now - 300
  end
  
  # Extracts the item_id from the URL if the entry is not only digits. Otherwise, the entry is just returned.
  def parse_url_for_item_id(url)
    if url.match(/\D*/).to_s.length != 0
      @item_id = url.match(/item=\d*\D/).to_s.gsub!(/\D+/, "")
    else
      url
    end
  end
  
  # Finds the current status of the auction (active, won, lost, etc)
  def find_status(auction)
    # If the auction is over, check if we won or lost
    if auction.item[:get_item_response][:item][:time_left] == "PT0S"
      begin
        if auction.item[:get_item_response][:item][:selling_status][:high_bidder][:user_id] == auction.user.username
          auction.auction_status = "Won"
        else
          auction.auction_status = "Lost"
        end
      rescue
        # There was no high_bidder, which means no one bid.
        auction.auction_status = "Lost"
      end
    else
      auction.auction_status = "Active"
    end
  end
  
end