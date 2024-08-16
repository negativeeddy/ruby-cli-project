require 'thor'
require 'exif'
require 'pathname'
require 'builder'

# reads image files and extracts GPS data
class ImageCLI < Thor
  attr_accessor :geo_results

  desc 'hello NAME', 'say hello to NAME'
  def hello(name)
    puts "Hello #{name}"
  end

  desc 'scan [DIRECTORY]', 'scan the DIRECTORY'
  option :verbose, type: :boolean, default: false
  option :outputType, type: :string, default: 'csv', enum: %w[csv xml]
  def scan(directory = nil)
    @geo_results = []
    directory = File.absolute_path('.') if directory.nil?
    verbose_output "starting with #{directory}, output is #{options[:outputType]}"
    process_directory(directory)
    puts generate_output
  end

  no_commands do # rubocop:disable Metrics/BlockLength
    def verbose_output(message)
      puts message if options[:verbose]
    end

    def generate_output
      verbose_output "printing results as #{options[:outputType]}"
      case options[:outputType]
      when 'csv'
        output_csv_results
      when 'xml'
        output_xml_results
      else
        'Unknown output type'
      end
    end

    def output_csv_results
      output = ''
      @geo_results.each do |result|
        output += "#{result[0]},#{result[1]}\n"
      end
      output
    end

    def output_xml_results
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.results do |results|
        @geo_results.each do |result|
          results.image do |image|
            image.path result[0]
            image.location result[1]
          end
        end
      end

      builder.target!
    end

    def process_directory(directory)
      verbose_output "scanning: #{directory}"
      Dir.foreach(directory) do |filename|
        full_path = File.absolute_path(filename, directory)

        if (Dir.exist?(full_path) unless filename.start_with?('.'))
          process_directory(full_path)
        elsif ['.jpg', '.gif', '.png'].include? File.extname(full_path).downcase
          file_pathname = Pathname.new(full_path)
          process_file file_pathname
        end
      end
    end

    def process_file(filepath)
      absolute_path = filepath.expand_path
      location = get_geo_data(absolute_path)
      @geo_results.push([filepath, location])
    end

    def get_geo_data(absolute_path)
      f = File.open(absolute_path)
      data = Exif::Data.new(f) # load from file

      if data.gps_latitude.nil? || data.gps_longitude.nil?
        'No GPS data found'
      else
        stringify_geo data.gps_latitude, data.gps_latitude_ref
      end
    rescue Exif::NotReadable
      'Not a readable file'
    end

    def stringify_geo(position, geo_ref)
      degrees = position[0].to_f
      minutes = position[1].to_f
      seconds = position[2].to_f
      "#{degrees}° #{minutes}' #{seconds}\" #{geo_ref}"
    end
  end
end

ImageCLI.start(ARGV)
