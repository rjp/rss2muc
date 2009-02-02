require 'yaml'
require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'gdbm'
require 'sha1'

feeds = YAML.load_file('feeds.yml')
articles = GDBM.new('read.db')

loop {
	feeds.each { |feed_info|
        feed_url = feed_info['url']
	    new_entries = []
	    feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)
		feed.entries.each { |f|
	        # do we care if the title changes?
	        sha1 = SHA1.hexdigest(f.title + f.url)
	        unless articles[sha1] then
	            new_entries.push f.title + " " + sha1
	            articles[sha1] = f.title
	        end
		}
	    p new_entries
	}
    sleep 60
}
