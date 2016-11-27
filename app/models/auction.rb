class Auction < ActiveRecord::Base
  #attr_accessible :item_id, :max_bid, :user_id, :item, :picture, :user_notification, :id, :user, :auction_status, :lead_time, :to_add
  belongs_to :user
  validates_uniqueness_of :item_id, :scope => :user_id, :message => "has already been added.", :on => :create
  validates_presence_of :max_bid, :message => "must be entered."
  validates_presence_of :item_id, :message => "must be entered."
  validates_inclusion_of :lead_time, :in => 0..3, :allow_blank => true, :message => "can only be between 0 and 3 seconds."
  validates_presence_of :user
  before_destroy :remove_auction
  
  validate :prepare, :on => :create
  validate :user_has_phone_if_notify, :on => :create
  
  serialize :picture, Array
  
  # If the user specifies that they want to be notified on updates, but didn't provide a number, raise error.
  def user_has_phone_if_notify
    if user_notification != "Do not notify" && (user.phone_number == "" || user.phone_number == nil)
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

  attr_accessor :to_add
  
  def prepare
    # Parse the eBay item URL for the item's ID, then get the item's info
    self.item_id = self.parse_url_for_item_id
    
    return false if not self.user
    
    if self.auction_status == "Active" || self.auction_status == nil
      self.item = EbayAction.new(self.user).get_item(self.item_id, nil)
    end

    # If the auction is real
    if self.item[:get_item_response][:ack] == "Success"
      self.find_status

      # Load the listing's pictures. If the item's seller didn't include a picture, load ebay's
      # default picture. Else, check if there are multiple pictures. If true, push them all into the
      # pictures array. If there's only one picture, then push that in.
      self.picture = []
      if self.item[:get_item_response][:item][:picture_details][:photo_display] == "None"
        self.picture.push "http://p.ebaystatic.com/aw/pics/nextGenVit/imgNoImg.gif"
      else
        pictures = self.item[:get_item_response][:item][:picture_details][:picture_url]
        if pictures.respond_to?(:each)
          pictures.each do |pic|
            self.picture.push pic.to_s
          end
        else
          self.picture.push pictures.to_s
        end
      end
    else  
      # eBay sent back a "Failure" ack, meaning the auction does not exist.
      errors.add :item_id, "does not exist. Please try adding the auction's Item ID or URL."
    end
  end

  def self.prepare_multiple(auctions_to_prepare, current_user)
    auctions = []
    auctions_to_prepare.reject! { |a| a[:to_add] != "1" }
    
    auctions_to_prepare.each do |auction|
      auctions << Auction.new(auction)
    end

    auctions_to_delete = []

    puts auctions.inspect
    auctions.each_with_index do |auction, index|
      auction.user = current_user
      if auction.save
        auction.enqueue_job
        auctions_to_delete << auction
      end
    end

    return auctions - auctions_to_delete
  end
  
  def enqueue_job
    # If the auction is still going, enqueue an AuctionBidder worker to bid on the auction
    if self.auction_status == "Active"
      Resque.enqueue_in(self.get_enqueue_time.seconds, AuctionBidder, self.id) # If doesn't work, use enqueue_at and seconds.from_now
    end
  end
  
  def remove_auction
    Resque.remove_delayed(AuctionBidder, self.id)
    self.update_attributes :auction_status => "Deleted"
  end
  
  def restore_auction
    self.auction_status = 'Active' # So find_status won't ignore it.
    self.update_auction
    self.enqueue_job
  end

  def self.remove_multiple(auction_ids)
    if auction_ids
      auctions = Auction.find(auction_ids)
      auctions.each(&:remove_auction)
    end
  end

  def self.restore_multiple(auction_ids)
    if auction_ids
      auctions = Auction.find(auction_ids)
      auctions.each do |auction|
        auction.update_attributes :auction_status => 'Active'
        Resque.enqueue(AuctionUpdater, auction.id)
      end
    end
  end
  
  # Calculates the time remaining on the auction minus 5 minutes
  def get_enqueue_time
    return Time.parse(self.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - 300 
  end
  
  # Extracts the item_id from the URL if the entry is not only digits. Otherwise, the entry is just returned.
  def parse_url_for_item_id
    return nil if not self.item_id 
    if self.item_id.match(/\D+/).to_s.length != 0
      self.item_id.match(/item=\d+\D/).to_s.gsub!(/\D+/, "") ||
      self.item_id.match(/-\/\d+/).to_s.gsub!(/\D+/, "")
    else
      return self.item_id
    end
  end

  def update_auction
    if self.auction_status == "Active"
      self.item = EbayAction.new(self.user).get_item(self.item_id, nil)
      self.find_status
      self.save
    end
  end
  
  # Finds the current status of the auction (active, won, lost, etc)
  def find_status
    message = ""
    # If the auction is over, check if we won or lost
    if self.item[:get_item_response][:item][:time_left] == "PT0S" && self.auction_status != "Deleted"
      begin
        if self.item[:get_item_response][:item][:selling_status][:high_bidder][:user_id] == self.user.username
          self.auction_status = "Won"
          message = "Congratulations! You won the auction for \"#{self.item[:get_item_response][:item][:title][0,113]}\"! :)"
        else
          self.auction_status = "Lost"
          message = "Sorry, but you have lost the auction for \"#{self.item[:get_item_response][:item][:title][0,113]}\". :("
        end
      rescue
        # There was no high_bidder, which means no one bid.
        self.auction_status = "Lost"
        message = "Sorry, but you have lost the auction for \"#{self.item[:get_item_response][:item][:title][0,113]}\". :("
      end
      
      # Send out the notification of win/loss if the user wants it and hasn't been notified yet.
      if self.user_notification == "Text Message" && self.been_notified.to_s.split(",")[0] != self.id &&
      self.been_notified.to_s.split(",")[1] != self.auction_status.downcase
        Resque.enqueue(NotificationSender, self.id, message)
        self.been_notified = self.id.to_s + ",#{self.auction_status.downcase}"
      end
    elsif self.auction_status != "Deleted"
      self.auction_status = "Active"
    end
  end
  
  # Returns the appropriate auctions based on the user's selected auction status preference.
  def self.sort_auctions(current_user)
    auctions = []
    # If the status == "Ended" return all Won, Lost, and Ended
    if current_user.preferred_status == "Ended"
      auctions = current_user.auctions.where(:auction_status => %w[Won Lost])
    elsif %w[Won Lost Active Deleted].include? current_user.preferred_status
      # Just match the status
      auctions = current_user.auctions.where(:auction_status => current_user.preferred_status)
    else
      auctions = current_user.auctions.where(:auction_status => %w[Active Won Lost])
    end
    if current_user.preferred_sort == "title_asc" || current_user.preferred_sort == nil || current_user.preferred_sort == ""
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:title]] }
    elsif current_user.preferred_sort == "max_bid_asc"
      auctions = auctions.sort_by { |a| [a[:max_bid],
                                         a.item[:get_item_response][:item][:title]] }
    elsif current_user.preferred_sort == "price_asc"
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:selling_status][:converted_current_price],
                                         a.item[:get_item_response][:item][:title]] }
    elsif current_user.preferred_sort == "title_desc"
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:title]] }.reverse
    elsif current_user.preferred_sort == "max_bid_desc"
      auctions = auctions.sort_by { |a| [-a[:max_bid],
                                         a.item[:get_item_response][:item][:title]] }
    elsif current_user.preferred_sort == "price_desc"
      auctions = auctions.sort_by { |a| [-a.item[:get_item_response][:item][:selling_status][:converted_current_price].to_f,
                                         a.item[:get_item_response][:item][:title]] }
    elsif current_user.preferred_sort == "time_desc"
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:listing_details][:end_time],
                                         a.item[:get_item_response][:item][:title]] }.reverse
    else
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:listing_details][:end_time],
                                         a.item[:get_item_response][:item][:title]] }
    end
  end
  
end