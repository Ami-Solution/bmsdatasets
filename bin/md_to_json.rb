#!/usr/bin/env ruby

require 'json'
require 'yaml'

class MdToJson

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
    io << JSON.pretty_generate({'datasets' => objects})
  end

  private

  def build_id(str)
    str.gsub(/\W/, ' ').
      gsub(/ +/, '-').
      strip.
      downcase.
      gsub(/\-+$/, '')
  end

end


if __FILE__ == $0
  raise "USAGE: #{$0} MARKDOWN_FILES" unless ARGV.length > 0

  MdToJson.new.format(ARGV)
end
