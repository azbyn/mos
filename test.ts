#!/home/azbyn/Projects/qt_ts/qt_ts
capture = "k"
kp = "kp"
module Foo[capture]:
	fun static(): 4
	fun static2(): Foo.static() +2
	staticThing = Foo.static2()
	k = capture


println(color)
println(color.Base00)
println(Foo.static())
println(Foo.static2())
console.setAttr(Attr.Bold, color.Green)
console.Fg = color.Orange
println(Foo.k)
console.setAttr()
console.puts("k")

#dict = { "k": 1 }
#dict["ja"] = 1
#println(dict["k"])

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
