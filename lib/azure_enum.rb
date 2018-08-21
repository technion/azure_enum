require "azure_enum/version"
require 'erb'
require 'httpclient'
require 'nokogiri'

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
          return
        rescue
          next
        end
      end
    end

    def xml_pretty
      xsl =<<XSL
  <xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="*"/>
  <xsl:template match="/">
    <xsl:copy-of select="."/>
  </xsl:template>

  </xsl:stylesheet>
XSL

      doc = Nokogiri::XML(@xml_text)
      xslt = Nokogiri::XSLT(xsl)
      out = xslt.transform(doc)
      out.to_xml
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
      f = Federation.new(domain)
      f.check_redirect
      f.enumerate_autodisc
      puts f.xml_pretty
    end
  end
end
