# Name:         Josh Goben
# OSU Email:    gobenj@oregonstate.edu
# Course:       CS261 - Data Structures
# Assignment:   Assignment 6
# Due Date:     07 December 2023
# Description:  Defines a HashMap class with associated methods for adding,
# removing, resizing, and getting values. Also contains methods to check if a
# key is present, to get all keys and values and to clear the HashMap entirely.
# Elements in HashMaps with this implementation are iterable.

from a6_include import (DynamicArray, DynamicArrayException, HashEntry,
                        hash_function_1, hash_function_2)


class HashMap:
    def __init__(self, capacity: int, function) -> None:
        """
        Initialize new HashMap that uses
        quadratic probing for collision resolution
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        self._buckets = DynamicArray()

        # capacity must be a prime number
        self._capacity = self._next_prime(capacity)
        for _ in range(self._capacity):
            self._buckets.append(None)

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
        Increment from given number to find the closest prime number
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
        Receives a key and value then adds the key/value pair to the HashMap.
        Replaces an existing value if the key already exists in the HashMap.
        Will perform a resize of the underlying DynamicArray() if the load
        factor is equal to or greater than 0.5.
        """
        # check for load factor >= 1 and resize if necessary
        if self.table_load() >= 0.5:
            # doubles current capacity then resizes
            self.resize_table(self._capacity * 2)

        # get the target key index
        key_index = self._hash_index(key)
        initial_index = key_index

        # check if we need to update an existing key
        # without this, we could overwrite a tombstone when we should be
        # updating an existing key, then end up with duplicate keys
        replace = self.contains_key(key)

        # iterate until we find an available node, or we find our key
        # quadratic probe formula:
        # i = (initial_index + j ** 2) % m; j+=1, m=length of arr
        hash_entry = self._buckets.get_at_index(key_index)
        j = 1
        while hash_entry:
            if hash_entry.is_tombstone and not replace:  # found a TS entry
                hash_entry.key = key
                hash_entry.value = value
                hash_entry.is_tombstone = False
                self._size += 1
                return
            elif hash_entry.key == key:  # update existing key
                hash_entry.value = value
                return
            key_index = (initial_index + j ** 2) % self._capacity
            hash_entry = self._buckets.get_at_index(key_index)
            j += 1

        # store the key/value as a HashEntry() object in the array
        self._buckets.set_at_index(key_index, HashEntry(key, value))
        self._size += 1

    def resize_table(self, new_capacity: int) -> None:
        """
        Resizes the current HashMap. Will accept an integer value which must
        be greater than the current size of the HashMap. If the integer is not
        already prime, then the next largest prime number will be selected.

        If an invalid (too small) integer is provided, then method returns
        immediately and does nothing.

        The smallest table size we can ever have is 3, per the __init__ method,
        so this resize method handles any new_capacity value of 3 or greater.
        """
        # stop if new_cap is less than current_size
        if new_capacity < self._size:
            return

        # if not prime change to the next highest prime number
        if not self._is_prime(new_capacity):
            new_capacity = self._next_prime(new_capacity)

        '''
        while self._size / new_capacity > 0.5:
            new_capacity = self._next_prime(new_capacity * 2)
        '''

        new_map = HashMap(new_capacity, self._hash_function)

        for index in range(self._capacity):
            hash_element = self._buckets.get_at_index(index)
            if hash_element and not hash_element.is_tombstone:
                new_map.put(hash_element.key, hash_element.value)

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
        Returns the current number of empty buckets in the HashMap.
        """
        return self._capacity - self._size

    def get(self, key: str) -> object:
        """
        Receives a key then returns its value if it is in the HashMap. If not,
        then returns None.
        """
        # get our starting index
        key_index = self._hash_index(key)
        initial_index = key_index

        # iterate through buckets, using quadratic probing if necessary
        hash_entry = self._buckets.get_at_index(key_index)
        j = 1
        while hash_entry:
            if hash_entry.key == key and not hash_entry.is_tombstone:
                return hash_entry.value
            else:  # quadratic probe until we find the key or an empty spot
                key_index = (initial_index + j ** 2) % self._capacity
                hash_entry = self._buckets.get_at_index(key_index)
                j += 1

        return None

    def contains_key(self, key: str) -> bool:
        """
        Receives a key then returns True if it is in the HashMap. If not,
        then returns False.
        """
        # get our starting index
        key_index = self._hash_index(key)
        initial_index = key_index

        # iterate through buckets, using quadratic probing if necessary
        hash_entry = self._buckets.get_at_index(key_index)
        j = 1
        while hash_entry:
            if hash_entry.key == key and not hash_entry.is_tombstone:
                return True
            else:  # quadratic probe until we find the key or an empty spot
                key_index = (initial_index + j ** 2) % self._capacity
                hash_entry = self._buckets.get_at_index(key_index)
                j += 1

        return False

    def remove(self, key: str) -> None:
        """
        Receives a key then removes it if it is in the HashMap. If not,
        then no changes are made to the HashMap.
        """
        # get our starting index
        key_index = self._hash_index(key)
        initial_index = key_index

        # iterate through buckets, using quadratic probing if necessary
        hash_entry = self._buckets.get_at_index(key_index)
        j = 1
        while hash_entry:
            if hash_entry.key == key and not hash_entry.is_tombstone:
                hash_entry.is_tombstone = True
                self._size -= 1
                return
            else:  # quadratic probe until we find the key or an empty spot
                key_index = (initial_index + j ** 2) % self._capacity
                hash_entry = self._buckets.get_at_index(key_index)
                j += 1

    def get_keys_and_values(self) -> DynamicArray:
        """
        Returns a DynamicArray which contains every key/value pair in the
        HashMap. Each element in the DynamicArray will be a tuple consisting
        of the key and value.
        """
        hash_map_array = DynamicArray()

        for element in range(self._capacity):
            hash_entry = self._buckets.get_at_index(element)
            if hash_entry and not hash_entry.is_tombstone:
                hash_map_array.append((hash_entry.key, hash_entry.value))

        return hash_map_array

    def clear(self) -> None:
        """
        Clears the entire HashMap of all keys and values. The capacity of the
        HashMap is not changed.
        """
        new_map = HashMap(self._capacity, self._hash_function)

        self._buckets = new_map._buckets
        self._size = 0

    def __iter__(self):
        """
        Defines the starting index to be used in the __next__ method.
        """
        self._index = 0

        return self

    def __next__(self):
        """
        Starts with the index provided in the self_index variable initialized
        by the __iter__ method.

        Iterates through the HashMap contents until finding an active element.
        Empty array nodes and element with tombstone values are passed over.
        """
        # handle a DynamicArray of size=0
        try:
            hash_entry = self._buckets.get_at_index(self._index)
        except DynamicArrayException:
            raise StopIteration

        # iterate through array until we find an active HashMap element
        while hash_entry is None or hash_entry.is_tombstone:
            self._index += 1
            try:
                hash_entry = self._buckets.get_at_index(self._index)
            except DynamicArrayException:
                raise StopIteration

        self._index += 1
        return hash_entry


# ------------------- BASIC TESTING ---------------------------------------- #

if __name__ == "__main__":

    print("\nPDF - put example 1")
    print("-------------------")
    m = HashMap(53, hash_function_1)
    for i in range(150):
        m.put('str' + str(i), i * 100)
        if i % 25 == 24:
            print(m.empty_buckets(), round(m.table_load(), 2), m.get_size(), m.get_capacity())

    print("\nPDF - put example 2")
    print("-------------------")
    m = HashMap(41, hash_function_2)
    for i in range(50):
        m.put('str' + str(i // 3), i * 100)
        if i % 10 == 9:
            print(m.empty_buckets(), round(m.table_load(), 2), m.get_size(), m.get_capacity())

    print("\nPDF - resize example 1")
    print("----------------------")
    m = HashMap(20, hash_function_1)
    m.put('key1', 10)
    print(m.get_size(), m.get_capacity(), m.get('key1'), m.contains_key('key1'))
    m.resize_table(30)
    print(m.get_size(), m.get_capacity(), m.get('key1'), m.contains_key('key1'))

    print("\nPDF - resize example 2")
    print("----------------------")
    m = HashMap(75, hash_function_2)
    keys = [i for i in range(25, 1000, 13)]
    for key in keys:
        m.put(str(key), key * 42)
    print(m.get_size(), m.get_capacity())

    for capacity in range(111, 1000, 117):
        m.resize_table(capacity)

        if m.table_load() > 0.5:
            print(f"Check that the load factor is acceptable after the call to resize_table().\n"
                  f"Your load factor is {round(m.table_load(), 2)} and should be less than or equal to 0.5")

        m.put('some key', 'some value')
        result = m.contains_key('some key')
        m.remove('some key')

        for key in keys:
            # all inserted keys must be present
            result &= m.contains_key(str(key))
            # NOT inserted keys must be absent
            result &= not m.contains_key(str(key + 1))
        print(capacity, result, m.get_size(), m.get_capacity(), round(m.table_load(), 2))

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
    m = HashMap(11, hash_function_1)
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

    m.resize_table(2)
    print(m.get_keys_and_values())

    m.put('20', '200')
    m.remove('1')
    m.resize_table(12)
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

    print("\nPDF - __iter__(), __next__() example 1")
    print("---------------------")
    m = HashMap(10, hash_function_1)
    for i in range(5):
        m.put(str(i), str(i * 10))
    print(m)
    for item in m:
        print('K:', item.key, 'V:', item.value)

    print("\nPDF - __iter__(), __next__() example 2")
    print("---------------------")
    m = HashMap(10, hash_function_2)
    for i in range(5):
        m.put(str(i), str(i * 24))
    m.remove('0')
    m.remove('4')
    print(m)
    for item in m:
        print('K:', item.key, 'V:', item.value)
