class EbayAction

  def initialize(user)
    @user = user
    @client ||= Savon::Client.new do
      wsdl.endpoint = "https://api.sandbox.ebay.com/wsapi"
      wsdl.namespace = "urn:ebay:apis:eBLBaseComponents"
    end
  end

  def get_session_id
    runame = "Levion-Leviona4d-c40e--xkueiv"
    session_id = self.request :endpoint => "GetSessionID",
      :body => { "RuName" => runame, "MessageID" => @user.id },
    :header => { "ebl:RequesterCredentials" => { "ebl:Credentials" => {
                                                   "AppId" => "Leviona4d-c40e-454f-9d49-dd510693f96",
                                                   "DevId" => "55831621-5890-4bb6-8efb-83e22e4e731b",
                                                 "AuthCert" => "2a4a78d9-3e13-40c1-86eb-5606300231da" }
                                                 } }

    @user.session_id = session_id.body[:get_session_id_response][:session_id]
    @user.save
    consent_url = "https://signin.sandbox.ebay.com/ws/eBayISAPI.dll?SignIn&RuName=#{runame}" +
      "&SessID=#{session_id.body[:get_session_id_response][:session_id]}" +
      "&ruparams=user_id%3D#{session_id.body[:get_session_id_response][:correlation_id]}"
  end

  def fetch_token
    auth_token = self.request :endpoint => "FetchToken",
      :body => { "SessionID" => @user.session_id },
    :header => { "ebl:RequesterCredentials" => { "ebl:Credentials" => {
                                                   "AppId" => "Leviona4d-c40e-454f-9d49-dd510693f96",
                                                   "DevId" => "55831621-5890-4bb6-8efb-83e22e4e731b",
                                                 "AuthCert" => "2a4a78d9-3e13-40c1-86eb-5606300231da" }
                                                 } }
    @user.auth_token = auth_token.body[:fetch_token_response][:e_bay_auth_token]
    @user.auth_token_exp = auth_token.body[:fetch_token_response][:hard_expiration_time]
    @user.save
  end

  def ebay_time
    response = self.request :endpoint => "GeteBayOfficialTime"
    Time.parse(response.body[:gete_bay_official_time_response][:timestamp])
  end

  def add_item(item={})
    response = self.request :endpoint => "AddItem",
      :body => { "Item" => item }
  end

  # Separate output_selector with , and no spaces. Format like XML (ex: "timeleft,title")
  def get_item(item_id, output_selector)
    output_selector ||= "country,description,itemid,endtime,viewitemurl,bidcount,bidincrement,convertedcurrentprice," +
      "shippingservicecost,timeleft,title,picturedetails,userid,bidcount,hasreserveprice,convertedreserveprice"
    response = self.request :endpoint => "GetItem",
      :body => { "ItemID" => item_id, "DetailLevel" => "ItemReturnDescription",
                 "OutputSelector" => output_selector }
      response.body
  end

  def place_bid(item_id, amount)
    response = self.request :endpoint => "PlaceOffer",
      :body => { "ItemID" => item_id, "Offer" => { "Action" => "Bid", "MaxBid" => amount, "Quantity" => "1" }, "EndUserIP" => "127.0.0.1" }
  end

  def import
    response = self.request :endpoint => "GetMyeBayBuying", 
      :body => { "WatchList" => { "Include" => true } }

    auctions = []
    response.body[:get_mye_bay_buying_response][:watch_list][:item_array][:item].each do |key, value|
      begin
        auction = Auction.new
        auction.item_id = key[:item_id]

        if key[:selling_status][:converted_current_price]
          price = key[:selling_status][:converted_current_price]
        else
          price = key[:selling_status][:current_price]
        end

        auction.item = {
          :get_item_response => {
            :item => {
              :title => key[:title],
              :listing_details => { :end_time => key[:listing_details][:end_time], :view_item_url => key[:listing_details][:view_item_url] },
              :selling_status => { :converted_current_price => price },
              :picture_details => { :picture_url => get_item(auction.item_id, "pictureurl")[:get_item_response][:item][:picture_details][:picture_url] }
            }
          }
        }

        auctions.push auction
      rescue
        puts "Failed to import auction from #{key[:listing_details][:view_item_url]}"
      end
    end

    @user.auctions.each do |already_added_auction|
      auctions.delete_if { |imported_auction| imported_auction.item_id == already_added_auction.item_id }
    end

    return auctions
  end

  def request(values={})
    values[:body] ||= {}
    values[:header] ||= {}

    response = @client.request "#{values[:endpoint]}Request", user = @user do
      soap.endpoint = "https://api.sandbox.ebay.com/wsapi?siteid=0&routing=beta&callname=" + values[:endpoint] +
        "&version=783&appid=Leviona4d-c40e-454f-9d49-dd510693f96"
      soap.body = { :Version => "783" }
      soap.input = "#{values[:endpoint]}Request", { :xmlns => "urn:ebay:apis:eBLBaseComponents" }
      soap.header = { "ebl:RequesterCredentials" => { "ebl:eBayAuthToken" => user.auth_token,
                                                      "ebl:Credentials" => {
                                                        "AppId" => "Leviona4d-c40e-454f-9d49-dd510693f96",
                                                        "DevId" => "55831621-5890-4bb6-8efb-83e22e4e731b",
                                                      "AuthCert" => "2a4a78d9-3e13-40c1-86eb-5606300231da" }
                                                      },
                      :attributes! => { "ebl:RequesterCredentials" => { "xmlns:ebl" => "urn:ebay:apis:eBLBaseComponents"} } }

      values.keys.each do |key|
        if soap.send(key).is_a?(Hash)
          soap.send("#{key}=", soap.send(key).merge(values[key]))
        end
      end
    end
  end
end
