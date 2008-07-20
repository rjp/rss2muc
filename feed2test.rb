require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'sqlite3'
require 'sha1'

feeds = []

db = SQLite3::Database.new('test.db')

feed = FeedNormalizer::FeedNormalizer.parse open(ARGV[0])

counter = 1
db.transaction {
    feed.entries.each { |f|
        db.execute("INSERT INTO testfeed VALUES (?,?,?,?,?,?)",
                counter, f.content, f.description, f.title,
                f.date_published, f.url
        )
        counter = counter + 1
    }
}

db.close
