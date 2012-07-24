class EbayAction
  
  def initialize
    @client ||= Savon::Client.new do
      wsdl.endpoint = "https://api.sandbox.ebay.com/wsapi?siteid=0&routing=beta&callname=GeteBayOfficialTime&version=423&appid=Leviona4d-c40e-454f-9d49-dd510693f96"
      wsdl.namespace = "urn:ebay:apis:eBLBaseComponents"
    end
  end
  
  def time
    response = self.request :endpoint => "GeteBayOfficialTime"
    Time.parse(response.body[:gete_bay_official_time_response][:timestamp])
  end
  
  def ebay_and_local_time
    puts self.time.localtime.to_f
    puts Time.now.to_f
  end
  
  def measure_time_diff
    result_time = nil
    benchmark_time = Benchmark::measure {
      result_time = (Time.now.to_f - self.time.to_f)
    }
    result_time = (result_time - benchmark_time.real)
  end
  
  def request(values={})
    values[:body] ||= {}
    values[:header] ||= {}

    response = @client.request "#{values[:endpoint]}Request" do
      soap.endpoint = "https://api.sandbox.ebay.com/wsapi?siteid=0&routing=beta&callname=" + values[:endpoint] + "&version=423&appid=Leviona4d-c40e-454f-9d49-dd510693f96"
      soap.body = { "Version" => "423" }
      soap.input = "#{values[:endpoint]}Request", { "xmlns" => "urn:ebay:apis:eBLBaseComponents" }
      soap.header = { "ebl:RequesterCredentials" => { "ebl:eBayAuthToken" => "AgAAAA**AQAAAA**aAAAAA**n8gNUA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhCZGGqQqdj6x9nY+seQ**194BAA**AAMAAA**RKYUL774WkhrRJGrHi1wS+VHDL2lOxG+Hoi9xx7Mm7jdbrh5BRv2UC93JN3Msn2EdwmnqhDwF2qxKFJYtY38YMMqKfpp+/GVB+WAta570T+LlCO5kKitdVTOal6EBhQRiMiKU9t7vGhTsi+ByQrShFpjH4Re3X6bQXNOGTjeWb1G+RdYOuH9NMELf7mVs6CBmWmhOdCuRow+Ekb/yVbGe1ZUfBcl55wYGI4AefPJTqoHgZuDEThrTeRs7TGFd3RaH5Cct+nMQrZRBEpUVeraUYEwCEct04qaRyfLm/EA4fvJcxp1znRr3BwGNwEam4OFeioQA4/bJMgmqU5eA8Unj8g7lLhYo2kWkspAG4aU5RkoFbMYctUDS2kSlQ3VtHJgmPwAHJVcPsWg2SO0B6Z+/SoPyToXiTFfNRSvgZXjxbzHmzringmRQ4yMwGdxDkD8rjFzTJTTCune42QH9WIqpjNPFwx+K3Y+V4qkPc2Q2b6VXQE/VOae0d5/4FrSQ8PMZB6SAbWSD/MfiX5ofpruOAHUGBG/9zpGXbPeESel2Jvv4DYpkRf0CLRiOAXrgW3PP1D1AnbHaVAR7PC/L9Lm0/BjJbWVlhKbaJyq/LIlv1JLwn4HInbWiR9XuXUGXshAGS+gZnGmzgNbAFllwT75opRiFdm2E1q4mOAntc9+1uviAYc5CxMs3igohPNut0JYdKDyQQyrGBOizIb1yM8kQRwfYiGRiTlyq/xrmkcjlK0+qM1dyFoaYaXvVQrh/sDc" }, :attributes! => { "ebl:RequesterCredentials" => { "xmlns:ebl" => "urn:ebay:apis:eBLBaseComponents"} } }

      values.keys.each do |key|
        if soap.send(key).is_a?(Hash)
          soap.send("#{key}=", soap.send(key).merge(values[key]))
        end
      end
 
    end
  end
  
end