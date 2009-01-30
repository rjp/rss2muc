require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'gdbm'
require 'sha1'

feeds = GDBM.new('feeds.db')
articles = GDBM.new('read.db')

db = SQLite3::Database.new('feeds.db')

db.execute('select url, last from feeds') { |f|
    feeds.push [ f[0], f[1] ]
}

feeds.each { |feed_url, feed_last|
    new_entries = []
    feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)
	feed.entries.each { |f|
        sha1 = SHA1.hexdigest(f.title + f.url)
        unless articles[sha1] then
            new_entries.push f.title + " " + sha1
        end
	}
    p new_entries
}
