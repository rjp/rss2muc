require 'rubygems'
require 'feed-normalizer'
require 'open-uri'

feed = FeedNormalizer::FeedNormalizer.parse open('frontpage.xml')
feed.entries.each { |f|
    puts f.title
}
