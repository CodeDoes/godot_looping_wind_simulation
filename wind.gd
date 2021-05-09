tool
extends Node

export var loop_range = 1.0 # sec
export var time = 0.0
export var wind_strength = 8.0
export var time_scale = 4.0
export var time_offset = 0.0
#export var clippable_strength_boost = 0.2
export (OpenSimplexNoise) var noise:OpenSimplexNoise = preload("res://wind simplex noise.tres")

func _process(delta: float) -> void:
	time=fposmod(time+delta,loop_range)
#	property_list_changed_notify()
	
	
func get_wind_velocity_at_point(point:Vector2)->Vector2:
	"""
	return velocity of wind at a point
	"""
#	var point_rotation = noise.get_noise_4d(point.x,point.y,6.0,time)
#	point = point.rotated(TAU*point_rotation)
	var t1 = time
	var t2 = t1+loop_range#fposmod(,loop_range)#fposmod(time+loop_range/2,loop_range)
	var m1 = (t1/loop_range)
	var m2 = 1.0-m1#(t2/loop_range)
	t1 = t1 * time_scale+time_offset*time_scale
	t2 = t2 * time_scale+time_offset*time_scale
	var velocity = Vector2(
		noise.get_noise_4d(point.x,point.y,0,t1),
		noise.get_noise_4d(point.x,point.y,623,t1)
		)*m1
	velocity += Vector2(
		noise.get_noise_4d(point.x,point.y,0,t2),
		noise.get_noise_4d(point.x,point.y,623,t2)
		)*m2
#	velocity *= 100.0
#	velocity /= 2
#	velocity = velocity.normalized()*noise.get_noise_4d(point.x,point.y,+300.0,time*100)
	assert(abs(velocity.x)<=1)
	assert(abs(velocity.y)<=1)
	return velocity*wind_strength#(+velocity*wind_strength*clippable_strength_boost)/2.0
