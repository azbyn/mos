#!/home/azbyn/Projects/qt_ts/qt_ts
struct Foo(dict):
	fun ctor(this, val):
		println("ctor w ", type(this))
		this.base["whatever"] = val

	prop Val(this): return this.base["whatever"]
	prop Val=(this, val): this.base["whatever"] = val

	fun doSmth(this):
		println("do smth", this.Val)
	fun toString(this):
		return this.Val.toString()

	staticThing = 56
foo = Foo(5)
println(foo)
Foo.doSmth(foo)
println(Foo.staticThing)
#dict = { }
#dict["ja"] = 1
#println(dict["ja"])

#Tuple.

#a = 4

#if a == 1:
#	println("a is 1")
#elif a < 4:
#	println("a < 4")
#elif a < 16:
#	println("a < 16")
#elif a < 32:
#	println("a < 32")
#else:
#	println("a is >=4")
#prop X(): 45
#prop X=(v):
#	println("setting x to:", v)

#for i in (1,5,56,98):
#	println(i);
#prop x=(v): thing = v
#tpl = (1, 3, 4)
#println("asin(1)", cos(Pi))
#tpl.Test = 9
#tpl2 = tuple(tpl)
#println("x:", tuple.toBool(tpl2))
#printfln("sz: @, [0]: @, Tail: @", tpl.Size, tpl[0], tpl.Tail)
#X = 5
#printfln("x: @", X)
#for i in range(10):
#	printred("a", i, "#n")
#	println("other")
