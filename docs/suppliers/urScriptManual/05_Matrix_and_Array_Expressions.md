# 5. Matrix and Array Expressions

Matrix and array operations can be assigned to a variable to store and manipulate multiple numbers at the
same time. It is also possible to get access and write to a single entry of the matrix. The matrix and array are 0-
indexed.
array = [1,2,3,4,5]
a = array[0]
array[2] = 10
matrix = [[1,2],[3,4],[5,6]]
b = matrix[0,0]
matrix[2,1] = 20
Matrix and array can be manipulated by matrix-matrix, array-array,matrix-array,matrixscalar and array-scalar
operations.
Matrix-matrix multiplication operations are supported if the first matrix’s number of columns matches the
second matrix’s number of rows. The resulting matrix will have the dimensions of the first matrix number of
rows and the second matrix number of columns.
C = [[1,2],[3,4],[5,6]] * [[10,20,30],[40,50,60]]
Matrix-array multiplication operations are supported if the matrix is the first operand and array is second. If the
matrix’s number of columns matches the arrays length, the resulting array will have the length as the matrix
number of rows.
C = [[1,2],[3,4],[5,6]] * [10,20]
Array-array operations are possible if both arrays are of the same length and supports: addition, subtraction,
multiplication, division and modulo operations. The operation is executed index by index on both arrays and
thus results in an array of the same length. E.g. a[i] b[i] = c[i].
mul = [1,2,3] * [10,20,30]
div = [10,20,30] / [1,2,3]
add = [1,2,3] + [10,20,30]
sub = [10,20,30] - [1,2,3]
mod = [10,20,30] % [1,2,3]
Scalar operations on a matrix or an array are possible. They support addition, subtraction, multiplication,
division and modulo operations. The scalar operations are done on all the entries of the matrix or the array.
E.g. a[i] + b = c[i]
mul1 = [1,2,3] * 5
mul2 = 5 * [[1,2],[3,4],[5,6]]
div1 = [10,20,30] / 10
div2 = 10 / [10,20,30]
add1 = [1,2,3] + 10
add2 = 10 + [1,2,3]
sub1 = [10,20,30] - 5


5. Matrix and Array Expressions
sub2 = 5 - [[10,20],[30,40]]
mod1 = [11,22,33] % 5
mod2 = 121 % [[10,20],[30,40]]