require 'mime/types'
require 'open-uri'
require 'open_uri_redirections'
require 'fileutils'

module DataGov
  class Resource
    attr_reader :metadata, :dataset

    def initialize(metadata, dataset)
      @metadata = metadata
      @dataset = dataset
    end

    def download
      if File.exist?(File.join(directory, file_name))
        puts "#{file_name} already exists, skipping download"
        return
      end
      puts "Downloading from: #{metadata['url']}"
      begin
        FileUtils.mkdir_p(directory)
        retries ||= 0
        puts "try ##{retries}"
        download = open(
          metadata['url'],
          allow_redirections: :all,
          read_timeout: 900,
          open_timeout: 60
        )
        File.open(File.join(directory, file_name), 'w') { |io| IO.copy_stream(download, io) }
        File.open(File.join(directory, 'headers.txt'), 'w') { |file| file.write(download.meta.to_json) }
      rescue StandardError => e
        puts e.inspect
        if (retries += 1) < 3
          puts 'Retrying'
          retry
        end
        puts "Removing #{directory}"
        FileUtils.rm_rf(directory)
      end
    end

    def directory
      File.join(dataset.pairtree.path, metadata['id'])
    end

    def file_name
      File.basename(metadata['url'])
    end

    def extension
      mimetype.preferred_extension
    end

    def mimetype
      MIME::Types[metadata['mimetype']].first || MIME::Types['text/plain'].first
    end
  end
end
