# 7. Function

A function is declared as follows:
def add(a, b):
return a+b
end
The function can then be called like this:
result = add(1, 4)
It is also possible to give function arguments default values:
def add(a=0,b=0):
return a+b
end
If default values are given in the declaration, arguments can be either input or skipped as below:
result = add(0,0)
result = add()
When calling a function, it is important to comply with the declared order of the ar- guments. If the order is
different from its definition, the function does not work as ex- pected.
Arguments can only be passed by value (including arrays). This means that any modi- fication done to the
content of the argument within the scope of the function will not be reflected outside that scope.
def myProg()
a = [50,100]
fun(a)
def fun(p1):
p1[0] = 25
assert(p1[0] == 25)
...
end
assert(a[0] == 50)
...
end
URScript also supports named parameters.
