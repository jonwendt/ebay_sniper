class ProcessCgEntryPage
  @queue = :cgpg

  def self.perform(link, location, category)
    mechanize = Mechanize.new { |agent| agent.user_agent = 'Mac Safari' }
    result_page = mechanize.get(link)
    new_emails = result_page.body.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).map { |v| v.downcase.strip }.uniq
    puts "Inserting new emails from page #{link} with: #{new_emails.join(', ')}"
  end
  
end