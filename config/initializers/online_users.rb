class OnlineUsers
  def self.users
    @@users ||= []
  end
  
  def self.add element
    if @@users
      @@users << element
    else
      @@users = [element]
    end
  end
  
  def self.remove element
    if @@users.include? element
      @@users.delete element
    end
  end
end