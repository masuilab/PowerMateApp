require 'rubygems'
require 'json'
require 'yaml'

class Hash
  def put_keys_into_children!(key=nil)
    self.each do |k,v|
      v['key'] = k if v.kind_of? Hash
      if v.kind_of? Array or v.kind_of? Hash
        v.put_keys_into_children!(k || key)
      end
    end
  end
end

class Array
  def put_keys_into_children!(key=nil)
    self.each do |i|
      if i.kind_of? Hash
        i['key'] = key
      end
      i.put_keys_into_children!(key)
    end
  end
end

yaml_files = ARGV

tree = {}

yaml_files.each do |f|
  data = YAML.load File.open(f).read
  data.put_keys_into_children!
  tree[File.basename(f).split('.')[0]] = data
end  

puts tree.to_json(
          :indent    => ' ' * 2,
          :object_nl => "\n",
          :space     => ' '
          )
