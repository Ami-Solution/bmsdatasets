#!/usr/bin/env ruby

require 'csv'
require_relative 'solar_scout_util'

class NormalizeCsvIds
  include SolarScoutUtil

  def process(csv_fname)
    csv = CSV.read(csv_fname, headers:true, encoding:'iso8859-1')

    # extract headers
    all_headers = csv.headers

    # collect the ones that are IDs
    id_headers = all_headers.reduce({}) do |memo, key|
      if key =~ /^(\w+)_id$/
        memo[key] = $1		# e.g., title_id => title
      end

      memo
    end

    # iterate over rows
    csv.each do |row|
      id_headers.each do |key_id, key|
        row[key_id] = build_id(row[key]) if row[key]
      end
    end

    csv
  end

end


if __FILE__ == $0 && 1 == ARGV.length
  # if there is 1 argument, invoke code on first argument

  fname = ARGV[0]
  csv = NormalizeCsvIds.new.process(fname)

  print csv.to_s

elsif __FILE__ == $0 && 0 == ARGV.length
  # no command line arg, run unit test

  require 'minitest/autorun'

  class Test < Minitest::Test
    def setup
    end

    def test_csvs
    end
  end

end
