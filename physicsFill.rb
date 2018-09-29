#Physics fill
END{
	puts "That's all folks!"
}
class Formulaic
	###encapsulation
	attr_accessor :id, :unit, :constants, :vars, :overlap, :formulas, :master
	###constructors
	def initialize(id, unit, vars)
			@id = id 				#int
			@unit = unit 			#symbol
			#filled hash with constants (9.8, 101300, etc)
			@vars = vars 			#empty hash with possible vars
			@master = [:xo, :xf, :vo, :vf, :a, :t]
	end
	
	def poss(forms)
		#formulas as args. arrkeys must include key and that value at that key must be non nil
		counter = 0
		vars.each {|key, val| counter += 1 if (forms.include?(key) && val)}
		1 == (forms.length - counter)
	end
	
	def retUnknown(arrkeys)
		###return the unknown determined to exist in pos
		vars.each {|key, val| return key if (!val && arrkeys.include?(key))}
		:errorKey#Lazy error control is ok for early projects
		#^ but not anymore: somehow since :errorkey is entered doAll is using retUnknown even if Poss evals false
	end
	
	def cross?(formulaic)
		form = formulaic
		retable = []
		vars.each {|key, value| retable << key if formulaic.has_key?(key)}
		!retable.empty?
	end

	def input(*entered_values)
		i = 0
		vars.each{|key, value| vars[key] = entered_values[i]}
		#take in all args, including NaNs (with GUI should be able to keep in order)
		#assign the entered values to corresponding keys
		#difficulty in making pragmatic + general for subclasses
	end
	
	def doAll
	end
	
	def clearVars
		vars.each {|key, value| vars[key] = nil}
		vars
	end
	
end

class Kinematic < Formulaic
	def initialize()
		super(0, :kinematics, {xo:nil, xf:nil, vo:nil, vf:nil, a:nil, t:nil})
		@overlap = {a: [:forces], vo: [:energy], vf: [:energy], t: [:momentum]}
		@constants = {g:9.8, axp: 0}
		@formulas = {vat:[:vf, :vo, :a, :t], dat:[:xo, :xf, :vo, :a, :t], twenty2:[:vf, :vo, :a, :xo, :xf]}
	end

	def initialize(*values)
		super(0, :kinematics, {xo:values[0], xf:values[1], vo:values[2], vf:values[3], a:values[4], t:values[5]})
		@overlap = {a: [:forces], vo: [:energy], vf: [:energy], t: [:momentum]}
		@constants = {g:9.8, axp: 0}
		@formulas = {vat:[:vf, :vo, :a, :t], dat:[:xo, :xf, :vo, :a, :t], twenty2:[:vf, :vo, :a, :xo, :xf]}
	end
	
	def doAll
		###preform possible equations entering values into vars until progress is not made
		prev = vars.clone
		
		loop do
			prev = vars.clone
			### could find missing, store in array, enter each into each equation
			### make poss return the key not included (what to solve for)***good idea
			### write another method using poss to return which equations are possible (maybe doable)
			### if not then find a way to run through each, short circuiting if completed
			
      vatPoss = poss(formulas[:vat])				#boolean flag true if it is possible to calculate
			datPoss = poss(formulas[:dat])				#boolean flag  					"
			twenty2Poss = poss(formulas[:twenty2])#boolean flag  					"
			puts "#{vatPoss} and #{datPoss} and #{twenty2Poss}"
			
			vatUnk = vatPoss ? retUnknown(formulas[:vat]) : nil							#
			datUnk = datPoss ? retUnknown(formulas[:dat]) : nil							#
			twenty2Unk = twenty2Poss ? retUnknown(formulas[:twenty2]) : nil	#
			puts "#{vatUnk} and  #{datUnk} and #{twenty2Unk} prior"
			vatUnk ? vars[vatUnk] = vat(vatUnk) : 100
			datUnk ? vars[datUnk] = dat(datUnk) : 100
			twenty2Unk ? vars[twenty2Unk] = twenty2(twenty2Unk) : 100
			puts "#{vars} postor"
			
			break if prev == vars
		end
	end
	
	def vat(unknown)
		#vf = vo + at
		case unknown
		when :vf
			vars[:vo] + (vars[:a] * vars[:t])
		when :vo
			vars[:vf] - (vars[:a] * vars[:t])
		when :a
			(vars[:vf] - vars[:vo])/vars[:t]
		when :t
			(vars[:vf] - vars[:vo])/vars[:a]
		end
	end	
		
	def dat(unknown)
		#xf - xo = vo t + 1/2 a t^2
		case unknown
		when :xf
			(vars[:vo] * vars[:t]) + (0.5 * vars[:a] * vars[:t]**2) + vars[:xo]
		when :xo
			vars[:xf] - (vars[:vo] * vars[:t] + 0.5 * vars[:a] * vars[:t]**2 )
		when :vo
			((vars[:xf] - vars[:xo]) - (0.5 * vars[:a] * vars[:t]**2))/vars[:t]
		when :t
			##should short circuit, never requested
		when :a
			(2 * ((vars[:xf] - vars[:xo]) - (vars[:vo] * vars[:t])))/vars[:t]**2
		end
	end
	
	def twenty2(unknown)
		case unknown
		when :vf
			vars[:vo]**2 + 2 * vars[:a] * (vars[:xf] - vars[:xo])
		when :vo
			(vars[:vf]**2 - (2 * vars[:a] * (vars[:xf] - vars[:xo])))**(1.0/2)
		when :a
			(vars[:vf]**2 - vars[:vo]**2) / (2 *(vars[:xf] - vars[:xo]))
		when :xf
			vars[:xo] + ((vars[:vf]**2 - vars[:vo]**2) / (2 * vars[:a]))
		when :xo
			(vars[:xf] - ((vars[:vf]**2 - vars[:vo]**2) / (2 * vars[:a])))
		end
	end
	
end


a = {a: -9.8, dx: 10, vo: 7, dy: nil}
kine = Kinematic.new()
=begin
#puts kine.input(0,0,0,0,0,0)
puts kine.vars
puts kine.constants[:g]
puts kine.twenty2(:a)
puts kine.vars[:a]
###^ tests
=end

puts "physicsFill is now in Kinematics mode\n"+
	"enter all numbers for which you have known values\n"+
	"0:xo\n"+
	"1:xf\n"+
	"2:vo\n"+
	"3:vf\n"+
	"4:a\n"+
	"5:t\n"
arr = []
(gets.chomp!).scan(/\d/).each{|a| arr << a.to_i}

arr.each do|num|
	puts "value for " +kine.master[num].to_s
	kine.vars[kine.master[num]] = (gets.chomp!).to_f
end

kine.doAll

puts kine.vars


