#!/usr/bin/env ruby

require 'csv'
require 'json'
require_relative 'solar_scout_util'

# Converts SolarScout/Catalyst datasets CSV to JSON
#
class CsvToJson
  include SolarScoutUtil

  def process(csv_fname)
    csv = CSV.read(csv_fname, headers:true)

    # extract named headers
    all_headers = csv.headers

    # organize return result
    array = []

    # iterate over rows
    csv.each do |row|
      hash = {
        'category_id' => build_id(row['category']),
        'title_id'    => build_id(row['title'])
      }
      all_headers.each {|key|
        case key
        when 'sources', 'tags'
          splitted = row[key].split /,/
          stripped = splitted.map &:strip
          hash[key] = stripped
        when 'status'
          hash[key] = ('1' == row[key])
        else
          hash[key] = row[key]
        end
      }

      array << hash
    end

    {'datasets' => array}
  end

end


if __FILE__ == $0 && 1 == ARGV.length
  # if there is 1 argument, invoke code on first argument

  fname = ARGV[0]
  converter = CsvToJson.new
  obj = converter.process(fname)

  puts JSON.pretty_generate(obj)

elsif __FILE__ == $0 && 0 == ARGV.length
  # no command line arg, run unit test

  require 'minitest/autorun'

  class Test < Minitest::Test
    def setup
      fname = 'data/datasets.csv'
      @converter = CsvToJson.new
      @result = @converter.process(fname)
    end

    def test_datasets
      datasets = @result['datasets']

      assert_instance_of Array, datasets
      assert_equal 27, datasets.size

      # first dataset
      dset = datasets.first
      assert_equal 'Solar DataSet Query', dset['title']

      # status needs to be a boolean
      assert_equal true, dset['status']

      # 'sources' and 'tags' should be arrays
      {
        'sources' =>['solarscout'],
        'tags'    =>['api']
      }.each {|key, arry|
        assert_equal arry, dset[key], "FAILED ON KEY: #{key}"
      }

      # find dataset with name
      selected = datasets.select {|ds|
        'Community Solar Scenario Tool (CSST)' == ds['title']
      }
      dset = selected[0]
      assert_equal 'community-solar-scenario-tool-csst', dset['title_id']
      assert_equal 'cost-and-economic-analyses', dset['category_id']
    end
  end

end
