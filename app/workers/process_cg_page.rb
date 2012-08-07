class ProcessCgPage
  @queue = :cg

  def self.perform(location, category, id=nil, url=nil)
    mechanize = Mechanize.new { |agent| agent.user_agent = 'Mac Safari' }
    cg_page = nil
    
    begin
      puts "Checking out page at " + (location.gsub(/\/$/, '') + category)
      if not url
        cg_page = mechanize.get(location.gsub(/\/$/, '').strip + category.strip)
      else
        cg_page = mechanize.get(url)
      end
    rescue Exception => e
      raise e
    end
    
    results = cg_page.search("blockquote/p/a").map { |v| v.attributes['href'].text }
      
    results.each do |result|
      Resque.enqueue ProcessCgEntryPage, result.to_s, location, category
    end
    
    next_page_link = cg_page.link_with(:text => "next 100 postings")
    
    if next_page_link
      puts "========== "
      puts "Getting next page at #{next_page_link.uri}"
      puts "========== "      
      Resque.enqueue ProcessCgPage, location, category, 0, mechanize.agent.resolve(next_page_link.uri, cg_page).to_s
    end
  end
  
end