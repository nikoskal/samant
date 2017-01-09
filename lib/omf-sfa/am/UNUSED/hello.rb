=begin

print "Hello, World!\n"
puts "Hello, Ruby!";


print <<EOF
    This is the first way of creating
    here document ie. multiple line string.
EOF


print <<"foo"  # you can stack them
  I said foo.
foo
  #I said bar.
  #bar

=end

class Customer
  @@no_of_customers=0 #class variable, cannot be uninitialized
  VAR = 200 #constant
  def initialize(id, name, addr) #local variables
    @@no_of_customers += 1
    @cust_id=id #instance variable, nil when uninitialized
    @cust_name=name
    @cust_addr=addr
  end

  def display_details()
    puts "Customer id #@cust_id"
    puts "Customer name #@cust_name"
    puts "Customer address #@cust_addr"
  end

  def total_no_of_customers()
    puts "Total number of customers: #@@no_of_customers"
  end
end

# Create Objects
cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
cust2=Customer.new("2", "Poul", "New Empire road, Khandala")

=begin
# Call Methods
cust1.display_details()
cust1.total_no_of_customers()
cust2.display_details()
cust2.total_no_of_customers()
=end

#array
ary = ["fred", 10, 3.14, "This is a string", "last element",]
ary.each do |i|
  #puts i
end

#hash
hsh = colors = {"red" => 345, "green" => 0x0f0, "blue" => 0x00f}
hsh.each do |key, value|
  #print key, " is ", value, "\n"
end

=begin
#parallel assignment
a, b, c = 10, 20, 30
puts a ,b, c
a, b = b, c
puts a ,b, c

VAR = 100
CONST = proc {' in there'}
puts ::VAR #If no prefix expression is used, the main Object class is used by default.
puts Customer::VAR
puts CONST.call
=end

CONST = ' out there'
class Inside_one
  CONST = proc { ' in there' }

  def where_is_my_CONST
    ::CONST + ' inside one'
  end
end
class Inside_two
  CONST = ' inside two'

  def where_is_my_CONST
    CONST
  end
end

#puts Inside_one::CONST.call + Inside_two::CONST

foo=42
#puts defined? Inside_one.new.where_is_my_CONST

#if-elsif-else
x=0
if x > 2 then #optional
  puts "x is greater than 2"
elsif x <= 2 and x!=0
  puts "x is 1"
else
  puts "I can't guess the number"
end

#unless-else
unless x>2
  puts "x is less than 2"
else
  puts "x is greater than 2"
end

#case
$age = 6
case $age
  when 0 .. 2
    puts "baby"
  when 3 .. 6
    puts "little child"
  when 7 .. 12
    puts "child"
  when 13 .. 18
    puts "youth"
  else
    puts "adult"
end

#while loop
$i = 0
$num = 5

while $i < $num do
  #puts("Inside the loop i = #$i" )
  $i +=1
end

#8a ektelestei mia fora toulaxiston
$i = 0
$num = 5
begin
  #puts("Inside the loop i = #$i" )
  $i +=1
end while $i < $num

#until loop
$i = 0
$num = 5
until $i > $num do
  #puts("Inside the loop i = #$i" )
  $i +=1;
end

#for -> doesnt create a new scope for local variables (sto telos to i 8a exei timi 5)
i=7
for i in 0..5
  puts "Value of local variable is #{i}"
end


#sto telos to b den uparxei
(0..5).each do |b|
  puts "Value of local variable is #{b}"
end

#pws xrisimopoioume to rescue
begin
  for i in 1..5
    puts "Value of local variable is #{i}"
    raise if i > 2
  end
rescue
  #retry
end

def test(a1="Ruby", a2="Perl")
  #puts "The programming language is #{a1}"
  #puts "The programming language is #{a2}"
  return 42, "the sun"
end

var = test "C", "C++"
#puts var

def sample (*test) #variable parameters number
  #puts "The number of parameters is #{test.length}"
  for i in 0...test.length
    #puts "The parameters are #{test[i]}"
  end
end

sample "Zara", "6", "F"
sample "Mac", "36", "M", "MCA"

class Accounts
  def reading_charge
    puts "kalispera"
  end

  def Accounts.return_date
    puts "gamiesai"
  end
end

acc = Accounts.new
#acc.reading_charge
#Accounts.return_date
#acc.return_date cannot acces it like that. only in a static way

#modules, omadopoioun sta8eres/sunartiseis/klaseis
module Trig
  PI = 3.141592654

  def Trig.sin(x)
    puts "sin"
  end

  def Trig.cos(x)
    puts "cos"
  end
end

one = Trig.cos(5)

module Week
  FIRST_DAY = "Sunday"

  def weeks_in_month
    puts "You have four weeks in a month"
  end

  def Week.weeks_in_year
    puts "You have 52 weeks in a year"
  end
end

module Week2
  FIRST_DAY = "Sunday"

  def weeks_in_month
    puts "You have 32 weeks in a month"
  end

  def Week.weeks_in_year
    puts "You have 52 weeks in a year"
  end
end

class Decade
  include Week2
  include Week
  no_of_yrs=10

  def no_of_months
    puts Week::FIRST_DAY
    number=10*12
    puts number
  end
end

d1 = Decade.new
puts Week::FIRST_DAY
Week.weeks_in_year
d1.no_of_months
#SOS klironomikotita, an exoume cascade twn methodwn apo 2 diaforetika modules, kaleitai auto pou egine include teleutaio, edw "Week"
d1.weeks_in_month

x, y, z = 12, 36, 72
puts "The value of x is #{x}."
puts "The sum of x and y is #{ x + y }."
puts "The average was #{ (x + y + z)/3 }."

a = ["a", "b", "c"]
n = [65, "66", "67"]
puts a.pack("A3A3A3") #=> "a  b  c  "
puts a.pack("a3a3a3") #=> "a\000\000b\000\000c\000\000"
puts n.pack("ca2a1") #=> "A666"

#me to yield kalw to block pou exei idio onoma me ti sunartisi (def) kai tis parametrous pou exei dipla tis pernaw se autes tou block
def test
  yield 5
  puts "You are in the method test"
  yield 100
end

test { |ke| puts "You are in the block #{ke}" }

#You can use any Ruby object as a key or value, even an array, so following example is a valid one
months = Hash[d2 = Decade.new => 100, "month" => 200]

puts "#{months[d2]}"
puts "#{months['month']}"


time1 = Time.new

puts "Current Time : " + "#{time1.usec}"

if (('a'..'j') === 'c')
  puts "c lies in ('a'..'j')"
end

#print "Enter a value :" #san print
#val = gets
#puts "#{val+"3"}" #san println

puts File.readable?("test2.txt") # => true
puts File.writable?("test2.txt") # => true
puts File.executable?("test2.txt") # => false

puts Dir.pwd


# define a class
class Box
  # constructor method
  def initialize(w, h)
    @width, @height = w, h
  end

  # instance method by default it is public
  def getArea
    getWidth() * getHeight
  end

  # define private accessor methods
  def getWidth
    @width
  end

  def getHeight
    @height
  end

  # make them private
  private :getWidth, :getHeight

  # instance method to print area
  def printArea
    @area = getWidth() * getHeight
    puts "Big box area is : #@area"
  end

  # make it protected
  protected :printArea
end

module Marios
  @i = 5
  module Avgeris
  end
end

module Kwstas
  @b = 7
  attr_accessor :b
end

module Marios::Avgeris::Alexandros
  @c = 3
end

class Person
  attr_accessor :name
end
person = Person.new
person.name = 'Dennis'
puts person.name

A = Class.new

def A.speak
  "I'm class A"
end

puts A.speak #=> "I'm class A"
puts A.singleton_methods #=> ["speak"]

class A
  def self.c_method
    'in A#c_method'
  end
end

puts A.singleton_methods

class Person
end

puts Person.class #=> Class

class Class
  def loud_name
    "#{name.upcase}!"
  end
end

puts Person.loud_name #=> "PERSON!"

matz = Object.new

def matz.speak
  "Place your burden to machine's shoulders"
end

puts matz.class #=> Object
opts = Hash[:resource_uri => 12334, :account => Marios]
puts opts[:resource_uri]

class A
  def initialize()
    @res_handler = 5
  end

  def retu
    return @res_handler.to_s
  end
end

b = A.new
puts b.retu

puts ["a", "b", "c"].join("-")

module Alpha

  class Five
    def retu
      return adda(10)
    end
  end

  module B
    class Six
      def retu
        return 6
      end
    end
  end

end

#puts Alpha::B::Six.new.retu

module Alpha::B
  class Seven
    def retu
      return 7
    end
    def adda(i)
      i=i+1
    end
  end
end

module Alpha::Epsilos
  def kak
    #adda(3)
    7
  end
end
puts Alpha::B::Six.new.retu

class Tempo
  AR = 5

  def ret
    puts "#{AR}"
  end
end

Tempo.new.ret

class Bines
  def test
    i = 100
    j = 10
    k = 0
  end
end

if 5
  puts Bines.new.test
end

print "1/2/3/4/5/6/7/8/9/0".split('/')[0..-2]
puts
puts ['sdf', 'sdff']

R = [1, 2, 3, 4, 5]

R.map do |avga|
  puts (avga+1).to_s
end

puts 9

class Patates
  def initialize
    @@param = 1
  end

  attr_accessor :account #TODO remove this when we enable authentication on both rest and xmpp
  [
      # ACCOUNT
      :can_create_account?, # ()
      :can_view_account?, # (account)
      :can_renew_account?, # (account, until)
      :can_close_account?, # (account)
      # RESOURCE
      :can_create_resource?, # (resource_descr, type)
      :can_modify_resource?, # (resource_descr, type)
      :can_view_resource?, # (resource)
      :can_release_resource?, # (resource)
      # LEASE
      :can_view_lease?, # (lease)
      :can_modify_lease?, # (lease)
      :can_release_lease?, # (lease)
  ].each do |m|
    define_method(m) do |*args| # Evaluates the given block in the context of the class/module.
      #debug "Check permission '#{m}' (#{@permissions.inspect})"
      unless @permissions[m]
        raise InsufficientPrivilegesException.new
      end
      true
    end
  end
  [1, 2, 3, 4]

  def tria
    @kolos = @@param + 1
    puts @kolos
  end
end
#puts patates.new.account

options = {:font_size => 10, :font_family => "Arial"}
#options[self] = [1,2,34]
ma = (options[self] ||= [1, 2, 34])

module Tempa
  def pros(i)
    @@declarations ||= {}
    m = (@@declarations[self] ||= [])
    m << i
    puts
    #puts m
    puts

  end

  def api_description()
    @@declarations ||= {}
    @@declarations[self] || []
  end

end

module Tempb
  extend Tempa
  pros 9
  pros 4
  pros 8

end

Tempb.api_description.each do |a|
  print a+1
end

puts

s1 = Set.new [1,2]
s2 = Set.new [1,2,3,4,5]
s3 = s2-s1
s4 = Set.new [3,4,5]
puts s3 == s4

res_descr = {}
res_descr[:name] = 4

puts res_descr[:name]

class Parent
  attr_accessor :i
end

p1 = Parent.new
p1.i = 5
p2 = p1
p2.i = 6
puts p1.i

#puts Alpha::B::Five.new.retu
#puts Alpha::Epsilos.kak

k = [{:name=>"node1", :hostname=>"node1"}, {:name=>"node2", :hostname=>"node2"}] # pinakas apo hash

k.each do |a|
  puts a[:name]
end

puts 5

require 'spira'
require 'rdf/turtle'
require 'sparql/client'
#require 'sparql'
require 'rdf/vocab'


require_relative '../../omn-models/resource'
#require_relative '../../omn-models/old_populator'

account = Semantic::Account.for(:nil_account) # vres ton default account
sparql = SPARQL::Client.new($repository)
query = sparql.construct([:s, :p, account.uri]).where([:s, :p, account.uri])
query.each_statement do |s,p,o|
  query2 = sparql.construct([s, :p, :o]).where([s, :p, :o])
  @output = RDF::Writer.for(:ntriples).buffer do |writer|
    writer << query2 #$repository
  end
end

puts @output

