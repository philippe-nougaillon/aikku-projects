require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://projects.aikku.eu'
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.create do
  add '/about'
end
