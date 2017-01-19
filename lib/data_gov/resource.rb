require 'mime/types'
require 'open-uri'
require 'open_uri_redirections'
require 'ruby-progressbar'

module DataGov
  class Resource
    attr_reader :metadata, :dataset

    def initialize(metadata, dataset)
      @metadata = metadata
      @dataset = dataset
    end

    def download
      if dataset.pairtree.exists?(file_name)
        puts "#{file_name} already exists, skipping download"
        return
      end
      pbar = ProgressBar.create(title: file_name, total: nil)
      begin
        download = open(metadata['url'],
                        allow_redirections: :safe,
                        content_length_proc: lambda do |content_length|
                          if content_length && 0 < content_length
                            pbar.total = content_length
                          end
                        end,
                        progress_proc: lambda do |s|
                          if pbar.total
                            pbar.progress += s
                          else
                            pbar.increment
                          end
                        end)
        dataset.pairtree.open(file_name, 'w') { |io| IO.copy_stream(download, io) }
      rescue StandardError => e
        puts e
      end
    end

    def file_name
      "#{metadata['id']}.#{extension}"
    end

    def extension
      mimetype.preferred_extension
    end

    def mimetype
      MIME::Types[metadata['mimetype']].first || MIME::Types['text/plain'].first
    end
  end
end
