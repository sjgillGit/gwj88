class_name PredictiveTargeting

# Written by Kain Shin in preparation for his own projects
# The latest version is maintained on his website at ringofblades.org
# Modified from C# to GDScript by ShadowCommander

# ////////////////////////////////////////////////////////////////////////////
# This implies that no solution exists for this situation as the target may literally outrun the projectile with its current direction
# In cases like that, we simply aim at the place where the target will be 1 to 5 seconds from now.
# Feel free to randomize t at your discretion for your specific game situation if you want that guess to feel appropriately noisier
static func PredictiveAimWildGuessAtImpactTime() -> float:
	return randf_range(1, 5)

# ////////////////////////////////////////////////////////////////////////////
# returns true if a valid solution is possible
# projectileVelocity will be a non-normalized vector representing the muzzle velocity of a lobbed projectile in 3D space
# if it returns false, projectileVelocity will be filled with a reasonable-looking attempt
# The reason we return true/false here instead of Vector3 is because you might want your AI to hold that shot until a solution exists
# This is meant to hit a target moving at constant velocity
# Full derivation by Kain Shin exists here:
# http://www.gamasutra.com/blogs/KainShin/20090515/83954/Predictive_Aim_Mathematics_for_AI_Targeting.php
# gravity is assumed to be a positive number. It will be calculated in the downward direction, feel free to change that if you game takes place in Spaaaaaaaace
static func PredictiveAim(muzzlePosition: Vector3, projectileSpeed: float, targetPosition: Vector3, targetVelocity: Vector3, gravity: float) -> Array:
	assert(projectileSpeed > 0, "What are you doing shooting at something with a projectile that doesn't move?")
	var projectileVelocity: Vector3 = Vector3.INF
	if muzzlePosition == targetPosition:
		# Why dost thou hate thyself so?
		# Do something smart here. I dunno... whatever.
		projectileVelocity = projectileSpeed * (Vector3(randf_range(0, PI*2), randf_range(0, PI*2), randf_range(0, PI*2)).normalized() * Vector3.FORWARD)
		return [true, projectileVelocity]

	# Much of this is geared towards reducing floating point precision errors
	var projectileSpeedSq: float = projectileSpeed * projectileSpeed
	var targetSpeedSq: float = targetVelocity.length_squared() # doing this instead of self-multiply for maximum accuracy
	var targetSpeed: float = sqrt(targetSpeedSq)
	var targetToMuzzle: Vector3 = targetPosition - muzzlePosition#muzzlePosition - targetPosition #
	var targetToMuzzleDistSq: float = targetToMuzzle.length_squared() # doing this instead of self-multiply for maximum accuracy
	var targetToMuzzleDist: float = sqrt(targetToMuzzleDistSq)
	var targetToMuzzleDir: Vector3 = targetToMuzzle
	targetToMuzzleDir = targetToMuzzleDir.normalized()

	# Law of Cosines: A*A + B*B - 2*A*B*cos(theta) = C*C
	# A is distance from muzzle to target (known value: targetToMuzzleDist)
	# B is distance traveled by target until impact (targetSpeed * t)
	# C is distance traveled by projectile until impact (projectileSpeed * t)
	var cosTheta: float = targetToMuzzleDir.dot(targetVelocity.normalized()) if (targetSpeedSq > 0) else 1.0

	var validSolutionFound: bool = true
	var t: float
	if is_equal_approx(projectileSpeedSq, targetSpeedSq):
		# a = projectileSpeedSq - targetSpeedSq = 0
		# We want to avoid div/0 that can result from target and projectile traveling at the same speed
		# We know that C and B are the same length because the target and projectile will travel the same distance to impact
		# Law of Cosines: A*A + B*B - 2*A*B*cos(theta) = C*C
		# Law of Cosines: A*A + B*B - 2*A*B*cos(theta) = B*B
		# Law of Cosines: A*A - 2*A*B*cos(theta) = 0
		# Law of Cosines: A*A = 2*A*B*cos(theta)
		# Law of Cosines: A = 2*B*cos(theta)
		# Law of Cosines: A/(2*cos(theta)) = B
		# Law of Cosines: 0.5*A/cos(theta) = B
		# Law of Cosines: 0.5 * targetToMuzzleDist / cos(theta) = targetSpeed * t
		# We know that cos(theta) of zero or less means there is no solution, since that would mean B goes backwards or leads to div/0 (infinity)
		if cosTheta > 0:
			t = 0.5 * targetToMuzzleDist / (targetSpeed * cosTheta)
		else:
			validSolutionFound = false
			t = PredictiveAimWildGuessAtImpactTime()
	else:
		# Quadratic formula: Note that lower case 'a' is a completely different derived variable from capital 'A' used in Law of Cosines (sorry):
		# t = [ -b � Sqrt( b*b - 4*a*c ) ] / (2*a)
		var a: float = projectileSpeedSq - targetSpeedSq
		var b: float = 2.0 * targetToMuzzleDist * targetSpeed * cosTheta
		var c: float = -targetToMuzzleDistSq
		var discriminant: float = b * b - 4.0 * a * c

		if discriminant < 0:
			# Square root of a negative number is an imaginary number (NaN)
			# Special thanks to Rupert Key (Twitter: @Arakade) for exposing NaN values that occur when target speed is faster than or equal to projectile speed
			validSolutionFound = false
			t = PredictiveAimWildGuessAtImpactTime()
		else:
			# a will never be zero because we protect against that with "if (approximatelyf(projectileSpeedSq, targetSpeedSq))" above
			var uglyNumber: float = sqrt(discriminant)
			var t0: float = 0.5 * (-b + uglyNumber) / a
			var t1: float = 0.5 * (-b - uglyNumber) / a
			# Assign the lowest positive time to t to aim at the earliest hit
			t = minf(t0, t1)
			if is_zero_approx(t):
				t = maxf(t0, t1)

			if is_zero_approx(t):
				# Time can't flow backwards when it comes to aiming.
				# No real solution was found, take a wild shot at the target's future location
				validSolutionFound = false
				t = PredictiveAimWildGuessAtImpactTime()

	# Vb = Vt - 0.5*Ab*t + [(Pti - Pbi) / t]
	projectileVelocity = targetVelocity + (-targetToMuzzle / t)
	if !validSolutionFound:
		# PredictiveAimWildGuessAtImpactTime gives you a t that will not result in impact
		#  Which means that all that math that assumes projectileSpeed is enough to impact at time t breaks down
		#  In this case, we simply want the direction to shoot to make sure we
		#  don't break the gameplay rules of the cannon's capabilities aside from gravity compensation
		projectileVelocity = projectileSpeed * projectileVelocity.normalized()

	if !is_equal_approx(gravity, 0):
		# projectileSpeed passed in is a constant that assumes zero gravity.
		# By adding gravity as projectile acceleration, we are essentially breaking real world rules by saying that the projectile
		#  gets additional gravity compensation velocity for free
		# We want netFallDistance to match the net travel distance caused by gravity (whichever direction gravity flows)
		var netFallDistance: float = (t * projectileVelocity).y
		# d = Vi*t + 0.5*a*t^2
		# Vi*t = d - 0.5*a*t^2
		# Vi = (d - 0.5*a*t^2)/t
		# Remember that gravity is a positive number in the down direction, the stronger the gravity, the larger gravityCompensationSpeed becomes
		var gravityCompensationSpeed: float = (netFallDistance + 0.5 * gravity * t * t) / t
		projectileVelocity.y = gravityCompensationSpeed

	# FOR CHECKING ONLY (valid only if gravity is 0)...
	# float calculatedprojectilespeed = projectileVelocity.magnitude
	# bool projectilespeedmatchesexpectations = (projectileSpeed == calculatedprojectilespeed)
	# ...FOR CHECKING ONLY

	return [validSolutionFound, projectileVelocity]

static func CalculateIntercept(targetLocation: Vector3, targetVelocity: Vector3, interceptorLocation: Vector3, interceptorSpeed: float) -> Vector3:
	var Ax: float = targetLocation.x
	var Ay: float = targetLocation.y
	var Az: float = targetLocation.z

	var As: float = targetVelocity.length()
	var Av: Vector3 = targetVelocity.normalized()
	var Avx: float = Av.x
	var Avy: float = Av.y
	var Avz: float = Av.z

	var Bx: float = interceptorLocation.x
	var By: float = interceptorLocation.y
	var Bz: float = interceptorLocation.z

	var Bs: float = interceptorSpeed

	var t: float = 0

	var a: float = (
		pow(As, 2.0) * pow(Avx, 2.0) +
		pow(As, 2.0) * pow(Avy, 2.0) +
		pow(As, 2.0) * pow(Avz, 2.0) -
		pow(Bs, 2.0)
		)

	if a == 0:
		# Debug.Log("Quadratic formula not applicable")
		print_debug("Quadratic formula not applicable")
		return targetLocation

	var b: float = (
		As * Avx * Ax +
		As * Avy * Ay +
		As * Avz * Az +
		As * Avx * Bx +
		As * Avy * By +
		As * Avz * Bz
		)

	var c: float = (
		pow(Ax, 2.0) +
		pow(Ay, 2.0) +
		pow(Az, 2.0) -
		Ax * Bx -
		Ay * By -
		Az * Bz +
		pow(Bx, 2.0) +
		pow(By, 2.0) +
		pow(Bz, 2.0)
		)

	var t1: float = (-b + pow((pow(b, 2.0) - (4.0 * a * c)), (1.0 / 2.0))) / (2.0 * a)
	var t2: float = (-b - pow((pow(b, 2.0) - (4.0 * a * c)), (1.0 / 2.0))) / (2.0 * a)

	# Debug.Log("t1 = " + t1 + " t2 = " + t2)
	print_debug("t1 = ", t1, " t2 = ", t2)

	if t1 <= 0 || t1 == INF || is_nan((t1)):
		if t2 <= 0 || t2 == INF || is_nan(t2):
			return targetLocation
		else:
			t = t2
	elif t2 <= 0 || t2 == INF || is_nan(t2) || t2 > t1:
		t = t1
	else:
		t = t2

	# Debug.Log("t = " + t)
	# Debug.Log("Bs = " + Bs)
	print_debug("t = ", t)
	print_debug("Bs = ", Bs)

	var Bvx: float = (Ax - Bx + (t * As + Avx)) / (t * pow(Bs, 2.0))
	var Bvy: float = (Ay - By + (t * As + Avy)) / (t * pow(Bs, 2.0))
	var Bvz: float = (Az - Bz + (t * As + Avz)) / (t * pow(Bs, 2.0))

	var Bv: Vector3 = Vector3(Bvx, Bvy, Bvz)

	# Debug.Log("||Bv|| = (Should be 1) " + Bv.magnitude)
	print_debug("||Bv|| = (Should be 1) ", Bv.length())

	return Bv * Bs
