# 6. Flow of Control

The flow of control of a program is changed by if-statements:
if a > 3:
a = a + 1
elif b < 7:
b = b * a
else:
a = a + b
end
and while-loops:
l = [1,2,3,4,5]
i = 0
while i < 5:
l[i] = l[i]*2
i = i + 1
end
You can use break to stop a loop prematurely and continue nearest enclosing loop.
to pass control to the next iteration of the
6.1. Special keywords
• halt immediately stops program execution and terminates the program. Not advisible while robot is in
motion.
• return returns from a function. When no value is returned, the keyword None must follow the keyword
return.
• pause pauses program execution.