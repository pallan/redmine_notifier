require "redmine_notifier/version"
require 'feedzirra'
require 'optparse'
require 'optparse/time'

module RedmineNotifier

  class Command
    attr_accessor :options

    def initialize(*args)
      @options = {}
      parse_argv(*args)
    end

    def call
      primed = false
      feed = Feedzirra::Feed.fetch_and_parse(@url)

      begin
        sleep(options[:delay]) if primed
        puts "#{Time.now} - Checking feed #{@url}..."
        if !primed || feed.updated?
          entries = primed ? feed.new_entries : feed.entries.select {|e| e.published >= options[:start_at] }
          entries.each do |entry|
            `terminal-notifier -group 'redmine-notifier' -title "#{entry.title.gsub('"', '\"')}" -subtitle "#{entry.published.localtime.strftime('%a, %b %e, %Y %l:%M%P')}" -message "#{entry.author}" -open "#{entry.url}"`
            sleep(2)
          end
          feed = Feedzirra::Feed.update(feed) unless primed
          primed = true
        end
      end until options[:delay] == 0
    end

    private

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: redmine-notifier [OPTIONS] ACTIVITY_ATOM_URL"
        opts.on('-d', '--delay N', Integer, 'Delay N seconds between requests, default is 0 or a single request')  { |m| options[:delay] = m }
        opts.on('-S', '--start TIME', Time, 'At start show updates newer than TIME' ) {|t| options[:start_at] = t }
        opts.on('-h', '--help', 'Display this screen' ) do
          puts opts
          exit 0
        end
      end.parse!(args)

      options[:delay] ||= 0
      options[:start_at] ||= Time.now
      @url = args.pop
    end

  end
end
