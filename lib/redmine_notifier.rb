require "redmine_notifier/version"
require 'feedzirra'
require 'optparse'
require 'optparse/time'
require 'yaml'

module RedmineNotifier

  class Command
    attr_accessor :options

    def initialize(*args)
      @options = load_options
      parse_argv(*args)
    end

    def call
      puts "#{Time.now} - Beginning notifier..."
      puts "#{Time.now} - Configuration: Update #{options[:delay]} seconds (0 means once)."
      puts "#{Time.now} - Configuration: URL: #{options[:url]}"
      puts "#{Time.now} - Configuration: Notify in updates Newer than: #{options[:start_at].localtime} (at start)"

      last_checked = options[:start_at]
      begin
        feed = Feedzirra::Feed.fetch_and_parse(options[:url])
        puts "#{Time.now} - Checking feed..."
        entries = feed.entries.select {|e| e.published >= last_checked }
        last_checked = Time.now
        puts "#{Time.now} - New Entries found: #{feed.new_entries.count}"
        puts "#{Time.now}    #{entries.map(&:id).join("\n    ")}"
        entries.each do |entry|
          `terminal-notifier -group 'redmine-notifier' -title "#{entry.title.gsub('"', '\"')}" -subtitle "#{entry.published.localtime.strftime('%a, %b %e, %Y %l:%M%P')}" -message "#{entry.author}" -open "#{entry.url}"`
          puts "#{Time.now}   - Sending notification for: #{entry.title} #{entry.published}"
          sleep(2)
        end
        write_options
        sleep(options[:delay])
      end until options[:delay] == 0
    end

    private

    def options_file_path
      File.expand_path('.redmine-notifier', '~')
    end

    def load_options
      File.exists?(options_file_path) ? YAML.load(File.read(options_file_path)) : {}
    end

    def write_options
      File.open(options_file_path, 'w+') do |f|
        f.write YAML.dump(options.merge(start_at: Time.now))
      end
    end

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

      # if the URL was loaded from the dotfile and none was supplied
      # we don't want to overwrite it - pa
      url = args.pop
      options[:url] = url unless url.nil?

      options[:delay]     ||= 0
      options[:start_at]  ||= Time.now
    end

  end
end
