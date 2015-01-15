require File.expand_path('../../lib/lruhash',  __FILE__)
require 'bundler'
Bundler.require(:default)
require 'pry'
require 'minitest/autorun'

describe 'LRUHash' do
  describe "An lru hash" do
    before do
      @hash = LRUHash.new
      @hash.max = 2
    end

    it "should allow simple insertion" do
      @hash["1"] = 1
      assert_equal 1, @hash["1"]
    end

    it "should throw out the least recently written element" do
      @hash["1"] = 1
      @hash["2"] = 2
      @hash["3"] = 3

      assert_equal nil, @hash["1"]
      assert_equal 2,   @hash["2"]
      assert_equal 3,   @hash["3"]
    end

    it "should throw out the least recently read item" do
      @hash["1"] = 1
      @hash["2"] = 2

      @hash["1"]

      @hash["3"] = 3

      assert_equal 1,   @hash["1"]
      assert_equal nil, @hash["2"]
      assert_equal 3,   @hash["3"]
    end

    it "should expire old items when store is called" do
      @hash["1"] = 1
      @hash["2"] = 2

      @hash.store("3", 3)

      assert_equal nil, @hash["1"]
      assert_equal 2,   @hash["2"]
      assert_equal 3,   @hash["3"]
    end

    describe "fetch" do
      it "fetch should update the recently read list if the element is found" do
        @hash["1"] = 1
        @hash["2"] = 2

        @hash.fetch("1")

        @hash["3"] = 3

        assert_equal 1,   @hash["1"]
        assert_equal nil, @hash["2"]
        assert_equal 3,   @hash["3"]
      end

      it "should allow fetch with a default.  Does not store if used." do
        assert_equal 42, @hash.fetch('2', 42)
        assert_equal nil, @hash['2']
      end

      it "should allow fetch with a block.  Does not store if used." do
        assert_equal 42, @hash.fetch('2') { 42 }
        assert_equal nil, @hash['2']
      end
    end

    describe "scaling" do
      it "should work with a large number of items" do
        iterations = 10_000
        keys = (0..iterations - 2).to_a.shuffle
        @hash.max = iterations

        @hash["first"] = "initial element"
        assert_equal "initial element", @hash["first"]

        keys.each { |k| @hash[k.to_s] = "=#{k}" }
        assert_equal "initial element", @hash["first"]

        keys.each { |k| @hash[k.to_s] }
        @hash["last"] = "push the first out!"

        assert_equal nil, @hash["first"]
      end
    end
  end
end
