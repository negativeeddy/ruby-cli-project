require 'minitest/autorun'
require_relative 'image_cli'

# test the cli
class TestLocationCLI < Minitest::Test
  def setup
    @cli = ImageCLI.new
  end

  def test_execute_command
    @cli.geo_results = []
    @cli.geo_results.push ['/x/image.jpg', "50.0° 5.48' 0.0\" N"]
    @cli.geo_results.push ['path 2', 'location 2']
    @cli.options = { outputType: 'csv' }
    actual = @cli.generate_output
    expected = "/x/image.jpg,50.0° 5.48' 0.0\" N\npath 2,location 2\n"
    assert_equal expected, actual
  end
end
