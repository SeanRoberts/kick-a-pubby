class Group
  attr_accessor :name

  def initialize(name)
    require 'open-uri'
    self.name = name
  end

  def member_ids
    member_list.split("\n")
  end

  def cache_path
    File.join(Rails.root, 'tmp', "group_cache_#{name}.txt")
  end

  private
    def member_list
      if !File.exist?(cache_path) || File.mtime(cache_path) < lambda { 1.hours.ago }.call
        remote_xml
      else
        local_list
      end
    end

    def remote_xml
      require 'open-uri'
      begin
        current_page = 1
        # Get the first page and write it
        xml = URI.parse("http://steamcommunity.com/groups/#{name}/memberslistxml/?xml=1&p=#{current_page}").read
        doc = Hpricot::XML(xml)
        f = File.new(cache_path, "w")
        f.puts doc.search(:steamID64).map(&:inner_html).join("\n")
        f.close

        # Get subsequent pages
        while doc.search(:totalPages).inner_html.to_i > current_page
          current_page += 1
          xml = URI.parse("http://steamcommunity.com/groups/#{name}/memberslistxml/?xml=1&p=#{current_page}").read
          doc = Hpricot::XML(xml)
          f = File.new(cache_path, "a")
          f.puts doc.search(:steamID64).map(&:inner_html).join("\n")
          f.close
        end

        local_list
      rescue OpenURI::HTTPError
        local_list
      end
    end

    def local_list
      begin
        File.open(cache_path, "rb").read
      rescue
        raise "Could not open XML for #{name}"
      end
    end
end