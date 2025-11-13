16. Module urmath
16.1. acos(f )
Returns the arc cosine of f
Returns the principal value of the arc cosine of f, expressed in radians. A runtime error is raised if f lies
outside the range [-1, 1].
Parameters
f: floating point value
Return Value
the arc cosine of f.
Example command: acos(0.707)
• Example Parameters:
• f is the cos of 45 deg. (.785 rad)
• Returns .785

16.2. asin(f )
Returns the arc sine of f
Returns the principal value of the arc sine of f, expressed in radians. A runtime error is raised if f lies
outside the range [-1, 1].
Parameters
f: floating point value
Return Value
the arc sine of f.
Example command: asin(0.707)
• Example Parameters:
• f is the sin of 45 deg. (.785 rad)
• Returns .785
16.3. atan(f )
Returns the arc tangent of f
Returns the principal value of the arc tangent of f, expressed in radians.
Parameters
e-Series 76 Script Directory
16. Module urmath
f: floating point value
Return Value
the arc tangent of f.
Example command: atan(1.)
• Example Parameters:
• f is the tan of 45 deg. (.785 rad)
• Returns .785
16.4. atan2(x, y)
Returns the arc tangent of x/y
Returns the principal value of the arc tangent of x/y, expressed in radians. To compute the value, the
function uses the sign of both arguments to determine the quadrant.
Parameters
x: floating point value
y: floating point value
Return Value
the arc tangent of x/y.
Example command: atan2(.5,.5)
• Example Parameters:
• x is the one side of the triangle
• y is the second side of a triangle
• Returns atan(.5/.5) = .785

16.5. binary_list_to_integer(l)
Returns the value represented by the content of list l
Returns the integer value represented by the bools contained in the list l when evaluated as a signed
binary number.
Parameters
l: The list of bools to be converted to an integer. The bool at index 0 is evaluated as the least significant
bit. False represents a zero and True represents a one. If the list is empty this function returns 0. If the list
contains more than 32 bools, the function returns the signed integer value of the first 32 bools in the list.
Return Value
The integer value of the binary list content.
Example command: binary_list_to_integer([True,False,False,True])
Script Directory 77 e-Series
16. Module urmath
• Example Parameters:
• l represents the binary values 1001
• Returns 9
16.6. ceil(f )
Returns the smallest integer value that is not less than f
Rounds floating point number to the smallest integer no greater than f.
Parameters
f: floating point value
Return Value
rounded integer
Example command: ceil(1.43)
• Example Parameters:
• Returns 2

16.7. cos(f )
Returns the cosine of f
Returns the cosine of an angle of f radians.
Parameters
f: floating point value
Return Value
the cosine of f.
Example command: cos(1.57)
• Example Parameters:
• f is angle of 1.57 rad (90 deg)
• Returns 0.0
16.8. d2r(d)
Returns degrees-to-radians of d
Returns the radian value of ’d’ degrees. Actually: (d/180)*MATH_PI
Parameters
e-Series 78 Script Directory
16. Module urmath
d: The angle in degrees
Return Value
The angle in radians
Example command: d2r(90)
• Example Parameters:
• d angle in degrees
• Returns 1.57 angle in radians
16.9. floor(f )
Returns largest integer not greater than f
Rounds floating point number to the largest integer no greater than f.
Parameters
f: floating point value
Return Value
rounded integer
Example command: floor(1.53)
• Example Parameters:
• Returns 1
16.10. make_list(length, initial_value, capacity=length)

Create a new list of length "length" with the initial value of each element given by "initial_value" and assign
it to a variable.
The "initial_value" sets the type of the list. It can be a complex type like struct. If not provided, the
"capacity" will be defaulted to "length".
Creation list of list with this function is not supported (they are matrices in URScript).
Parameters
length: Number of elements which will be initialized
initial_value: Initial value of the elements
capacity: Maximum number of elements. List can be extended and contracted between 0, and capacity
(Optional default value equals to length)
Example command 1: list_1 = make_list(5, "a")
Equivalent to ["a", "a", "a", "a", "a"]
Script Directory 79 e-Series
16. Module urmath
• Example Parameters:
• length = 5
• initial_value = "a"
• capacity = 5
Example command 2: list_2 = make_list(10, 0, 100)
• Example Parameters:
• length = 10
• initial_value = 0
• capacity = 100
Example command 3: list_3 = make_list(0, 0, 100)
Create an initially empty list with the potential to hold 100 elements of integers.
• Example Parameters:
• length = 0
• initial_value = 0
• capacity = 100

16.11. get_list_length(v)
Returns the length of a list variable
The length of a list is the number of entries the list is composed of.
Parameters
v: A list variable
Return Value
An integer specifying the length of the given list
Example command: get_list_length([1,3,3,6,2])
• Example Parameters:
• v is the list 1,3,3,6,2
• Returns 5
16.12. integer_to_binary_list(x)
Returns the binary representation of x
Returns a list of bools as the binary representation of the signed integer value x.
Parameters
x: The integer value to be converted to a binary list.
e-Series 80 Script Directory
16. Module urmath
Return Value
A list of 32 bools, where False represents a zero and True represents a one. The bool at index 0 is the
least significant bit.
Example command: integer_to_binary_list(57)
• Example Parameters:
• x integer 57
• Returns binary list
16.13. interpolate_pose(p_from, p_to, alpha)
Linear interpolation of tool position and orientation.
When alpha is 0, returns p_from. When alpha is 1, returns p_to. As alpha goes from 0 to 1, returns a pose
going in a straight line (and geodetic orientation change) from p_from to p_to. If alpha is less than 0,
returns a point before p_from on the line. If alpha is greater than 1, returns a pose after p_to on the line.
Parameters
p_from: tool pose (pose)
p_to: tool pose (pose)
alpha: Floating point number
Return Value
interpolated pose (pose)
Example command: interpolate_pose(p[.2,.2,.4,0,0,0], p[.2,.2,.6,0,0,0], .5)
• Example Parameters:
• p_from = p[.2,.2,.4,0,0,0]
• p_to = p[.2,.2,.6,0,0,0]
• alpha = .5
• Returns p[.2,.2,.5,0,0,0]

16.14. inv(m)
Get the inverse of a matrix or pose
The matrix must be square and non singular.
Parameters
m: matrix or pose (spatial vector)
Return Value
inverse matrix or pose transformation (spatial vector)
Example command:
Script Directory 81 e-Series
16. Module urmath
• inv([[0,1,0],[0,0,1],[1,0,0]])-> Returns [[0,0,1],[1,0,0],[0,1,0]]
• inv(p[.2,.5,.1,1.57,0,3.14])-> Returns p[0.19324,0.41794,-
0.29662,1.23993,0.0,2.47985]
16.15. length(v)
Returns the length of a list variable or a string
The length of a list or string is the number of entries or characters it is composed of.
Parameters
v: A list or string variable
Return Value
An integer specifying the length of the given list or string
Example command: length("here I am")
• Example Parameters:
• v equals string "here I am"
• Returns 9

16.16. log(b, f )
Returns the logarithm of f to the base b
Returns the logarithm of f to the base b. If b or f is negative, or if b is 1 a runtime error is raised.
Parameters
b: floating point value
f: floating point value
Return Value
the logarithm of f to the base of b.
Example command: log(10.,4.)
• Example Parameters:
• b is base 10
• f is log of 4
• Returns 0.60206
e-Series 82 Script Directory
16. Module urmath
16.17. norm(a)
Returns the norm of the argument
The argument can be one of four different types:
Pose: In this case the euclidian norm of the pose is returned.
Float: In this case fabs(a) is returned.
Int: In this case abs(a) is returned.
List: In this case the euclidian norm of the list is returned, the list elements must be numbers.
Parameters
a: Pose, float, int or List
Return Value
norm of a
Example command:
• norm(-5.3)-> Returns 5.3
• norm(-8)-> Returns 8
• norm(p[-.2,.2,-.2,-1.57,0,3.14])-> Returns 3.52768
16.18. normalize(v)

Returns the normalized form of a list of floats
Except for the case of all zeroes, the normalized form corresponds to the unit vector in the direction of v.
Throws an exception if the sum of all squared elements is zero.
Parameters
v: List of floats
Return Value
normalized form of v
Example command:
• normalize([1, 0, 0])-> Returns [1, 0, 0]
• normalize([0, 5, 0])-> Returns [0, 1, 0]
• normalize([0, 1, 1])-> Returns [0, 0.707, 0.707]
16.19. point_dist(p_from, p_to)
Point distance
Script Directory 83 e-Series
16. Module urmath
Parameters
p_from: tool pose (pose)
p_to: tool pose (pose)
Return Value
Distance between the two tool positions (without considering rotations)
Example command: point_dist(p[.2,.5,.1,1.57,0,3.14], p[.2,.5,.6,0,1.57,3.14])
• Example Parameters:
• p_from = p[.2,.5,.1,1.57,0,3.14] -> The first point
• p_to = p[.2,.5,.6,0,1.57,3.14] -> The second point
• Returns distance between the points regardless of rotation
16.20. pose_add(p_1, p_2)

Pose addition
Both arguments contain three position parameters (x, y, z) jointly called P, and three rotation parameters
(R_x, R_y, R_z) jointly called R. This function calculates the result x_3 as the addition of the given poses
as follows:
p_3.P = p_1.P + p_2.P
p_3.R = p_1.R * p_2.R
Parameters
p_1: tool pose 1(pose)
p_2: tool pose 2 (pose)
Return Value
Sum of position parts and product of rotation parts (pose)
Example command: pose_add(p[.2,.5,.1,1.57,0,0], p[.2,.5,.6,1.57,0,0])
• Example Parameters:
• p_1 = p[.2,.5,.1,1.57,0,0] -> The first point
• p_2 = p[.2,.5,.6,1.57,0,0] -> The second point
• Returns p[0.4,1.0,0.7,3.14,0,0]
16.21. pose_dist(p_from, p_to)
Pose distance
Parameters
p_from: tool pose (pose)
e-Series 84 Script Directory
16. Module urmath
p_to: tool pose (pose)
Return Value
distance
Example command: pose_dist(p[.2,.5,.1,1.57,0,3.14], p[.2,.5,.6,0,1.57,3.14])
• Example Parameters:
• p_from = p[.2,.5,.1,1.57,0,3.14] -> The first point
• p_to = p[.2,.5,.6,0,1.57,3.14] -> The second point
• Returns distance between two poses including rotation
16.22. pose_inv(p_from)
Get the inverse of a pose
Parameters
p_from: tool pose (spatial vector)
Return Value
inverse tool pose transformation (spatial vector)
Example command: pose_inv(p[.2,.5,.1,1.57,0,3.14])
• Example Parameters:
• p_from = p[.2,.5,.1,1.57,0,3.14] -> The point
• Returns p[0.19324,0.41794,-0.29662,1.23993,0.0,2.47985]
16.23. pose_sub(p_to, p_from)

Pose subtraction
Parameters
p_to: tool pose (spatial vector)
p_from: tool pose (spatial vector)
Return Value
tool pose transformation (spatial vector)
Example command: pose_sub(p[.2,.5,.1,1.57,0,0], p[.2,.5,.6,1.57,0,0])
• Example Parameters:
• p_1 = p[.2,.5,.1,1.57,0,0] -> The first point
• p_2 = p[.2,.5,.6,1.57,0,0] -> The second point
• Returns p[0.0,0.0,-0.5,0.0,.0.,0.0]
Script Directory 85 e-Series
16. Module urmath
16.24. pose_trans(p_from, p_from_to)

Pose transformation
The first argument, p_from, is used to transform the second argument, p_from_to, and the result is then
returned. This means that the result is the resulting pose, when starting at the coordinate system of p_
from, and then in that coordinate system moving p_from_to.
This function can be seen in two different views. Either the function transforms, that is translates and
rotates, p_from_to by the parameters of p_from. Or the function is used to get the resulting pose, when
first making a move of p_from and then from there, a move of p_from_to.
If the poses were regarded as transformation matrices, it would look like:
T_world->to = T_world->from * T_from->to T_x->to = T_x->from * T_from->to
Parameters
p_from: starting pose (spatial vector)
p_from_to: pose change relative to starting pose (spatial vector)
Return Value
resulting pose (spatial vector)
Example command: pose_trans(p[.2,.5,.1,1.57,0,0], p[.2,.5,.6,1.57,0,0])
• Example Parameters:
• p_1 = p[.2,.5,.1,1.57,0,0] → The first point
• p_2 = p[.2,.5,.6,1.57,0,0] → The second point
• Returns p[0.4,-0.0996,0.60048,3.14,0.0,0.0]
16.25. pow(base, exponent)
Returns base raised to the power of exponent
Returns the result of raising base to the power of exponent. If base is negative and exponent is not an
integral value, or if base is zero and exponent is negative, a runtime error is raised.
Parameters
base: floating point value
exponent: floating point value
Return Value
base raised to the power of exponent
Example command: pow(5.,3)
• Example Parameters:
• Base = 5
• Exponent = 3
• Returns 125.
e-Series 86 Script Directory
16. Module urmath
16.26. r2d(r)
Returns radians-to-degrees of r
Returns the degree value of ’r’ radians.
Parameters
r: The angle in radians
Return Value
The angle in degrees
Example command: r2d(1.57)
• Example Parameters:
• r 1.5707 rad
• Returns 90 deg
16.27. random()
Random Number
Return Value
pseudo-random number between 0 and 1 (float)
16.28. rotvec2rpy(rotation_vector)

Returns RPY vector corresponding to rotation_vector
Returns the RPY vector corresponding to ’rotation_vector’ where the rotation vector is the axis of rotation
with a length corresponding to the angle of rotation in radians.
Parameters
rotation_vector: The rotation vector (Vector3d) in radians, also called the Axis-Angle vector (unit-
axis of rotation multiplied by the rotation angle in radians).
Return Value
The RPY vector (Vector3d) in radians, describing a roll-pitch-yaw sequence of extrinsic rotations about the
X-Y-Z axes, (corresponding to intrinsic rotations about the Z-Y’-X” axes). In matrix form the RPY vector is
defined as Rrpy = Rz(yaw)Ry(pitch)Rx(roll).
Example command: rotvec2rpy([3.14,1.57,0])
• Example Parameters:
• rotation_vector = [3.14,1.57,0] -> rx=3.14, ry=1.57, rz=0
• Returns [-2.80856, -0.16202, 0.9] -> roll=-2.80856, pitch=-0.16202, yaw=0.9
Script Directory 87 e-Series
16. Module urmath
16.29. rpy2rotvec(rpy_vector)
Returns rotation vector corresponding to rpy_vector
Returns the rotation vector corresponding to ’rpy_vector’ where the RPY (roll-pitch-yaw) rotations are
extrinsic rotations about the X-Y-Z axes (corresponding to intrinsic rotations about the Z-Y’-X” axes).
Parameters
rpy_vector: The RPY vector (Vector3d) in radians, describing a roll-pitch-yaw sequence of extrinsic
rotations about the X-Y-Z axes, (corresponding to intrinsic rotations about the Z-Y’-X” axes). In matrix form
the RPY vector is defined as Rrpy = Rz(yaw)Ry(pitch)Rx(roll).
Return Value
The rotation vector (Vector3d) in radians, also called the Axis-Angle vector (unit-axis of rotation multiplied
by the rotation angle in radians).
Example command: rpy2rotvec([3.14,1.57,0])
• Example Parameters:
• rpy_vector = [3.14,1.57,0] -> roll=3.14, pitch=1.57, yaw=0
• Returns [2.22153, 0.00177, -2.21976] -> rx=2.22153, ry=0.00177, rz=-2.21976

16.30. sin(f )
Returns the sine of f
Returns the sine of an angle of f radians.
Parameters
f: floating point value
Return Value
the sine of f.
Example command: sin(1.57)
• Example Parameters:
• f is angle of 1.57 rad (90 deg)
• Returns 1.0
16.31. size(v)
Returns the size of a matrix variable, the length of a list or string variable
Parameters
v: A matrix, list or string variable
Return Value
e-Series 88 Script Directory
16. Module urmath
Given a list or a string the length is returned as an integer. Given a matrix the size is returned as a list of
two numbers representing the number of rows and columns, respectively.
Example command:
• size("here I am")-> Returns 9
• size([1,2,3,4,5])-> Returns 5
• size([[1,2],[3,4],[5,6]])-> Returns [3,2]
16.32. sqrt(f )
Returns the square root of f
Returns the square root of f. If f is negative, a runtime error is raised.
Parameters
f: floating point value
Return Value
the square root of f.
Example command: sqrt(9)
• Example Parameters:
• f = 9
• Returns 3

16.33. tan(f)
Returns the tangent of f
Returns the tangent of an angle of f radians.
Parameters
f: floating point value
Return Value
the tangent of f.
Example command: tan(.7854)
• Example Parameters:
• f is angle of .7854 rad (45 deg)
• Returns 1.0
Script Directory 89 e-Series
16. Module urmath
16.34. transpose(m)
Get the transpose of a matrix
Parameters
m: matrix or an array
Return Value
transposed matrix or array
Example command:
transpose([[1,2],[3,4],[5,6]])-> Returns [[1,3,5],[2,4,6]]
transpose([1,2,3])-> Returns [[1],[2],[3]]
transpose([[1],[2],[3]])-> Returns [1,2,3]

16.35. wrench_trans(T_from_to, w_from)
Wrench transformation
Move the point of view of a wrench.
Note: Transforming wrenches is not as trivial as transforming poses as the torque scales with the length of
the translation.
w_to = T_from->to * w_from
Parameters
T_from_to: The transformation to the new point of view (Pose)
w_from: wrench to transform in list format [F_x, F_y, F_z, M_x, M_y, M_z]
Return Value
resulting wrench, w_to in list format [F_x, F_y, F_z, M_x, M_y, M_z]