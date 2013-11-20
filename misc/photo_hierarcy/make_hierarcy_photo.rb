require 'rubygems'
require 'mini_exiftool'
require 'awesome_print'

def get_create_date(fpath)
  MiniExiftool.new(fpath)["createdate"]
end

if ARGV.empty?
  STDERR.puts "e.g.  ruby make_hierarcy_photo.rb /path/to/photodir"
  exit 1
end

dir = ARGV.shift
files = Dir.glob("#{dir}/*").select{|i|
  i =~ /[^sml].jpg$/
}

puts get_create_date files[0]
