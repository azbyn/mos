#!/home/azbyn/Projects/qt_ts/qt_ts
struct X:
	#this.member = 4
	val = 5

	#.staticMember = 8
	#.var = 85
	#.var2 = 879
	#fun .a(): 1
	#fun .b(): 2
	#fun .c(): 3

	#this(x): println("arg:", x)
	this(k): this.val = k
	fun toString(): this.val.toString()
	#fun .static(x): x+4
	fun member(): this.val
	#fun this.alsoMember(): this.val
	#fun X.toBeImplemented(x="4"): x

#println(X.a())
#println(X.var)
#println(X.var2)
x = X(747)
#println(x)
println(x.member())

#println(X.static(0))
<<<
capture = "k"
kp = "kp"
<<<
fun addAll(a, args...):
	res = a
	for i in args:
		res += i
	return res
v = addAll(3, 1, 3, 5)
println(v)
v = (3, 1, 3, 5)
println(v)
iter = v.Iter
println(v.Iter)
for i in v:
	print(i~" ")
#println(v)

>>>
<<<
fun f[capture](var):
	module Foo[capture]:
		struct X:
			fun ctor(this): this.base = 4
			fun toString(this): this.base.toString()

		fun static(): 8
		fun static2(): Foo.X(Foo.static() +2)
		staticThing = Foo.static2()
		k = capture

	Console.setAttr(Attr.Bold, Color.Green)
	println(Console.Flags)
	Console.Fg = Color.Orange
	Console.Flags = Attr.Underline
	println(Foo.staticThing)
	println(var)
	Console.setAttr()
	Console.putnl()
f(98)
>>>
<<<
prop Pi(): Math.Pi
prop Pi=(x): Math.Pi = x
import Math : cos, Pi
println(cos(Pi))

println(hash(5))
println(hash(95))
println(kp)
println(Pi)
>>>
#println("k")

