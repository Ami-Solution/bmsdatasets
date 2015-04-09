#!/usr/bin/env ruby

require 'json'
require 'yaml'

class MdToJson

  def self.convert(fname)
    obj = YAML::load_file fname

    str = File.read fname
    str =~ /.+##.+ Description\s+(.+)(##.+Value\s+)(.+)/m
    obj['description'] = $1.strip
    obj['value'] = $3.strip

    obj
  end

  def self.format(filenames, io=STDOUT)
    objects = filenames.map {|fname| convert(fname)}
    io << JSON.pretty_generate({'datasets' => objects})
  end

end


if __FILE__ == $0
  raise "USAGE: #{$0} MARKDOWN_FILES" unless ARGV.length > 0

  MdToJson.format(ARGV)
end
