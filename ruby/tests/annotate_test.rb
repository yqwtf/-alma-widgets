require 'minitest/autorun'
require 'open3'

describe "Junit annotate plugin parser" do
  it "handles no failures" do
    stdout, stderr, status = Open3.capture3("#{__dir__}/../bin/annotate", "#{__dir__}/no-test-failures/")

    assert_equal stderr, <<~OUTPUT
      Parsing junit-1.xml
      Parsing junit-2.xml
      Parsing junit-3.xml
   