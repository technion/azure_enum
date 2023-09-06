
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "azure_enum/version"

Gem::Specification.new do |spec|
  spec.name          = "azure_enum"
  spec.version       = AzureEnum::VERSION
  spec.authors       = ["Technion"]
  spec.email         = ["technion@lolware.net"]

  spec.summary       = %q{Enumerate Office 365 tenancies for federated domains.}
  spec.description   = %q{External enumeration toolkit to identify organisation relationships in Office 365.}
  spec.homepage      = "https://github.com/technion/azure_enum"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency "httpclient", "~> 2.8.0"
  spec.add_dependency "nokogiri", "~> 1.15.4"
end
