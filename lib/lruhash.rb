class LRUHash < Hash
  def max
    @max ||= 256
  end

  def max=(value)
    @max = value
    shift while length > @max
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
      delete(key)
      self[key] = value
    end
    value
  end
end
