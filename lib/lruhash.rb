# A hash class that closely mimicks the original Ruby hash
# with a subtle difference, it is limited in size and cannot
# grow beyond a max value. This is done by maintaining the
# hashed objects in activity order and removing the least
# recently used item if the hash exceeds its size limit.
# Useful for implementing in-process caches where memory
# growth control is desired
# 
# There are two alternate implementations, one for Ruby 1.9.x+
# and one for previous Ruby versions. The 1.9.x implementation
# makes use of the fact that the new Ruby hash maintains insertion
# order. It should be better than the version for older Rubys as it relies
# on the native hash for most of its operations
if RUBY_VERSION.to_f >= 1.9 
  module LRU
    def max
      @max ||= 256
    end

    def max=(value)
      @max = value
      shift while self.length > @max
    end
      
    def [](key)
      if value = super(key)
        self.delete(key)
        self[key] = value
      end
    end
    
    def []=(key,value)
      unless self[key]
        self.shift while self.length > (max - 1)
      end
      super(key,value)
    end
  end

  class LRUHash < Hash
    include LRU
  end

else

  class LRUHash
    attr_accessor :max
    
    include Enumerable
    
    # The initialize method accepts any arguments
    # that are accepted by a normal hash
    # it initializes and internal hash with those
    # argumnets
    def initialize(*args)
      @max = 256
      @head = @tail = nil
      @store = Hash.new(*args)
    end
    
    # Used to set the maximum size of the hash
    # The initialize method sets a default size of 256
    def max=(value)
      @max = value
      shift while @store.length > @max
    end
    
    # Access an item by key.
    # The item will be promoted as the MRU item
    def [](key)
      if record = touch(key)
        trail(record)
        record[:value]
      end
    end
    
    # Insert/Update an item by key
    # If the item does not exist
    # It is created as the MRU
    # Else it is update and set as MRU
    def []=(key,value)
      if record = touch(key)
        trail(record)
        record[:value] = value
      else
        shift if @store.length >= @max 

        record = {:key=> key, :value=>value,:previous=>nil, :next=>nil}
        @store[key] = record
        if @store.length == 1
          @head = @tail = record
        else
          trail record
        end
      end
      value
    end
    
    # Removes the LRU item
    # Set the next item as the LRU item
    def shift
      if @store.length > 0
        @store.delete(@head[:key])
        value = @head[:value]
        key = @head[:key]
        if @store.length > 0
          @head = @head[:next]
          @head[:previous] = nil
        else
          @head = @tail = nil
        end
      end
      [key, value] if key
    end
    
    # Delete the item identified by key
    # Manage the item links appropiatly 
    def delete(key)
      if record = touch(key)
        @store.delete(key)
        @head = @tail = nil if @store.length.zero?
        record[:value]
      end
    end
    
    # Iterate over items in LRU order
    def each
      record = @head
      while record
        yield record[:key], record[:value]
        record = record[:next]
      end
    end
    
    # Iterate over items in reverse LRU (MRU) order
    def reversed_each
      record = @tail
      while record
        yield record[:key], record[:value]
        record = record[:previous]
      end
    end
    
    # The number of items in the hash
    def length
      @store.length
    end
    
    # Clears the hash
    def clear
      @store.clear
    end
    
    protected
    
    def touch key
      if record = @store[key]
        if record[:previous]
          record[:previous][:next] = record[:next]
          @tail = record[:previous] if @tail.object_id == record.object_id && record[:previous]
        end
        if record[:next]
          record[:next][:previous] = record[:previous]
          @head = record[:next] if @head.object_id == record.object_id && record[:next]
        end
      end
      record
    end
    
    def trail record
        record[:previous] = @tail
        @tail[:next] = record
        @tail = record
        record[:next] = nil
    end
    
  end
end

if __FILE__ == $0
  def setup
    @arr = [3,2,1,0,4,5,7,6,8,9]
    @h = LRUHash.new
    @arr.each {|e| @h[e] = e }
  end
  test_cases = {
    :test_insertion_order_with_each => Proc.new do
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == @arr
      print ' '
    end,
    :test_insertion_order_with_shift => Proc.new do
      arr = []
      while rec = @h.shift
        arr << rec[0]
      end
      print arr == @arr
      print ' '
      print @h.length == 0
      print ' '
    end, 
    :test_order_after_access => Proc.new do
      arr = []
      @arr.reverse.each {|e|@h[e] }
      while rec = @h.shift
        arr << rec[0]
      end
      print arr == @arr.reverse
      print ' '
    end,
   :test_set_max => Proc.new do
      @h.max = max = 3
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == @arr[@arr.length-max,max]    
      print ' '
    end,
    :test_set_max_with_access => Proc.new do
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == @arr
      print ' '
      @h[3]
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == @arr[1,arr.length-1]+[3]
      print ' '
      @h.max = max = 6
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == [5,7,6,8,9,3]
      print ' '
      @h[5]
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == [7,6,8,9,3,5]
      print ' '
      @h[13] = 13
      arr = []
      @h.each do |key,value|
        arr << key
      end
      print arr == [6,8,9,3,5,13]
      print ' '
    end,
    :test_performance => Proc.new do
      @h = LRUHash.new
      t = Time.now
      count = 15000
      count.times do |i|
        x = rand(count)
        @h[x] = x
        @h[rand(count)]
        @h[x]
      end
      print Time.now - t < 1
      print ' '
    end
  }
  test_cases.each do |name, block|
    print name.to_s.gsub('_',' ') + ': '
    setup
    block[]
    puts;puts
  end
end
