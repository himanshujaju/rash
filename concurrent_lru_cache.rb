# Concurrent Least Recently Used (LRU) cache.
# The implementation is thread safe and can be accessed by multiple threads.

require "set"

class SemaphoreError < RuntimeError
end

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

class ConcurrentLRUCache
  
  def initialize(max_size)
    @max_size = max_size
    @current_size = 0
    @internal_clock = 0
    @semaphore = Mutex.new

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

    @semaphore.synchronize {
      @internal_clock += 1
      previous_data = @key_data[key]
      update_access_time_locked(key, @internal_clock, previous_data.access_time)

      return previous_data.value
    }
  end

  # Returns a boolean, whether the cache contains the key.
  def contains?(key)
    @semaphore.synchronize {
      @key_data.has_key?(key)
    }
  end

  # Removes a key from cache.
  def erase(key)
    if !contains?(key)
      return
    end

    @semaphore.synchronize {
      erase_internal_locked(key)
    }
  end

  def add(key, value)
    if contains?(key)
      @semaphore.synchronize {
        erase_internal_locked(key)
      }
    end
    
    @semaphore.synchronize {
      @internal_clock += 1
      @current_size += 1
      data = KeyData.new(@internal_clock, value)
      access_order_data = AccessOrderData.new(@internal_clock, key)
      @key_data[key] = data
      @access_order.add(access_order_data)

      resize_locked()
    }
  end

  def size()
    @semaphore.synchronize {
      @current_size
    }
  end

  def resize_locked()
    semaphore_owned(@semaphore)
    if @current_size > @max_size
      remove_key = @access_order.first.key
      erase_internal_locked(remove_key)
    end
  end

  def update_access_time_locked(key, accessed_at, existing_ts)
    semaphore_owned(@semaphore)
    @key_data[key].access_time = accessed_at
    @access_order.delete(AccessOrderData.new(existing_ts, key))
    @access_order.add(AccessOrderData.new(accessed_at, key))
  end

  def erase_internal_locked(key)
    semaphore_owned(@semaphore)
    data = @key_data[key]
    @key_data.delete(key)
    @access_order.delete(AccessOrderData.new(data.access_time, key))
    @current_size -= 1
  end
  
  def semaphore_owned(semaphore)
    if !semaphore.owned?()
      raise SemaphoreError
    end
  end

  private :resize_locked, :update_access_time_locked, :erase_internal_locked,
          :semaphore_owned

end

