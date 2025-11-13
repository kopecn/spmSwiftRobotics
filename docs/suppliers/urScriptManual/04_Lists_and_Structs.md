# 4. Lists and Structs

## 4.1 Struct

A set of variables can be aggregated into structs, and thus transferred and stored as a single variable.

Structs can be obtained through multiple means:

- Using the `struct()` function  
- Doing an RPC call that returns a struct  
- Receiving ROS2 message (available on Polyscope X only)

The `struct()` function takes one or more named arguments, and each argument name becomes a member in the struct. All values must be initialized by value, and the type of the value cannot be changed subsequently.

### 4.1.1 Using a struct

**Create a struct:**

```python
myStruct = struct(identifier1 = 1, identifier2 = 2, myMember = "Hello structs", listMember = [1,2,3])
```

**Reassign a member:**

```python
myStruct.myMember = "Goodbye structs"
```

**Use a member:**

```python
myVar = myStruct.myMember
```

**Use a nested list:**

```python
myListElement = myStruct.listMember[0]
```

**Use the second member by index (identifier2):**

```python
myVar = myStruct[1]
```

**A nested struct, stored by value:**

```python
myStruct = struct(myStructMember = struct(myMember = "Hi nested struct"))
```

**Conversion of a struct to a list**, if all the struct members are of same type and if the list has the same type.  
Value of `myList` will be `[1.1, 2.2, 3.3, 4.4]`.

```python
myStruct = struct(m1 = 1.1, m2 = 2.2, m3 = 3.3, m4 = 4.4)
myList = [0.0, 0.0, 0.0, 0.0]
myList = myStruct
```

Structs can be passed to and returned from functions. In this example we create a new struct extended with a boolean member.

```python
struct_1 = struct(m1 = 1.1, m2="a string", m3=[1,2,3])

def ExtendStructWithBoolMember(struct_arg):
    struct_local = struct(m1 = 0.0, m2 = "n/a", m3 = make_list(0, 0, 10), extra_member = False)
    struct_local.m1 = struct_arg.m1
    struct_local.m2 = struct_arg.m2
    struct_local.m3 = struct_arg.m3
    struct_local.extra_member = True
    return struct_local
end

new_extended_struct = ExtendStructWithBoolMember(struct_1)
```

## 4.2 List

A list is a set of variables with the same type aggregated into a single object.

A list object in URScript has two attributes: **length** and **capacity**. The length indicates how many elements the list currently holds. The capacity tells how many elements the list can hold maximum. Once declared, the capacity of the list cannot be changed.

**Fixed length list:**

```python
aa = [11, 22, 33, 44, 55, 66, 77]
```

**Variable length list:**

```python
bb = make_list(length = 7, initial_value = 11, capacity = 20)
```

**Lists with structs:**

```python
aa = [1, 2, 3.5, 4, 5.5]
bb = make_list(10, struct(p1 = 1, p2 = "text"), 10)
cc = ["a", "b", "c", "d"]
dd = [struct(m1 = 10, m2 = "hello"), struct(m1 = 20, m2 = "hi")]
```

**Limitations:**
- Lists are passed by value.
- List elements can't change type.
- List of lists is not supported.

## 4.3 Methods in URScript

Starting from Polyscope 5.15, methods (member functions) are callables on list, matrix, and structs.

### 4.3.1 Methods on List

- `append(element)` – Adds element to the end of list.  
- `capacity()` – Returns maximum capacity.  
- `clear()` – Clears all elements.  
- `excess_capacity()` – Returns unused capacity.  
- `extend(list)` – Appends all elements of another list.  
- `insert(index, element)` – Inserts element at index.  
- `length()` – Returns current length.  
- `pop()` – Removes last element.  
- `remove(index)` – Removes element at index.  
- `slice(begin, end)` – Returns sub-list.  
- `to_string()` – Returns string representation.

### 4.3.2 Methods on Struct

- `length()` – Returns number of elements.  
- `to_string()` – Returns string representation.

### 4.3.3 Methods on Matrix

- `get_column(index)` – Returns column.  
- `get_row(index)` – Returns row.  
- `shape()` – Returns number of rows and columns.  
- `to_string()` – Returns string representation.
