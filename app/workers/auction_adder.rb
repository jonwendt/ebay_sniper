class AuctionAdder
  @queue = :auction_adder
  require 'rake'
  
  def self.perform
    Rake::Task['db:seed'].invoke
  end
end

