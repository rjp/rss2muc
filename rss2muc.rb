require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'sqlite3'

feeds = []

db = SQLite3::Database.new('feeds.db')
db.execute('select url from feeds') { |f|
    feeds.push f[0]
}

feeds.each { |feed_url|
    feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)
	feed.entries.each { |f|
	    puts f.title
	}
}
