#heavily based on https://github.com/brianfrankcooper/YCSB/blob/master/core/src/main/java/com/yahoo/ycsb/generator/ZipfianGenerator.java
#from Yahoo YCSB
#by Rodrigo Dlugokenski
#same licence applies (Apache 2.0)

=begin
Quick and dirty test results:

irb(main):003:0> z = Zipfian.new 1000
=> #<Zipfian:0x00000000c4e988 @zetan=7.730023676840303, @theta=0.99, @count_for_zeta=1000, @zeta2theta=1.840493339007644, @alpha=99.99999999999991, @eta=0.07908405745594563, @items=1000, @last_value=137.2236300555702>
irb(main):027:0> a = Array.new(1000) {|i| i = 0}
irb(main):028:0> (1..10000).each do |i|
irb(main):029:1* a[z.next_value] += 1
irb(main):030:1> end
=> 1..10000
irb(main):031:0> a
=> [1322, 1109, 471, 350, 257, 232, 181, 154, 129, 103, 125, 117, 93, 90, 93, 66, 72, 72, 76, 53, 53, 46, 55, 51, 45, 36, 42, 46, 34, 37, 41, 38, 39, 30, 41, 38, 37, 30, 31, 30, 29, 22, 28, 30, 26, 28, 28, 28, 23, 31, 31, 22, 18, 20, 21, 28, 25, 21, 25, 14, 18, 18, 16, 17, 27, 24, 21, 13, 24, 10, 20, 11, 18, 21, 19, 20, 16, 21, 10, 13, 18, 15, 11, 9, 10, 14, 16, 11, 14, 14, 11, 8, 11, 15, 12, 9, 12, 11, 14, 8, 11, 10, 16, 11, 15, 19, 11, 9, 15, 9, 7, 5, 23, 5, 12, 13, 15, 16, 15, 12, 7, 15, 11, 13, 15, 10, 10, 12, 10, 6, 10, 9, 13, 12, 5, 9, 7, 14, 10, 11, 16, 9, 8, 10, 6, 13, 6, 8, 8, 7, 8, 11, 12, 9, 5, 5, 8, 7, 4, 6, 3, 11, 5, 7, 11, 7, 6, 12, 5, 5, 9, 5, 9, 5, 5, 4, 9, 7, 3, 7, 5, 5, 9, 8, 6, 5, 3, 3, 5, 3, 6, 5, 8, 8, 3, 4, 7, 4, 9, 6, 9, 6, 9, 9, 13, 2, 4, 4, 10, 9, 7, 7, 5, 3, 12, 9, 6, 7, 5, 3, 5, 5, 9, 4, 6, 5, 9, 9, 4, 7, 5, 3, 5, 11, 6, 3, 9, 6, 9, 6, 2, 5, 5, 5, 4, 6, 3, 2, 6, 2, 8, 5, 6, 6, 5, 1, 3, 9, 6, 4, 7, 6, 7, 7, 7, 6, 3, 4, 2, 8, 5, 5, 3, 7, 2, 3, 4, 5, 3, 7, 2, 3, 5, 5, 4, 6, 6, 7, 2, 6, 3, 4, 2, 0, 2, 3, 1, 5, 2, 2, 3, 2, 7, 0, 2, 4, 2, 2, 6, 2, 3, 4, 1, 5, 7, 6, 2, 3, 5, 6, 4, 5, 6, 4, 6, 3, 2, 5, 5, 6, 3, 2, 6, 3, 3, 3, 3, 10, 4, 3, 2, 1, 3, 2, 2, 3, 4, 5, 0, 4, 3, 6, 3, 4, 6, 2, 1, 2, 5, 4, 2, 1, 2, 3, 2, 5, 4, 3, 6, 1, 5, 3, 1, 1, 4, 3, 6, 5, 6, 3, 3, 9, 3, 2, 4, 3, 4, 3, 1, 3, 2, 1, 3, 2, 2, 3, 8, 1, 4, 2, 4, 4, 0, 7, 3, 5, 3, 4, 3, 2, 0, 3, 3, 3, 2, 6, 5, 3, 5, 2, 3, 4, 2, 0, 8, 2, 2, 7, 0, 3, 7, 3, 3, 2, 2, 0, 0, 2, 0, 5, 1, 4, 1, 4, 8, 3, 3, 0, 4, 3, 5, 3, 3, 1, 0, 4, 2, 4, 6, 5, 4, 2, 1, 3, 3, 2, 3, 2, 7, 0, 3, 0, 3, 4, 1, 3, 5, 6, 3, 2, 2, 0, 4, 4, 4, 6, 3, 0, 1, 4, 2, 1, 2, 7, 4, 4, 1, 2, 5, 3, 1, 3, 1, 1, 0, 2, 2, 3, 2, 3, 3, 0, 2, 2, 2, 3, 2, 1, 5, 1, 4, 2, 2, 3, 5, 4, 1, 4, 3, 2, 3, 3, 2, 2, 3, 1, 1, 2, 2, 6, 4, 2, 1, 1, 5, 2, 0, 2, 2, 3, 5, 1, 2, 1, 2, 3, 1, 0, 0, 4, 4, 4, 3, 1, 4, 2, 2, 3, 3, 5, 2, 3, 1, 3, 4, 2, 1, 3, 2, 1, 3, 2, 0, 1, 2, 0, 4, 5, 3, 5, 0, 2, 3, 1, 3, 2, 1, 2, 5, 2, 3, 1, 4, 3, 1, 1, 1, 3, 2, 1, 2, 4, 1, 2, 2, 2, 2, 3, 3, 3, 1, 3, 3, 1, 2, 6, 2, 2, 4, 2, 1, 3, 3, 2, 3, 1, 3, 4, 0, 5, 0, 1, 2, 1, 2, 0, 3, 1, 0, 1, 0, 1, 3, 4, 3, 1, 2, 2, 1, 1, 2, 4, 3, 1, 2, 1, 1, 3, 1, 2, 2, 3, 2, 1, 3, 1, 2, 1, 1, 3, 2, 0, 0, 2, 3, 1, 2, 0, 2, 2, 2, 0, 1, 2, 1, 0, 3, 2, 2, 3, 2, 1, 2, 6, 0, 1, 1, 3, 1, 2, 2, 0, 1, 3, 6, 1, 3, 3, 0, 1, 1, 3, 1, 0, 0, 2, 1, 4, 3, 1, 1, 1, 0, 1, 1, 1, 2, 3, 4, 2, 2, 1, 1, 2, 1, 3, 0, 1, 1, 2, 3, 1, 1, 2, 1, 0, 1, 1, 2, 1, 1, 0, 0, 1, 2, 1, 1, 4, 3, 2, 1, 4, 2, 1, 1, 1, 1, 2, 4, 4, 2, 3, 1, 3, 0, 0, 0, 2, 0, 2, 0, 0, 2, 3, 4, 1, 1, 3, 0, 0, 0, 1, 0, 0, 1, 1, 2, 4, 2, 2, 3, 5, 1, 3, 1, 2, 2, 0, 0, 1, 2, 0, 3, 0, 1, 4, 2, 0, 1, 1, 4, 1, 1, 3, 3, 1, 0, 0, 0, 1, 1, 3, 1, 1, 2, 4, 4, 2, 0, 1, 1, 2, 1, 2, 1, 0, 1, 1, 0, 1, 1, 1, 3, 2, 1, 3, 2, 2, 2, 0, 2, 3, 2, 3, 2, 3, 3, 2, 2, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 2, 2, 1, 0, 2, 3, 2, 1, 0, 2, 0, 2, 1, 3, 0, 2, 2, 2, 3, 2, 0, 1, 2, 0, 1, 4, 4, 1, 2, 0, 1, 4, 3, 0, 1, 0, 0, 1, 0, 2, 0, 2, 1, 2, 2, 1, 3, 1, 1, 0, 0, 2, 1, 1, 1, 2, 2, 0, 5, 3, 1, 0, 1, 1, 1, 2, 1, 2, 1, 2, 2, 1, 3, 2, 2, 2, 0, 1, 2, 0, 1, 2, 0, 2, 2, 1, 2, 0, 2, 1, 1, 0, 2, 1, 0, 1, 2, 3, 2, 0, 0, 2, 1, 1, 3, 0, 0, 2, 2, 2, 1, 0]

Looks like it follows the zipf's law!!!
=end
class Zipfian

  def initialize(num_items, z_constant = 0.99)
    @zetan = zetastatic(num_items,z_constant)
    @theta = z_constant
    @zeta2theta = zeta(2,@theta)
    @alpha = 1.0/(1.0-@theta)
    @count_for_zeta = num_items
    @eta = (1 - ((2.0 / num_items) ** (1 - @theta))) / (1 - @zeta2theta/@zetan)
    @items = num_items
    @last_value = 0
    next_value()
  end

=begin
  * @param n The number of items to compute zeta over.
  * @param theta The zipfian constant.
  * @param st The number of items used to compute the last initialsum
  * @param initialsum The value of zeta we are computing incrementally from.
=end
  def zeta(n, theta, st = 0, initialsum = 0)
    @count_for_zeta = n
    zetastatic(n,theta, st, initialsum)
  end

=begin
  * @param n The number of items to compute zeta over.
  * @param theta The zipfian constant.
  * @param st The number of items used to compute the last initialsum
  * @param initialsum The value of zeta we are computing incrementally from.
=end
  def zetastatic(n, theta, st = 0, initialsum = 0)
    (st..n).reduce(initialsum) do |sum, i|
      sum + 1 / ((i+1)**theta)
    end
  end

  #based on from "Quickly Generating Billion-Record Synthetic Databases", Jim Gray et al, SIGMOD 1994
  #removed the suport for a decreased num of items
  def next_value(num_items = @items)
    if(num_items > @items)
      @zetan = zeta(num_items, @theta, @count_for_zeta, @zetan)
      @eta = (1 - ((2.0 / num_items) ** (1 - @theta))) / (1 - @zeta2theta/@zetan)
    end

    u = rand()
    uz = u * @zetan

    if(uz < 1.0)
      return 0
    end

    if(uz < 1.0+(0.5**@theta))
      return 1
    end

    @last_value = (@items * ((@eta*u - @eta + 1) ** @alpha)).to_i
  end

  def last_value
    @last_value
  end
end
