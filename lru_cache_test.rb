#!/usr/bin/env ruby -w

# Unit tests for LRUCache
# Run `./lru_cache_test.rb` to run these tests

require './lru_cache'

class AssertionError < RuntimeError
end

def assert(condition)
  if !condition
    raise AssertionError
  end
end

def generate_key_value(id)
  return "key_" + id.to_s, "value_" + id.to_s
end

def FindValidKeyTest()
  cache = LRUCache.new(10)
  key = "key_42"
  value = "value_xyz"
  cache.add(key, value)

  assert(cache.contains?(key))
  assert(cache.find(key) == value)
end

def FindInvalidKeyTest()
  key = "key_to_check"
  cache = LRUCache.new(10)
  cache.add("random_key", "random_value")

  assert(cache.size() == 1)
  assert(!cache.contains?(key))
  assert(cache.find(key) == nil)
end

def ValidEraseTest()
  key = "key_42"
  value = "random_value"
  cache = LRUCache.new(10)
  cache.add(key, value)
  
  assert(cache.contains?(key))
  cache.erase(key)
  assert(!cache.contains?(key))
end

def InvalidEraseTest()
  key = "key_to_check"
  cache = LRUCache.new(10)
  cache.add("key_42", "random_value")
  
  assert(cache.size() == 1)
  assert(!cache.contains?(key))
end

def AddWithUpdatedAccessTimeTest()
  cache_size = 7
  range = 0...cache_size
  cache = LRUCache.new(cache_size)
  range.each do |i|
     key, value = generate_key_value(i)
     cache.add(key, value)
  end
  assert(cache.size() == cache_size)

  target_key = "key_0"
  target_value = "new_target_value"
  cache.add(target_key, target_value)
  assert(cache.find(target_key) == target_value)
  assert(cache.size() == cache_size)

  range.each do |i|
    key, _ = generate_key_value(i)
    assert(cache.contains?(key))
  end

  # We have added more items than our cache can handle.
  key, value = generate_key_value(10)
  cache.add(key, value)

  # `key_1` should be removed instead of `key_0`
  assert(cache.size() == cache_size)
  assert(cache.contains?(target_key))
  assert(!cache.contains?("key_1"))
end

def FindAndUpdateKeyAccessTimeTest()
  cache_size = 7
  range = 0...cache_size
  cache = LRUCache.new(cache_size)
  range.each do |i|
     key, value = generate_key_value(i)
     cache.add(key, value)
  end
  assert(cache.size() == cache_size)

  target_key, target_value = generate_key_value(0)
  assert(cache.find(target_key) == target_value)
  assert(cache.size() == cache_size)

  range.each do |i|
    key, _ = generate_key_value(i)
    assert(cache.contains?(key))
  end

  # We have added more items than our cache can handle.
  key, value = generate_key_value(10)
  cache.add(key, value)

  # `key_1` should be removed instead of `key_0`
  assert(cache.size() == cache_size)
  assert(cache.contains?(target_key))
  assert(!cache.contains?("key_1"))
end

def AddTooManyItemsTest()
  cache_size = 7
  range = 0...cache_size
  cache = LRUCache.new(cache_size)
  range.each do |i|
     key, value = generate_key_value(i)
     cache.add(key, value)
  end
  assert(cache.size() == cache_size)

  # We have added more items than our cache can handle.
  key, value = generate_key_value(10)
  cache.add(key, value)

  assert(cache.size() == cache_size)
  assert(!cache.contains?("key_0"))
end

def RunAllTests()
  puts "Running tests."

  FindValidKeyTest()
  FindInvalidKeyTest()

  ValidEraseTest()
  InvalidEraseTest()

  AddWithUpdatedAccessTimeTest()
  FindAndUpdateKeyAccessTimeTest()
  AddTooManyItemsTest()

  puts "All tests passed."
end

RunAllTests()

