require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'gdbm'
require 'sha1'

feeds = GDBM.new('feeds.db')
articles = GDBM.new('read.db')

feeds.keys.each { |feed_url|
    new_entries = []
    feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)
	feed.entries.each { |f|
        # do we care if the title changes?
        sha1 = SHA1.hexdigest(f.title + f.url)
        unless articles[sha1] then
            new_entries.push f.title + " " + sha1
        end
	}
    p new_entries
}
