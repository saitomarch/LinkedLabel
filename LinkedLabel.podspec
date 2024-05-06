Pod::Spec.new do |spec|
  spec.name         = "LinkedLabel"
  spec.version      = "0.0.1"
  spec.summary      = "LinkedLabel(PFLinkedLabel) is a subclass of UILabel which supports hyperlinks."
  spec.homepage     = "https://github.com/saitomarch/LinkedLabel"
  spec.license      = "Apache License, Version 2.0"
  spec.author             = { "SAITO Tomomi" => "t-saito@project-flora.net" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://github.com/saitomarch/LinkedLabel.git", :tag => "v#{spec.version}" }
  spec.swift_versions = "5.0"
  spec.source_files  = "LinkedLabel", "LinkedLabel/**/*.{h,m,swift}"
  spec.public_header_files = "LinkedLabel/**/*.h"
end
