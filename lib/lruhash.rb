class LRUHash < Hash
  def initialize(max:)
    @max = max
  end

  def max
    @max ||= 256
  end

  def store(key, value)
    if !key?(key) && length > (max - 1)
      shift
    end
    super(key, value)
  end

  def fetch(*args, &blk)
    key = args[0]
    if key?(key)
      self[key]
    else
      super(*args, &blk)
    end
  end

  def []=(key, value)
    store(key, value)
  end

  def [](key)
    if (value = super(key))
      # We delete and add here to put the entry back on the front of the LRU list.
      delete(key)
      self[key] = value
    end
    value
  end
end
