tool
extends Node2D
const WindType = preload("res://wind.gd")
var last_time = 0
var cycle = 0
func get_wind()->WindType:
	return (get_parent() as WindType)
	
func _process(delta: float) -> void:
	var wind = get_wind()
	if last_time>wind.time:
		cycle=int(!cycle)
		
#	prints(last_time,wind.time)
	last_time = wind.time
	update()
	
func _get_configuration_warning():
	if not get_parent() is WindType:
		return "Parent must be WindType"
	return ""
func _draw():
	var wind = get_wind()
	var rad = TAU*(wind.time/wind.loop_range)
	match cycle:
		0:
			draw_arc(Vector2.ZERO,16,0,rad,32,Color.white,3.0,true)
		1:
			draw_arc(Vector2.ZERO,16,rad,TAU,32,Color.white,3.0,true)
