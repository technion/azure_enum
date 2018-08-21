require "azure_enum/version"
require "erb"
require "httpclient"
require "nokogiri"

# Azure and Exchange federated domain enumerator
module AzureEnum
  # Class initializes with a domain name, and provides methods to interact with MS Autodiscover
  class Federation
    def initialize(domain)
      @domain = domain
      @xml_text = nil
      @redirect = nil
    end

    # This will identify if the http:// redirect exists for the domain, usually per Office 365
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
        "https://autodiscover.#{@domain}/autodiscover/autodiscover.svc",
        "https://#{@domain}/autodiscover/autodiscover.svc"
      ]

      httpsdomains.unshift @redirect if @redirect
      httpsdomains.each do |url|
        xml = get_xml(@domain, url)
        begin
          http = HTTPClient.new
          content = { "Content-Type" => "text/xml; charset=utf-8" }
          res = http.post(url, xml, content)
          @xml_text = res.content
          return true
          # It is bad style to rescue "all" errors. However, it turns out there is a practically
          # never ending list of ways this can fail. And "any" failure is reason to rule out the address
        rescue
          next
        end
      end
      return false
    end

    def getdomains
      raise "enumumerate_autodisc not called yet" unless @xml_text
      tree = Nokogiri.parse(@xml_text)
      tree.xpath(
        "//ad:GetFederationInformationResponseMessage/ad:Response/ad:Domains/ad:Domain",
        ad: "http://schemas.microsoft.com/exchange/2010/Autodiscover"
      ).map(&:text)
    end

    private

    # This is an internal class just to pass the correct structure to ERB in get_xml
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
      path = File.dirname __dir__
      template = File.read(File.join(path, "discovery.xml.erb"))
      renderer = ERB.new(template)
      discovery = Discovery.new(domain, url)
      renderer.result(discovery.get_binding)
    end
  end

  # This is the intended API: runs each step of the enumeration process and returns a result
  class << self
    def federated(domain)
      e = Federation.new(domain)
      e.check_redirect
      if e.enumerate_autodisc
        e.getdomains
      else
        nil
      end
    end
  end
end
