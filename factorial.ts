#!/home/azbyn/Projects/d_throwaway/throwaway_script
fun factorial(i) {
    i <= 1 ? 1 : i * factorial(i - 1);
}
println("6! = ", factorial(6));
