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

    # iterate over rows to build title_id-to-dset
    datasets = {}
    csv.each do |row|
      title_id = build_id(row['title'])

      dset = {
        'category_id' => build_id(row['category']),
        'title_id'    => title_id
      }
      all_headers.each {|key|
        case key
        when 'sources', 'tags'
          splitted = row[key].split /,/
          stripped = splitted.map &:strip
          dset[key] = stripped
        when 'status'
          dset[key] = ('1' == row[key])
        else
          dset[key] = row[key]
        end
      }

      datasets[title_id] = dset
    end

    # iterate over datasets to build categories
    categories = {}
    datasets.each do |title_id, dset|
      cc = dset['category']
      categories[cc] = [] unless categories.include?(cc)
      categories[cc].push(title_id)
    end

    # iterate over datasets to build tag-to-title_ids
    tags = {}
    datasets.each do |title_id, dset|
      dset['tags'].each do |tt|
        tags[tt] = [] unless tags.include?(tt)
        tags[tt].push(title_id)
      end
    end

    {
      'datasets'	=> datasets,
      'index_source'	=> datasets.values,
      'categories'	=> categories,
      'tags'		=> tags
    }
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

      assert_instance_of Hash, datasets
      assert_equal 27, datasets.size

      # first dataset
      dset = datasets['solar-dataset-query']
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
    end

    def test_array
      array = @result['index_source']

      assert_instance_of Array, array
      assert_equal 27, array.size

      # a sample dataset has all the fields
      dset = array[0]
      %w(status sources category title summary description value tags
       link query contact identifier).each do |header|
        assert_equal true,
                     dset.include?(header),
                     "MISSING HEADER: #{header}"
      end
    end

    def test_build_id
      datasets = @result['datasets']
      dset = datasets['community-solar-scenario-tool-csst']

      assert_equal 'Community Solar Scenario Tool (CSST)', dset['title']
      assert_equal 'cost-and-economic-analyses', dset['category_id']
    end

    def test_categories
      categories = @result['categories']

      assert_instance_of Hash, categories
      assert_instance_of Array, categories.values.first

      histogram = {
        "Climate and Solar Data"=>2,
        "Cost and Economic Analyses"=>8,
        "Developer Resource"=>1,
        "Mapping Tools and Data"=>4,
        "Market Data"=>2,
        "Open Energy Information"=>2,
        "Photo Voltaic Data Acquisition"=>2,
        "Photo Voltaic Watts"=>3,
        "Utility Rate Database"=>3
      }
      assert_equal histogram.keys, categories.keys
      histogram.each do |cat, count|
        assert_equal count, categories[cat].length
      end
    end

    def test_tags
      histogram = {
        "api"=>11,
        "application"=>1,
        "gis"=>2,
        "pdf"=>1,
        "portal"=>3,
        "sdk"=>1,
        "web"=>7,
        "xls"=>4,
        "xml"=>1
      }

      tags = @result['tags']
      assert_instance_of Hash, tags
      assert_instance_of Array, tags.values.first

      assert_equal histogram.keys, tags.keys.sort
      histogram.each do |tt, count|
        assert_equal count, tags[tt].length
      end
    end
  end

end
