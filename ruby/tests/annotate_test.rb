require 'minitest/autorun'
require 'open3'

describe "Junit annotate plugin parser" do
  it "handles no failures" do
    stdout, stderr, status = Open3.capture3(