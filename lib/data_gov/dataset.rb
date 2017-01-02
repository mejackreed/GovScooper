require 'pairtree'

module DataGov
  class Dataset
    attr_reader :id, :ckan_metadata

    def initialize(ckan_metadata)
      @ckan_metadata = ckan_metadata
      @id = ckan_metadata['id']
    end

    def save_ckan_metadata
      pairtree.open('ckan.json', 'w') do |io|
        io.write(JSON.pretty_generate(ckan_metadata))
      end
    end

    def pairtree
      @pairtree ||= Pairtree.at(pairtree_location, create: true)
                            .mk(id.delete('-'))
    end

    def pairtree_location
      ENV.fetch('DATA_DIR')
    end
  end
end
