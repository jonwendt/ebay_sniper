class Auction < ActiveRecord::Base
  attr_accessible :item_id, :max_bid, :user_id, :item, :picture, :user_notification, :id
  belongs_to :user
  validates_uniqueness_of :item_id, :scope => :user_id, :message => "This auction has already been added."
  validates_presence_of :max_bid, :message => "You must enter a max bid."
  
  serialize :picture, Array
  
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
  
end