require 'minitest/autorun'
require_relative 'image_cli'

# test the cli
class TestLocationCLI < Minitest::Test
  def setup
    @cli = ImageCLI.new
  end

  def test_execute_command
    @cli.geo_results = [['/x/image.jpg', "50.0° 5.48' 0.0\" N"],
                        ['path 2', 'location 2']]
    @cli.options = { outputType: 'csv' }
    actual = @cli.generate_output
    expected = "/x/image.jpg,50.0° 5.48' 0.0\" N\npath 2,location 2\n"
    assert_equal expected, actual
  end

  def test_xml_results
    @cli.geo_results = [['/x/image.jpg', "50.0° 5.48' 0.0\" N"],
                        ['path 2', 'location 2']]
    actual = @cli.output_xml_results
    expected = "<results>\n  <image>\n    <path>/x/image.jpg</path>\n    <location>50.0° 5.48' 0.0\" N</location>\n  </image>\n  <image>\n    <path>path 2</path>\n    <location>location 2</location>\n  </image>\n</results>\n"
    assert_equal expected, actual
  end

  def test_xml_results_empty
    @cli.geo_results = []
    actual = @cli.output_xml_results
    expected = "<results>\n</results>\n"
    assert_equal expected, actual
  end

  def test_csv_results
    @cli.geo_results = [['/x/image.jpg', "50.0° 5.48' 0.0\" N"],
                        ['path 2', 'location 2']]
    actual = @cli.output_csv_results
    expected = "/x/image.jpg,50.0° 5.48' 0.0\" N\npath 2,location 2\n"
    assert_equal expected, actual
  end

  def test_csv_results_empty
    @cli.geo_results = []
    actual = @cli.output_csv_results
    expected = ''
    assert_equal expected, actual
  end
end
