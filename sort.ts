#!/home/azbyn/Projects/qt_ts/qt_ts
sort = fun(data, cmp):
	size = data.Size()
	for a in range(1, size):
		for b in range(size - 1, a -1, -1):
			if cmp(data[b-1], data[b]):
				t = data[b-1]
				data[b-1] = data[b]
				data[b] = t
	return data
for a in range(7, 1, -1):
	println("a=", a)

d = [3, 54, 4, 0, 8, 65]
# not
sorted = sort(d, \ a b -> a > b)
println("s=", sorted)
println("d=", d)
