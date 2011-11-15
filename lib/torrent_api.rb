require 'rubygems'

require 'fileutils'
require 'net/http'

require 'hpricot'
require 'open-uri'

require 'nokogiri'
require 'uri'

%w(result base result_set).each do |filename|
  require File.join(File.dirname(__FILE__), 'torrent_reactor', filename)
end
%w(result base categories details result_set).each do |filename|
  require File.join(File.dirname(__FILE__), 'pirate_bay', filename)
end
%w(result base result_set).each do |filename|
  require File.join(File.dirname(__FILE__), 'demonoid', filename)
end

class TorrentApi
  attr_accessor :service, :search_term, :results

  def initialize(service=:pirate_bay, search_term=nil)
    @service = service
    @search_term = search_term

    @results = search if @search_term
  end

  def search
    if @service == :all
      results = []
      results << PirateBay::Search.new(@search_term).execute
      results << Demonoid::Search.new(@search_term).execute
      results << TorrentReactor::Search.new(@search_term).execute
      results = results.flatten.sort_by { |sort| -(sort.seeds) }
    else
      case @service
        when :pirate_bay
          # do something
          handler = PirateBay::Search.new(@search_term)
        when :demonoid
          # do something
          handler = Demonoid::Search.new(@search_term)
        when :torrent_reactor
          # do something else
          handler = TorrentReactor::Search.new(@search_term)
        else
          raise "You must select a valid service provider"
      end

      results = handler.execute
    end
    @results = results
  end
end


# want to be able to do
# Torrent::Search.new(:all)
# Torrent::Search.new(:demonoid)
# Torrent::Search.new(:pirate_bay)
# Torrent::Search.new(:torrent_reactor)
# Search::Mininova.new('search_term')
#t = TorrentApi.new
#t.category = :movie # category may not be implemented in every api call
#t.service = :mininova
#results = t.get_results
#results.each { |torrent| puts torrent.seeds }
#
#t.service = :pirate_bay
#results = t.get_results
#
#t.service = :all
#results = t.get_results
#
#shorthand
#results = TorrentApi(:mininova, 'search_term')
#results = TorrentApi(:mininova, 'search_term')
#
#t = Torrent::Search.new(:mini_nova)
# results = t.execute
# results.each { |torrent| torrent.class = Torrent }