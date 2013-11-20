# -*- coding: utf-8 -*-
require 'rubygems'
require 'mini_exiftool'
require 'awesome_print'
require 'yaml'

def get_create_date(fpath)
  MiniExiftool.new(fpath)["createdate"]
end

if ARGV.empty?
  STDERR.puts "please specify photo directory"
  STDERR.puts "e.g.  ruby make_hierarcy_photo.rb /path/to/photodir"
  exit 1
end

dir = ARGV.shift
files = Dir.glob(File.join dir, "*").select{|i| i =~ /[^sml].jpg$/ }

tree = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = [] } } }

files.each do |file|
  date = get_create_date file
  next unless date
  node = {:url => file, :name => "masui photo"}
  tree["#{date.year}"]["#{date.year}/#{date.month}"]["#{date.year}/#{date.month}/#{date.day}"].push node
end

puts tree.to_yaml
