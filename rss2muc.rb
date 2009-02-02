require 'yaml'
require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'gdbm'
require 'sha1'
require 'time'
require 'simple-ordered-list'

feeds = YAML.load_file('feeds.yml')
articles = GDBM.new('read.db')

pq = Queue::Priority.new()

start = Time.now.to_i + 10
feeds.each { |feed_info|
    pq.push(feed_info, start)
    start = start + 10
}

# TODO use a priority queue based on the time of next update for each URL
loop {
    now = Time.now.to_i
    feed_info, timestamp = pq.lowest(true)
    if timestamp > now then
        sleep timestamp - now
    end
    p feed_info, timestamp
    next_timestamp = timestamp + feed_info['refresh']
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
    puts "will check #{feed_info['name']} again at #{Time.at(next_timestamp)}"
    pq.push(feed_info, next_timestamp)
    p new_entries
}
