require 'minitest/autorun'
require './blog'

class TestBlog < Minitest::Unit::TestCase

  def setup
    @blog = Blog.new
  end

  def test_title_is_treehouse
    assert_equal "Treehouse Blog", @blog.title
  end
end