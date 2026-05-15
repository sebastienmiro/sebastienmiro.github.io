# frozen_string_literal: true

source "https://rubygems.org"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]

gem "jekyll-paginate"
gem "jekyll-sitemap"
gem "jekyll-seo-tag"
gem "jekyll-news-sitemap"
gem "jekyll-minifier"

gem "sass-embedded", "~> 1.69.0"

gemspec
