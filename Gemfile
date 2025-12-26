# frozen_string_literal: true

source "https://rubygems.org"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
  gem "wdm", "~> 0.1"
end

# Charge le thème Beautiful Jekyll via son gemspec
gemspec

# On force la version de Jekyll pour éviter Jekyll 4 et http_parser.rb
gem "jekyll", "~> 3.9.3"

# Plugins Jekyll supplémentaires de TON site
gem "jekyll-seo-tag"
gem "jekyll-news-sitemap"
gem "jekyll-minifier"
