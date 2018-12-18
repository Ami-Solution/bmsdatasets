#!/usr/bin/env ruby

require 'csv'
require 'json'
require 'yaml'
require_relative 'solar_scout_util'

class MdToJson
  include SolarScoutUtil

  def convert(fname)
    raw = YAML::load_file fname
    obj = {
      'dataset_id'  => build_id(raw['title']),
      'active'      => true,
      'source'      => 'solarscout',
      'category_id' => build_id(raw['category'])
    }.merge(raw)

    str = File.read fname
    str =~ /.+##.+ Description\s+(.+)(##.+Value\s+)(.+)/m
    obj['description'] = $1.strip
    obj['value'] = $3.strip

    obj
  end

  def format(filenames, io=STDOUT)
    objects = filenames.map {|fname| convert(fname)}
    headers = collect_headers(objects).uniq

    # generate CSV header line
    io << CSV.generate_line(headers)

    # generate rows
    objects.each do |obj|
      row = headers.map {|key| obj[key]}
      io << CSV.generate_line(row)
    end
  end

  private

  def collect_headers(array_of_objects)
    array_of_objects.reduce([]) {|memo, obj| memo += obj.keys}
  end

end


if __FILE__ == $0
  raise "USAGE: #{$0} MARKDOWN_FILES" unless ARGV.length > 0

  MdToJson.new.format(ARGV)
end
