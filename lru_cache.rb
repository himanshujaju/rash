# Least Recently Used (LRU) cache.

require "set"

KeyData = Struct.new(:access_time, :value)

AccessOrderData = Struct.new(:access_time, :key) do
  def <=>(other)
    diff = self.access_time - other.access_time
    if diff == 0
      return 0
    elsif diff < 0
      return -1
    else
      return 1
    end
  end
end

class LRUCache
  
  def initialize(max_size)
    @max_size = max_size
    @current_size = 0
    @internal_clock = 0

    # Stores mapping of a key to KeyData
    @key_data = {}
    # Stores tuple<access time, key> for all keys.
    @access_order = SortedSet.new()
  end

  # Returns value stored or nil if not found.
  def find(key)
    if !contains?(key)
      return nil
    end

    @internal_clock += 1
    previous_data = @key_data[key]
    update_access_time(key, @internal_clock, previous_data.access_time)

    return previous_data.value
  end

  # Returns a boolean, whether the cache contains the key.
  def contains?(key)
    @key_data.has_key?(key)
  end

  # Removes a key from cache.
  def erase(key)
    if !contains?(key)
      return
    end

    erase_internal(key)
  end

  def add(key, value)
    if contains?(key)
      erase_internal(key)
    end
    
    @internal_clock += 1
    @current_size += 1
    data = KeyData.new(@internal_clock, value)
    access_order_data = AccessOrderData.new(@internal_clock, key)
    @key_data[key] = data
    @access_order.add(access_order_data)

    resize()
  end

  def size()
    @current_size
  end

  def resize()
    if size() > @max_size
      remove_key = @access_order.first.key
      erase_internal(remove_key)
    end
  end

  def update_access_time(key, accessed_at, existing_ts)
    @key_data[key].access_time = accessed_at
    @access_order.delete(AccessOrderData.new(existing_ts, key))
    @access_order.add(AccessOrderData.new(accessed_at, key))
  end

  def erase_internal(key)
    data = @key_data[key]
    @key_data.delete(key)
    @access_order.delete(AccessOrderData.new(data.access_time, key))
    @current_size -= 1
  end
  private :resize, :update_access_time, :erase_internal

end

