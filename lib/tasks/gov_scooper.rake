require 'json'
require 'gov_scooper'
require 'fileutils'
# require 'pry'

def download_layers(layers)
  resource_count = 0
  layer_count = 0
  layer_total = layers.count
  layers.each do |layer|
    begin
      layer_count += 1
      puts "#{layer_count} of #{layer_total}"
      dataset = DataGov::Dataset.from_id(layer[0])
      puts "Downloading from dataset #{dataset.id}"
      resources = dataset.resources
      resource_count += resources.length
      resources.map(&:download)
    rescue StandardError => e
      puts e.inspect
    end
  end
  puts "#{resource_count} total resources"
end

namespace :gov_scooper do
  desc 'Sample OGM data and move it to a new directory'
  task :sample do
    number = Integer(ENV['GS_SAMPLE']) || 1
    ogm_loc = ENV.fetch('DATA_DIR')
    sample_output = ENV.fetch('GS_OUTPUT')
    if ogm_loc.nil?
      raise 'Please provide environment variable DATA_DIR'\
            ' for opengeometdata directory location'
    end
    raise 'Please provide output directory GS_OUTPUT' if sample_output.nil?

    Rake::Task['gov_scooper:copy_sample'].invoke
    ENV['DATA_DIR'] = sample_output
    Rake::Task['gov_scooper:create_layers_json'].invoke
    Rake::Task['gov_scooper:download_data'].invoke
    ENV['DATA_DIR'] = ogm_loc
  end
  desc 'Copy a sample of data'
  task :copy_sample do
    number = Integer(ENV['GS_SAMPLE']) || 1
    ogm_loc = ENV.fetch('DATA_DIR')
    sample_output = ENV.fetch('GS_OUTPUT')
    if ogm_loc.nil?
      raise 'Please provide environment variable DATA_DIR'\
            ' for opengeometdata directory location'
    end
    raise 'Please provide output directory GS_OUTPUT' if sample_output.nil?

    layers = JSON.parse(File.read(File.join(ogm_loc, 'pairtree_root', 'layers.json')))
    puts "#{layers.length} layers found"
    random_layers = layers.to_a.sample(number).to_h
    puts "Sampling #{random_layers.length} layers"
    random_layers.values.each do |value|
      output = File.join(sample_output, 'pairtree_root', value)
      FileUtils.mkdir_p output
      Dir[File.join(ogm_loc, 'pairtree_root', value, '*')].each do |file_name|
        next if File.directory? file_name
        puts "Copying #{file_name}"
        FileUtils.cp file_name, output
      end
    end
  end
  desc 'Download from a sample'
  task :download_sample do
    number = Integer(ENV['GS_SAMPLE']) || 1
    ogm_loc = ENV.fetch('DATA_DIR')
    if ogm_loc.nil?
      raise 'Please provide environment variable DATA_DIR'\
            ' for opengeometdata directory location'
    end
    layers = JSON.parse(File.read(File.join(ogm_loc, 'pairtree_root', 'layers.json')))
    puts "#{layers.length} layers found"
    random_layers = layers.to_a.sample(number).to_h
    puts "Sampling #{random_layers.length} layers"
    download_layers(random_layers)
  end
  desc 'Download data for layers in a given directory - Be careful with this'
  task :download_data do
    ogm_loc = ENV.fetch('DATA_DIR')
    if ogm_loc.nil?
      raise 'Please provide environment variable DATA_DIR'\
            ' for opengeometdata directory location'
    end
    layers = JSON.parse(File.read(File.join(ogm_loc, 'pairtree_root', 'layers.json')))
    puts "#{layers.length} layers found"
    download_layers(layers)
  end
  desc 'Create layers.json'
  task :create_layers_json do
    ogm_loc = ENV.fetch('DATA_DIR')
    if ogm_loc.nil?
      raise 'Please provide environment variable DATA_DIR'\
            ' for opengeometdata directory location'
    end
    layers = Dir[File.join(ogm_loc, 'pairtree_root', '**', 'ckan.json')]
    h = layers.map do |f|
      d = DataGov::Dataset.new(JSON.parse(File.read(f)))
      {
        d.id => f.sub(/.*pairtree_root\//, '').sub('ckan.json', '')
      }
    end
    v = h.inject(:merge!)
    puts "layers.json created for #{layers.count} files"
    File.open(File.join(ogm_loc, 'pairtree_root', 'layers.json'), 'w') do |io|
      io.write(JSON.pretty_generate(v))
    end
  end
end
