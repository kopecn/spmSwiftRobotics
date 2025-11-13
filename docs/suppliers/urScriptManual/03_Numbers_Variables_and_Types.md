4.1. Struct
A set of variables can be aggregated into structs, and thus transferred and stored as a single variable.
Structs can be obtained through multiple means:
• Using the struct function
• Doing an RPC call that returns a struct
• Receiving ROS2 message (available on Polyscope X only)
The struct function takes one or more named arguments, and each argument name becomes a member in the
struct. All values must be initialized by value, and the type of the value cannot be changed subsequently.

4.1.1. Using a struct
Create a struct:
myStruct = struct(identifier1 = 1, identifier2 = 2, myMember = "Hello structs",
listMember = [1,2,3])
Reassign a member:
myStruct.myMember = "Goodbye structs"
Use a member:
myVar = myStruct.myMember
Use a nested list:
myListElement = myStruct.listMember[0]
Use the second member by index (identifier2):
myVar = myStruct[1]
A nested struct, stored by value:
myStruct = struct(myStructMember = struct(myMember = "Hi nested struct") )
Conversion of a struct to a list, if all the struct members are of same type and if the list has the same type.
Value of myList will be [1.1, 2.2, 3.3, 4.4].
myStruct = struct(m1 = 1.1, m2 = 2.2, m3 = 3.3, m4 = 4.4)
myList = [0.0, 0.0, 0.0, 0.0]
myList = myStruct
Structs can be passed to and returned from function. In this example we create a new struct extended with a
boolean member.
struct_1 = struct(m1 = 1.1, m2="a string", m3=[1,2,3])
def ExtendStructWithBoolMember(struct_arg):
struct_local = struct(m1 = 0.0, m2 = "n/a", m3 = make_list(0, 0, 10), extra_
member = False)
struct_local.m1 = struct_arg.m1
struct_local.m2 = struct_arg.m2

4. Lists and Structs
struct_local.m3 = struct_arg.m3
struct_local.extra_member = True
return struct_local
end
new_extended_struct = ExtendStructWithBoolMember(struct_1)
4.2. List
A list is a set of variables with the same type aggregated into a single object.
A list object in URScript has two attributes: length and capacity. The length indicates how many elements the
list currently holding. The capacity tells how many elements the list can hold maximum.
Once declared, the capacity of the list cannot be changed.
Fixed length lists can be created with square bracket operator:
aa = [11, 22, 33, 44, 55, 66, 77]
Both length and capacity of this list is equal to 7.
Variable length lists can be created:
bb = make_list(length = 7, initial_value = 11, capacity = 20)
Length of this list is 7, but capacity is 20. List can be extended and contracted between 0, and 20 numeric
elements.
Lists can hold any type that URScript supports. This includes complex values created with struct() keyword:
aa = [1, 2, 3.5, 4, 5.5]
bb = make_list(10, struct(p1 = 1, p2 = "text"), 10)
cc = ["a", "b", "c", "d"]
dd = [struct(m1 = 10, m2 = "hello", m3 = make_list(length = 25, initial_value
= 0, capacity = 100)) , struct(m1 = 20, m2 = "hi", m3 = make_list(length = 50,
initial_value = 0, capacity = 100))]
List can be assigned only to existing list of greater or equal capacity to the length of source list:
aa = [1, 2, 3, 4, 5, 6] # aa.length() == 6, aa.capacity() == 6
bb = make_list(5, 0, 100) # bb.length() == 5, bb.capacity() == 100
aa = bb # aa capacity will remain 6 aa length will be 5
aa = [1, 2, 3, 4, 5, 6]
bb = aa # bb capacity will remain 100 bb length will be 6
List can hold structs (aka complex data types). All structs in the list have to be exactly of the same type:
aa = make_list(10, struct(p1 = 1, p2 = "text"), 10)
a = aa[4].p1 # a = 1
b = aa[4].p2 # b = "text"
aa[3].p1 = 22.5
aa[4] = struct(p1 = 99, p2 = "different text")

4.2.1. Limitations of lists
Lists can be passed to, and returned from functions only as copy by value.
List elements can't change type.

4. Lists and Structs
If list is returned from a function or list method, then the target list have to be earlier initialized with enough
capacity.
List of lists is not supported as this is how matrices are implemented in URScript.
4.3. Methods in URScript
Starting from Polyscope 5.15, methods (member functions) are callables on list, matrix and structs (currently).
The name of the list followed by a "." will invoke the function.
4.3.1. Methods on List
append(element)
Adds the element to the end of the list. Raises an error if at capacity.
Example: add the value 88 to a list.
l1 = make_list(0, 0, 10) # empty list of integers with capacity of 10
l1.append(88) # add element to the end of the list, length increases, exception
thrown if capacity exceeded

capacity()
Returns the maximum capacity of the list (>=length).
Example: merge list 2 to list 1 until list 1 is full. result: [-1, -1, -1, -1, -1, 6, 7, 8, 9, 10]
l1 = make_list(5, -1, 10)
l2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
idx = l1.length()
while(idx < l1.capacity()):
l1.append(l2[idx])
idx = idx + 1
end
clear()
Clear the list by setting length to 0.
list_1.clear() # list_1 will be []
excess_capacity()
Returns the unused capacity (= capacity-length).
Example: add element if the list has free space. result: [9,9,9,9,9,1,2,3,4,5]; popup "no more space"
l1 = make_list(5, 9, 10)
l2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
idx = 0
while(idx < l2.length()):
if(l1.excess_capacity() > 0):
l1.append(l2[idx])

4. Lists and Structs
else:
popup("no more space")
break
end
idx = idx + 1
end
extend(list of elements)
Adds all elements from the parameter list at the end. Raises an error if at capacity. The list in the input must be
of the same type as the list.
Example: add list 2 to list 1. result = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
l1 = make_list(2, 0, 100)
l2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
if l1.excess_capacity() >= l2.length():
l1.extend(l2)
end
insert(index, element)
Inserts the element at the given index, shifting remaining list. Raises an error if at capacity.
length()
Returns the current length of the list.
Example: update elements of a list in a loop
l1 = [1, 2, 3, 4, 5, 6]
idx = 0
while (idx < l1.length()):
l1[idx] = 10 + idx
idx = idx + 1
end

pop()
Removes the last element from the list.
remove(index)
Removes the element at a given index.
Example: remove even numbers from a collection.
l2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]
idx = l2.length() - 1
while(idx > 0):
if(l2[idx] % 2 == 0):
l2.remove(idx)
end
idx = idx - 1

4. Lists and Structs
end
slice(begin index, end index)
Returns a sub-list of elements [list[param1]... list[param2-1]]. Does not modify the original list.
to_string()
Returns a string representation of the list. has ...] if out of space.
4.3.2. Methods on Struct
length()
Returns the number of elements in the struct.

to_string()
Returns a string representation of the struct. has ...} if out of space.
4.3.3. Methods on Matrix
get_column(index)
Returns the column at the index by value.
get_row(index)
Returns the row at the index by value.
shape()
Returns the number of rows and columns in the matrix.
to_string()
Returns a string representation of the list. has ...] if out of space.