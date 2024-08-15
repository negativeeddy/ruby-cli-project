require 'thor'
require 'exif'
require 'pathname'

class ImageCLI < Thor
  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  desc "scan [DIRECTORY]", "scan the DIRECTORY"
  def scan (directory = ".")
    puts "Scanning #{directory}"
    process_directory(directory)
  end

  private 
def process_directory(directory)
  Dir.foreach(directory)  do |file|
    next if file.start_with?('.')
    next if file.start_with?('_')
    full_path = File.join(directory, file)
    
    if (Dir.exist?(full_path))
      puts "Directory: #{full_path}"
      process_directory(full_path)      
    elsif file.end_with?("jpg")
      file_pathname = Pathname.new(full_path)
      process_file file_pathname
    end
  end
end

  def process_file(filepath)
    # puts filepath
    absolute_path = filepath.expand_path
    # puts "Absolute Path: #{absolute_path}"
    f = File.open(absolute_path)
    begin
      data = Exif::Data.new(f) # load from file
    rescue Exif::NotReadable
      puts "#{absolute_path} Not a readable file"
      return
    end
    puts "#{absolute_path} #{data.gps_longitude}"
  end
end

ImageCLI.start(ARGV)
