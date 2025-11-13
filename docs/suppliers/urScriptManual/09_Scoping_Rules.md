# 9. Scoping Rules

A URScript program is declared as a function without parameters:
def myProg():
end
Every variable declared inside a program has a scope. The scope is the textual region where the variable is
directly accessible. Two qualifiers are available to modify this visibility:
• local qualifier tells the controller to treat a variable inside a function, as being truly local, even if a
global variable with the same name exists.
• global qualifier forces a variable declared inside a function, to be globally accessible.
For each variable the controller determines the scope binding, i.e. whether the variable is global or local. In
case no local or global qualifier is specified (also called a free variable), the controller will first try to find the
variable in the globals and otherwise the variable will be treated as local.
In the following example, the first a is a global variable and the second a is a local variable. Both variables are
independent, even though they have the same name:
def myProg():
global a = 0
def myFun():
local a = 1

...
end
...
end
Beware that the global variable is no longer accessible from within the function, as the local variable masks the
global variable of the same name.
In the following example, the first a is a global variable, so the variable inside the function is the same variable
declared in the program:
def myProg():
global a = 0
def myFun():
a = 1
...
end
...
end
For each nested function the same scope binding rules hold. In the following example, the first a is global
defined, the second local and the third implicitly global again:

9. Scoping rules
def myProg():
global a = 0
def myFun():
local a = 1
def myFun2():
a = 2
...
end
...
end
...
end
The first and third a are one and the same, the second a is independent.
Variables on the first scope level (first indentation) are treated as global, even if the global qualifier is
missing or the local qualifier is used:
def myProg():
a = 0
def myFun():
a = 1
...
end
...
end

The variables a are one and the same.