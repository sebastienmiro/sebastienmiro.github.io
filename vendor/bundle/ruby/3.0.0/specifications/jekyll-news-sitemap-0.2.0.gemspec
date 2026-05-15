# -*- encoding: utf-8 -*-
# stub: jekyll-news-sitemap 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-news-sitemap".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://www.github.com/skatkov/jekyll-news-sitemap/CHANGELOG.md", "homepage_uri" => "https://www.fbamonthly.com/jekyll-news-sitemap", "source_code_uri" => "https://www.github.com/skatkov/jekyll-news-sitemap" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stanislav Katkov".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-04-08"
  s.description = "Your friendly gem to produce Google News sitemap compatible xml file.".freeze
  s.email = ["sk@skylup.com".freeze]
  s.homepage = "https://www.fbamonthly.com/jekyll-news-sitemap".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.33".freeze
  s.summary = "Jekyll gem for Google News sitemap".freeze

  s.installed_by_version = "3.2.33" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<jekyll>.freeze, [">= 3.7", "< 5.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<jekyll>.freeze, [">= 3.7", "< 5.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
