class Group
  attr_accessor :name
  
  def initialize(name)
    require 'open-uri'
    self.name = name
  end
  
  def member_ids
    doc = Hpricot::XML(raw_xml)
    doc.search(:steamID64).map(&:inner_html)
  end
    
  private
    def cache_path
      File.join(Rails.root, 'tmp', "group_cache_#{name}.xml")
    end
    
    def raw_xml
      if !File.exist?(cache_path) || File.mtime(cache_path) < lambda { 1.hours.ago }.call
        remote_xml
      else
        local_xml
      end
    end
    
    def remote_xml
      require 'open-uri'
      begin
        f = File.new(cache_path, "w")
        xml = URI.parse("http://steamcommunity.com/groups/#{name}/memberslistxml/?xml=1").read
        f.puts xml
        f.close
        xml
      rescue OpenURI::HTTPError
        local_xml
      end
    end
    
    def local_xml
      begin
        File.open(cache_path, "rb").read
      rescue
        raise "Could not open XML for #{name}"
      end
    end
end