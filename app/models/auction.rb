class Auction < ActiveRecord::Base
  attr_accessible :item_id, :max_bid, :user_id, :item
  belongs_to :user
  
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
