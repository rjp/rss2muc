require 'yaml'
require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'gdbm'
require 'sha1'
require 'time'
require 'simple-ordered-list'
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'

feedfile = ARGV[0] || 'feeds.yml'

feeds = YAML.load_file(feedfile)
articles = GDBM.new('read.db')

pq = Queue::Priority.new()

joined = false
cl = Jabber::Client.new(Jabber::JID.new(ARGV[1]))
cl.connect
cl.auth(ARGV[2])
m = Jabber::MUC::SimpleMUCClient.new(cl)

m.on_join { |time,nick|
    joined = true
}

m.join(ARGV[3])

start = Time.now.to_i + 10
feeds.each { |feed_info|
    pq.push(feed_info, start)
    start = start + 10
}

# move this out of the loop so we can thread synchronise it
new_entries = []

rss = Thread.new { 
    puts "RSS producer alive"
# TODO use a priority queue based on the time of next update for each URL
loop {
    now = Time.now.to_i
    feed_info, timestamp = pq.lowest(true)
    puts "= next: #{feed_info['name']}, at: #{Time.at(timestamp)}"
    if timestamp > now then
        puts "= sleeping for #{timestamp-now} for #{feed_info['name']}"
        sleep timestamp - now
    end
    p feed_info, timestamp
    next_timestamp = timestamp + feed_info['refresh']
    feed_url = feed_info['url']
    seen_feed = articles[feed_url].to_i
    if seen_feed == 0 then puts "= ignoring first run: #{feed_url}"; end
    feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)
	feed.entries.each { |f|
        # do we care if the title changes?
        sha1 = SHA1.hexdigest(f.title + f.url)
        if articles[sha1] then
#            puts "r #{f.title}"
        elsif seen_feed == 0 then
            puts "! #{f.title}"
        else
            puts "+ #{f.title}"
            new_entries.push [f.title, f.url, feed_info['name']]
        end
        articles[sha1] = now.to_s
	}
    articles[feed_url] = now.to_s
    puts "= queued: #{feed_info['name']} at #{Time.at(next_timestamp)}"
    pq.push(feed_info, next_timestamp)
}
}

muc = Thread.new {
    puts "MUC consumer alive"
    loop {
        if new_entries.size > 0 then
            entry = new_entries.shift
            puts "- #{entry[0]}"
            if joined then
                t = "#{entry[2]}: #{entry[0]}\n#{entry[1]}"
                m.say(t)
            end
            sleep 5
        else
            sleep 60
        end
    }
}

rss.join
muc.join
