require 'pairtree'
require 'JSON'

module DataGov
  class Dataset
    attr_accessor :id, :ckan_metadata
    attr_reader :resources

    def initialize(ckan_metadata)
      @ckan_metadata = ckan_metadata
      @id = ckan_metadata['id']
    end

    def save_ckan_metadata
      pairtree.open('ckan.json', 'w') do |io|
        io.write(JSON.pretty_generate(ckan_metadata))
      end
    end

    def resources
      @resources ||= ckan_metadata['resources'].map do |resource|
        DataGov::Resource.new(resource, self)
      end
    end

    def download_resources
      puts "Downloading resources for #{id}"
      resources.map { |resource| resource.download }
    end

    def pairtree
      @pairtree ||= Pairtree.at(pairtree_location, create: true)
                            .mk(id.delete('-'))
    end

    def pairtree_location
      ENV.fetch('DATA_DIR')
    end

    def self.from_id(id)
      instance = new('')
      instance.id = id
      instance.ckan_metadata = JSON.parse(instance.pairtree.read('ckan.json'))
      instance
    end
  end
end
