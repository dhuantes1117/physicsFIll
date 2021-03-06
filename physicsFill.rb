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
			@master = []
			vars.to_a.flatten.each_with_index{|val, index|master << val if index.even?}
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
	
	def searchAndDestroy
		formulas.each do |key, arrVal|
			formFlag = poss(arrVal)
			formUnk = formFlag ? retUnknown(arrVal) : nil
			formUnk ? vars[formUnk] = self.send(key, formUnk) : nil
		end
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
			
			puts "crunching your numbers..."
			searchAndDestroy
			
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

class Projectile < Formulaic
	def initialize()
		super(0, :kinematics, {theta:nil, xo:nil, xf:nil, yo:nil, yf:nil, vo:nil, vf:nil, t:nil, ay:-9.8, ax:0, vox:nil, vfx:nil, voy:nil, vfy:nil, ymax:nil})
		@overlap = {a: [:forces], vo: [:energy], vf: [:energy], t: [:momentum]}
		@constants = {g:9.8, axp: 0}
		#TODO make formulas reflect adjusted
		@formulas = {vfox:[:vox, :vfx], vot:[:xf, :xo, :vox, :t], range:[:xf, :xo, :vo, :theta], maxY:[:ymax, :vo, :theta], tfv:[:t, :vo, :theta], vat:[:vfy, :voy, :t], dat:[:yf, :yo, :voy, :t], twenty2:[:vfy, :voy, :yo, :yf], soloMax:[:voy, :ymax, :yo], voof:[:theta, :vox, :voy]}
	end

	def initialize(*values)
		super(0, :kinematics, {theta:values[0], xo:values[1], xf:values[2], yo:values[3], yf:values[4], vo:values[5], vf:values[6], t:values[7], ay:-9.8, ax:0, vox:values[8], vfx:values[9], voy:values[10], vfy:values[11], ymax:values[12]})
		@overlap = {a: [:forces], vo: [:energy], vf: [:energy], t: [:momentum]}
		@constants = {g:9.8, axp: 0}
		#TODO make formulas reflect adjusted
		@formulas = {vfox:[:vox, :vfx], vot:[:xf, :xo, :vox, :t], range:[:xf, :xo, :vo, :theta], maxY:[:ymax, :vo, :theta], tfv:[:t, :vo, :theta], vat:[:vfy, :voy, :t], dat:[:yf, :yo, :voy, :t], twenty2:[:vfy, :voy, :yo, :yf], soloMax:[:voy, :ymax, :yo], voof:[:theta, :vox, :voy]}
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
			puts "crunching your numbers..."
      resolve
      incite
      incitef
			searchAndDestroy
			
			break if prev == vars
		end
	end
	
	#horizontal only formulas
	def vfox(unknown)
		#vfx = vox
		case unknown
		when :vfx
			vars[:vox]
		when :vox
			vars[:vfx]
		end
	end	
		
	def vot(unknown)
		#xf - xo = vo t
		case unknown
		when :xf
			(vars[:vox] * vars[:t]) + vars[:xo]
		when :xo
			vars[:xf] - (vars[:vox] * vars[:t])
		when :vox
			(vars[:xf] - vars[:xo])/vars[:t]
		when :t
			(vars[:xf] - vars[:xo])/vars[:vox]
		end
	end
	
	#values from angle and vo
	def range(unknown)
		if(vars[:yo] == 0 && vars[:yf] == 0) then
			#xf - xo = ((vo**2)*(Math.sin(2*theta)))/9.8
			case unknown
			when :xf
				(((vars[:vo]**2) * (Math.sin(2 * (vars[:theta] / (180/Math::PI))))) / -vars[:ay]) + vars[:xo]
			when :xo
				vars[:xf] - (((vars[:vo]**2) * (Math.sin(2 * (vars[:theta] / (180/Math::PI))))) / -vars[:ay])
			when :vo
				(((vars[:xf] - vars[:xo]) * -vars[:ay]))/Math.sin(2 * (vars[:theta] / (180/Math::PI)))**(1/2.0)
			when :theta
				(Math.asin((((vars[:xf] - vars[:xo]) * -vars[:ay])) / vars[:vo]**2) / 2) * (180/Math::PI)
			end
		end
	end
	
	def maxY(unknown)
		if(vars[:yo] == 0 && vars[:yf] == 0) then
			#ymax = ((vo**2)*(Math.sin(theta)**2))/(2g)
			case unknown
			when :ymax
				(((vars[:vo]**2) * (Math.sin((vars[:theta] / (180/Math::PI)))**2)) / (2 * -vars[:ay]))
			when :vo
				((vars[:ymax] * (2 * -vars[:ay])) / (Math.sin((vars[:theta] / (180/Math::PI)))**2)) / 2
			when :theta
				(Math.asin(((vars[:ymax] * (2 * -vars[:ay])) / (vars[:vo]**2))**(1/2.0))) * (180/Math::PI)
			end
		end
	end
	
	def tfv(unknown)
		if(vars[:yo] == 0 && vars[:yf] == 0) then
			#t = (2 * vo * Math.sin(theta))/g
			case unknown
			when :t
				(((2 * vars[:vo]) * (Math.sin(vars[:theta] / (180/Math::PI)))) / -vars[:ay])
			when :vo
				((vars[:t] * -vars[:ay]) / (Math.sin(vars[:theta] / (180/Math::PI)))) / 2
			when :theta
				Math.asin((vars[:t] * -vars[:ay]) / (2 * vars[:vo])) * (180/Math::PI)
			end
		end
	end
	
	#normal equations (with g for y)
	def vat(unknown)
		#vf = vo + at
		case unknown
		when :vfy
			vars[:voy] + (vars[:ay] * vars[:t])
		when :voy
			vars[:vfy] - (vars[:ay] * vars[:t])
		when :t
			(vars[:vfy] - vars[:voy])/vars[:ay]
		end
	end	
		
	def dat(unknown)
		#yf - yo = vo t + 1/2 a t^2
		case unknown
		when :yf
			(vars[:voy] * vars[:t]) + (0.5 * vars[:ay] * vars[:t]**2) + vars[:yo]
		when :yo
			vars[:yf] - (vars[:voy] * vars[:t] + 0.5 * vars[:ay] * vars[:t]**2 )
		when :voy
			((vars[:yf] - vars[:yo]) - (0.5 * vars[:ay] * vars[:t]**2))/vars[:t]
		when :t
			##should short circuit, never requested
		end
	end
	
	def twenty2(unknown)
		case unknown
		when :vfy
			-(vars[:voy]**2 + (2 * vars[:ay] * (vars[:yf] - vars[:yo])))**(1.0/2)
		when :voy
			(vars[:vfy]**2 - (2 * vars[:ay] * (vars[:yf] - vars[:yo])))**(1.0/2)
		when :yf
			vars[:yo] + ((vars[:vfy]**2 - vars[:voy]**2) / (2 * vars[:ay]))
		when :yo
			(vars[:yf] - ((vars[:vfy]**2 - vars[:voy]**2) / (2 * vars[:ay])))
		end
	end

	#twenty2 with only ymax
	def soloMax(unknown)
		#vf^2 = vo^2 + 2a/\y | 0 = vo^2 + 2a/\y | vo = sqrt(-2a/\y)
		case unknown
		when :voy
			(2 * -vars[:ay] * (vars[:ymax] - vars[:yo]))**(1.0/2)
		when :ymax
			vars[:yo] + ((-1.0 * vars[:voy]**2) / (2 * vars[:ay]))
		when :yo
			vars[:ymax] - ((-1.0 * vars[:voy]**2) / (2 * vars[:ay]))
		end
	end

	def voof(unknown)
		case unknown
		when :theta
			Math.atan(vars[:voy] / vars[:vox]) * (180.0/Math::PI)
		when :vox
			vars[:vo] * Math.cos(vars[:theta])
		when :voy
			vars[:vo] * Math.sin(vars[:theta])
		end
	end
	
	#not formulas
	def resolve
		if (vars[:vo] && vars[:theta] && !vars[:vox] && !vars[:voy]) then
			vars[:vox] = vars[:vo] * Math.cos(vars[:theta] / (180.0/Math::PI))
			vars[:voy] = vars[:vo] * Math.sin(vars[:theta] / (180.0/Math::PI))
		end
	end
	
	def incite
		if (!vars[:vo] && vars[:vox] && vars[:voy]) then
			vars[:vo] = (vars[:vox]**2 + vars[:voy]**2)**(1.0/2)
		end
	end
	
	def incitef
		if (!vars[:vf] && vars[:vfx] && vars[:vfy]) then
			vars[:vf] = -1 * (vars[:vfx]**2.0 + vars[:vfy]**2.0)**(1.0/2)
		end
	end
end

a = {a: -9.8, dx: 10, vo: 7, dy: nil}
kine = Kinematic.new()
proj = Projectile.new()
=begin
#puts kine.input(0,0,0,0,0,0)
puts kine.vars
puts kine.constants[:g]
puts kine.twenty2(:a)
puts kine.vars[:a]
###^ tests
=end

class UnitTest
	def initialize(tf)
		tf ? unitTestVerbose : unitTest
	end
	
	def unitTestVerbose
		form = Projectile.new(45, 0, 10.19716, 0, 0, 10, -10, 1.442096, 7.07106781187, 7.07106781187, 7.07106781187, -7.07106781187, 2.54929)
		puts form.vars
		hash = {}
		arr = []
		form.methods.each do |val|
			if (form.formulas.include?(val.to_sym)) then
				valSymbol = form.formulas[val.to_sym][0]
				puts valSymbol.to_s
				trueVal =  form.vars[valSymbol]
				puts trueVal.to_s
				calculatedVal = form.send(val, valSymbol)
				puts calculatedVal.to_s
				#solved value = projectile.vat(unknownKey)
				#if solved value doesn't equal programmed
				if (trueVal != calculatedVal) then
					hash[val] = "Issue with formula #{val.to_sym}\n#{valSymbol} should be #{trueVal}, but is #{calculatedVal} instead"
				end
				end
		end
		hash.each {|key, val| arr << val}
		puts arr.join("\n")
		puts "exiting unit test"
	end

	def unitTest
		form = Projectile.new(45, 0, 10.19716, 0, 0, 10, -10, 1.442096, 7.07106781187, 7.07106781187, 7.07106781187, -7.07106781187, 2.54929)
		hash = {}
		arr = []
		form.methods.each do |val|
			if (form.formulas.include?(val.to_sym)) then
				valSymbol = form.formulas[val.to_sym][0]
				trueVal =  form.vars[valSymbol]
				calculatedVal = form.send(val, valSymbol)
				#solved value = projectile.vat(unknownKey)
				#if solved value doesn't equal programmed
				if (trueVal != calculatedVal) then
					hash[val] = "Issue with formula #{val.to_sym}\n#{valSymbol} should be #{trueVal}, but is #{calculatedVal} instead"
				end
				end
		end
		hash.each {|key, val| arr << val}
	end
end






UnitTest.new(false)

puts "Welcome to physicsFill\n"+
	"choose a mode:\n"+
	"0:1D Kinematics\n"+
	"1:Projectile Kinematics\n"+
	"2:Forces\n"
	choice = gets.chomp!.to_i
case choice
when 0
	puts "physicsFill is now in Kinematics mode\n"+
	"enter all numbers for which you have known values"
	kine.master.each_with_index {|val, index| puts "#{index}:#{val}"}
	arr = []
	(gets.chomp!).scan(/\d+/).each{|a| arr << a.to_i}

	arr.each do|num|
		puts "value for " +kine.master[num].to_s
		kine.vars[kine.master[num]] = (gets.chomp!).to_f
	end
	kine.doAll
	kine.vars.each{|key, val| puts "#{key}: #{(val * 100).ceil / 100.0}"}
when 1
	puts "physicsFill is now in Projectile Kinematics mode\n"+
	"enter all numbers for which you have known values"
	proj.master.each_with_index {|val, index| puts "#{index}:#{val}" if (val != :ax ||val != :ay )}
	arr = []
	(gets.chomp!).scan(/\d+/).each{|a| arr << a.to_i}

	arr.each do|num|
	puts "value for " +proj.master[num].to_s
	proj.vars[proj.master[num]] = (gets.chomp!).to_f
	end
	
	proj.doAll
	proj.vars.each{|key, val| puts "#{key}: #{(val * 100).ceil / 100.0}"}
	
	
when 2
	puts "Forces mode has not yet been implemented...\nsorry bout that"
end	
