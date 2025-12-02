# Name:         Josh Goben
# OSU Email:    gobenj@oregonstate.edu
# Course:       CS261 - Data Structures
# Assignment:   Assignment 6
# Due Date:     07 December 2023
# Description:  Defines a HashMap class with associated methods for adding,
# removing, resizing, and getting values. Also contains methods to check if a
# key is present, to get all keys and values and to clear the HashMap entirely.


from a6_include import (DynamicArray, LinkedList,
                        hash_function_1, hash_function_2)


class HashMap:
    def __init__(self,
                 capacity: int = 11,
                 function: callable = hash_function_1) -> None:
        """
        Initialize new HashMap that uses
        separate chaining for collision resolution
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        self._buckets = DynamicArray()

        # capacity must be a prime number
        self._capacity = self._next_prime(capacity)
        for _ in range(self._capacity):
            self._buckets.append(LinkedList())

        self._hash_function = function
        self._size = 0

    def __str__(self) -> str:
        """
        Override string method to provide more readable output
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        out = ''
        for i in range(self._buckets.length()):
            out += str(i) + ': ' + str(self._buckets[i]) + '\n'
        return out

    def _next_prime(self, capacity: int) -> int:
        """
        Increment from given number and the find the closest prime number
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity % 2 == 0:
            capacity += 1

        while not self._is_prime(capacity):
            capacity += 2

        return capacity

    @staticmethod
    def _is_prime(capacity: int) -> bool:
        """
        Determine if given integer is a prime number and return boolean
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity == 2 or capacity == 3:
            return True

        if capacity == 1 or capacity % 2 == 0:
            return False

        factor = 3
        while factor ** 2 <= capacity:
            if capacity % factor == 0:
                return False
            factor += 2

        return True

    def get_size(self) -> int:
        """
        Return size of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._size

    def get_capacity(self) -> int:
        """
        Return capacity of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._capacity

    # ------------------------------------------------------------------ #

    def _hash_index(self, key: str) -> int:
        """
        Receives a key value then hashes and uses modulo to determine and
        return the target index of the array for the given key.

        Uses the current capacity of the current HashMap in the calculation.

        Returns the target key index as an integer.
        """
        key_hash = self._hash_function(key)  # get hash of key
        key_index = key_hash % self._capacity  # find target index

        return key_index

    def put(self, key: str, value: object) -> None:
        """
        Receives a key/value pair, then inserts into the current HashMap.
        If a duplicate key is provided then its stored value will be
        overwritten.

        Maintains a HashMap table load of 1 or less.
        """
        # check for load factor >= 1 and resize if necessary
        if self.table_load() >= 1.0:
            # doubles current capacity then resizes
            self.resize_table(self._capacity * 2)

        # get the target key index
        key_index = self._hash_index(key)

        # if LL contains key, remove and add new key
        # else add new key and increment size
        linked_list = self._buckets.get_at_index(key_index)
        if linked_list.contains(key):  # replace value
            linked_list.remove(key)
            linked_list.insert(key, value)
        else:  # insert new value
            linked_list.insert(key, value)
            self._size += 1

    def resize_table(self, new_capacity: int) -> None:
        """
        Resizes the current HashMap to the new capacity provided. Accepts any
        number 1 or greater and will automatically expand the capacity as
        needed to fit all elements.

        All existing key/value pairs will be retained but rehashed.
        """
        # stop if new_cap is less than 1 or not greater than current_size
        if new_capacity < 1:
            return

        # if not prime change to the next highest prime number
        if not self._is_prime(new_capacity):
            new_capacity = self._next_prime(new_capacity)

        # Now we make sure we're staying within a valid load factor of <= 1.0.
        # This allows for load factor of 1.0 since a full table is valid and
        # can be resized, and the load factor will be handled on the next
        # invocation of the put() method.
        while self._size / new_capacity > 1:
            new_capacity = self._next_prime(new_capacity * 2)

        # create new HashMap with new capacity and existing hash function
        new_map = HashMap(new_capacity, self._hash_function)

        # iterate through every element in the original array
        # check if that LL has any nodes
        # iterate through existing nodes putting all into new map
        # put() will handle resizing and rehashing of keys
        for element in range(self._capacity):
            linked_list = self._buckets.get_at_index(element)
            if linked_list.length() > 0:
                for node in linked_list:
                    new_map.put(node.key, node.value)  # indirect recursion

        # swap new_map components to current HashMap
        self._buckets = new_map._buckets
        self._capacity = new_map._capacity

    def table_load(self) -> float:
        """
        Returns the current table load of the HashMap.
        """
        return self._size / self._capacity

    def empty_buckets(self) -> int:
        """
        Returns the number of empty buckets in the current HashMap.
        """
        empty_buckets = 0
        for bucket in range(self._capacity):
            linked_list = self._buckets.get_at_index(bucket)
            if linked_list.length() == 0:
                empty_buckets += 1

        return empty_buckets

    def get(self, key: str):
        """
        Receives a key then returns the value associated with the key if it
        exists, or returns None otherwise.
        """
        key_index = self._hash_index(key)

        linked_list = self._buckets.get_at_index(key_index)
        node = linked_list.contains(key)
        if node:
            return node.value
        else:
            return node

    def contains_key(self, key: str) -> bool:
        """
        Receives a key then checks if the key exists in the HashMap. Returns
        True if so, False otherwise.
        """
        key_index = self._hash_index(key)
        linked_list = self._buckets.get_at_index(key_index)

        if linked_list.contains(key):
            return True
        else:
            return False

    def remove(self, key: str) -> None:
        """
        Receives a key then finds the key in the HashMap and removes it. If the
        key is not found, then nothing happens and nothing is returned.
        """
        key_index = self._hash_index(key)

        # get the linked list at node and removes the key if present
        # decrements the size if we successfully removed a key
        linked_list = self._buckets.get_at_index(key_index)
        if linked_list.remove(key):
            self._size -= 1

    def get_keys_and_values(self) -> DynamicArray:
        """
        Returns an array of all key/value pairs in the entire HashMap. Pairs
        will be returned as individual tuples for each pair.
        """
        hash_map_array = DynamicArray()

        for element in range(self._capacity):
            linked_list = self._buckets.get_at_index(element)
            if linked_list.length() > 0:
                for node in linked_list:
                    hash_map_array.append((node.key, node.value))

        return hash_map_array

    def clear(self) -> None:
        """
        Clears the HashMap but retains the current capacity.
        """
        new_map = HashMap(self._capacity)
        self._buckets = new_map._buckets
        self._size = 0


def find_mode(da: DynamicArray) -> tuple[DynamicArray, int]:
    """
    Receives a DynamicArray then calculates the mode of the values in the
    array.

    Returns a tuple of an array containing the mode(s) and an integer with the
    count of the mode(s).

    Default behavior for all unique elements is to return a mode count of 1 and
    an array of all elements.
    """
    map = HashMap()
    mode_array = DynamicArray()

    # iterate through da and put instances of each unique value into HashMap
    for element in range(da.length()):
        value = da.get_at_index(element)
        count = map.get(value)
        if count:
            map.put(value, count + 1)
        else:
            map.put(value, 1)

    # get the da export of the HashMap
    da_counts = map.get_keys_and_values()
    mode_counter = 0

    # iterate through each tuple and determine mode and counts
    for element in range(da_counts.length()):
        key, value = da_counts.get_at_index(element)
        if value > mode_counter:
            mode_array = DynamicArray()
            mode_array.append(key)
            mode_counter = value
        elif value == mode_counter:
            mode_array.append(key)

    return mode_array, mode_counter


# ------------------- BASIC TESTING ---------------------------------------- #

if __name__ == "__main__":

    print("\nPDF - put example 1")
    print("-------------------")
    m = HashMap(53, hash_function_1)
    for i in range(150):
        m.put('str' + str(i), i * 100)
        if i % 25 == 24:
            print(m.empty_buckets(), round(m.table_load(), 2), m.get_size(),
                  m.get_capacity())

    print("\nPDF - put example 2")
    print("-------------------")
    m = HashMap(41, hash_function_2)
    for i in range(50):
        m.put('str' + str(i // 3), i * 100)
        if i % 10 == 9:
            print(m.empty_buckets(), round(m.table_load(), 2), m.get_size(),
                  m.get_capacity())

    print("\nPDF - resize example 1")
    print("----------------------")
    m = HashMap(20, hash_function_1)
    m.put('key1', 10)
    print(m.get_size(), m.get_capacity(), m.get('key1'),
          m.contains_key('key1'))
    m.resize_table(30)
    print(m.get_size(), m.get_capacity(), m.get('key1'),
          m.contains_key('key1'))

    print("\nPDF - resize example 2")
    print("----------------------")
    m = HashMap(75, hash_function_1)
    keys = [i for i in range(1, 1000, 13)]
    for key in keys:
        m.put(str(key), key * 42)
    print(m.get_size(), m.get_capacity())

    for capacity in range(111, 1000, 117):
        m.resize_table(capacity)

        m.put('some key', 'some value')
        result = m.contains_key('some key')
        m.remove('some key')

        for key in keys:
            # all inserted keys must be present
            result &= m.contains_key(str(key))
            # NOT inserted keys must be absent
            result &= not m.contains_key(str(key + 1))
        print(capacity, result, m.get_size(), m.get_capacity(),
              round(m.table_load(), 2))

    print("\nPDF - table_load example 1")
    print("--------------------------")
    m = HashMap(101, hash_function_1)
    print(round(m.table_load(), 2))
    m.put('key1', 10)
    print(round(m.table_load(), 2))
    m.put('key2', 20)
    print(round(m.table_load(), 2))
    m.put('key1', 30)
    print(round(m.table_load(), 2))

    print("\nPDF - table_load example 2")
    print("--------------------------")
    m = HashMap(53, hash_function_1)
    for i in range(50):
        m.put('key' + str(i), i * 100)
        if i % 10 == 0:
            print(round(m.table_load(), 2), m.get_size(), m.get_capacity())

    print("\nPDF - empty_buckets example 1")
    print("-----------------------------")
    m = HashMap(101, hash_function_1)
    print(m.empty_buckets(), m.get_size(), m.get_capacity())
    m.put('key1', 10)
    print(m.empty_buckets(), m.get_size(), m.get_capacity())
    m.put('key2', 20)
    print(m.empty_buckets(), m.get_size(), m.get_capacity())
    m.put('key1', 30)
    print(m.empty_buckets(), m.get_size(), m.get_capacity())
    m.put('key4', 40)
    print(m.empty_buckets(), m.get_size(), m.get_capacity())

    print("\nPDF - empty_buckets example 2")
    print("-----------------------------")
    m = HashMap(53, hash_function_1)
    for i in range(150):
        m.put('key' + str(i), i * 100)
        if i % 30 == 0:
            print(m.empty_buckets(), m.get_size(), m.get_capacity())

    print("\nPDF - get example 1")
    print("-------------------")
    m = HashMap(31, hash_function_1)
    print(m.get('key'))
    m.put('key1', 10)
    print(m.get('key1'))

    print("\nPDF - get example 2")
    print("-------------------")
    m = HashMap(151, hash_function_2)
    for i in range(200, 300, 7):
        m.put(str(i), i * 10)
    print(m.get_size(), m.get_capacity())
    for i in range(200, 300, 21):
        print(i, m.get(str(i)), m.get(str(i)) == i * 10)
        print(i + 1, m.get(str(i + 1)), m.get(str(i + 1)) == (i + 1) * 10)

    print("\nPDF - contains_key example 1")
    print("----------------------------")
    m = HashMap(53, hash_function_1)
    print(m.contains_key('key1'))
    m.put('key1', 10)
    m.put('key2', 20)
    m.put('key3', 30)
    print(m.contains_key('key1'))
    print(m.contains_key('key4'))
    print(m.contains_key('key2'))
    print(m.contains_key('key3'))
    m.remove('key3')
    print(m.contains_key('key3'))

    print("\nPDF - contains_key example 2")
    print("----------------------------")
    m = HashMap(79, hash_function_2)
    keys = [i for i in range(1, 1000, 20)]
    for key in keys:
        m.put(str(key), key * 42)
    print(m.get_size(), m.get_capacity())
    result = True
    for key in keys:
        # all inserted keys must be present
        result &= m.contains_key(str(key))
        # NOT inserted keys must be absent
        result &= not m.contains_key(str(key + 1))
    print(result)

    print("\nPDF - remove example 1")
    print("----------------------")
    m = HashMap(53, hash_function_1)
    print(m.get('key1'))
    m.put('key1', 10)
    print(m.get('key1'))
    m.remove('key1')
    print(m.get('key1'))
    m.remove('key4')

    print("\nPDF - get_keys_and_values example 1")
    print("------------------------")
    m = HashMap(11, hash_function_2)
    for i in range(1, 6):
        m.put(str(i), str(i * 10))
    print(m.get_keys_and_values())

    m.put('20', '200')
    m.remove('1')
    m.resize_table(2)
    print(m.get_keys_and_values())

    print("\nPDF - clear example 1")
    print("---------------------")
    m = HashMap(101, hash_function_1)
    print(m.get_size(), m.get_capacity())
    m.put('key1', 10)
    m.put('key2', 20)
    m.put('key1', 30)
    print(m.get_size(), m.get_capacity())
    m.clear()
    print(m.get_size(), m.get_capacity())

    print("\nPDF - clear example 2")
    print("---------------------")
    m = HashMap(53, hash_function_1)
    print(m.get_size(), m.get_capacity())
    m.put('key1', 10)
    print(m.get_size(), m.get_capacity())
    m.put('key2', 20)
    print(m.get_size(), m.get_capacity())
    m.resize_table(100)
    print(m.get_size(), m.get_capacity())
    m.clear()
    print(m.get_size(), m.get_capacity())

    print("\nPDF - find_mode example 1")
    print("-----------------------------")
    da = DynamicArray(["apple", "apple", "grape", "melon", "peach"])
    mode, frequency = find_mode(da)
    print(f"Input: {da}\nMode : {mode}, Frequency: {frequency}")

    print("\nPDF - find_mode example 2")
    print("-----------------------------")
    test_cases = (
        ["Arch", "Manjaro", "Manjaro", "Mint", "Mint", "Mint", "Ubuntu",
         "Ubuntu", "Ubuntu"],
        ["one", "two", "three", "four", "five"],
        ["2", "4", "2", "6", "8", "4", "1", "3", "4", "5", "7", "3", "3", "2"]
    )

    for case in test_cases:
        da = DynamicArray(case)
        mode, frequency = find_mode(da)
        print(f"Input: {da}\nMode : {mode}, Frequency: {frequency}\n")
