require "azure_enum/version"
require "erb"
require "httpclient"
require "nokogiri"

module AzureEnum
  class Federation
    def initialize(domain)
      @domain = domain
      @xml_text = nil
      @redirect = nil
    end

    def check_redirect
      url = "http://autodiscover.#{@domain}/autodiscover/autodiscover.svc"
      begin
        res = HTTPClient.head(url)
      rescue
        return nil
      end
      return nil unless res.status_code == 302
      @redirect = res.header["Location"][0]
    end

    def enumerate_autodisc
      httpsdomains = [
        "https://#{@domain}/autodiscover/autodiscover.svc",
        "https://autodiscover.#{@domain}/autodiscover/autodiscover.svc"
      ]

      httpsdomains.unshift @redirect if @redirect
      httpsdomains.each do |url|
        xml = get_xml(@domain, url)
        begin
          http = HTTPClient.new
          content = { "Content-Type" => "text/xml; charset=utf-8" }
          res = http.post(url, xml, content)
          @xml_text = res.content
          return @xml_text
          last
        rescue
          next
        end
      end
    end
    def getdomains
      fail "enumumerate_autodisc not called yet" unless @xml_text
       tree = Nokogiri.parse(@xml_text)
       tree.xpath(
         "//ad:GetFederationInformationResponseMessage/ad:Response/ad:Domains/ad:Domain",
         "ad": "http://schemas.microsoft.com/exchange/2010/Autodiscover")
         .map do |node|
            node.text
       end
    end

    private
    class Discovery
      def initialize(domain, url)
        @domain = domain
        @url = url
      end
      def get_binding
        binding
      end
    end
    def get_xml(domain, url)
      template = File.read("discovery.xml.erb")
      renderer = ERB.new(template)
      discovery = Discovery.new(domain, url)
      renderer.result(discovery.get_binding)
    end
  end
  class << self
    def federated(domain)
      e = Federation.new(domain)
      e.check_redirect
      e.enumerate_autodisc
      e.getdomains
    end
  end
end
