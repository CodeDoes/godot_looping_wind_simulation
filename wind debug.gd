tool
extends Node2D
const WindType = preload("res://wind.gd")

func get_wind()->WindType:
	return (get_parent() as WindType)
	
func _process(delta: float) -> void:
	update()
	
func _get_configuration_warning():
	if not get_parent() is WindType:
		return "Parent must be WindType"
	return ""
export (int,8,100) var granularity = 32
func _draw() -> void:
	var wind:WindType = get_wind()
	var vrect = get_viewport_rect()
	var velocity:Vector2
	var mini_rect = Rect2(-Vector2.ONE*2,Vector2.ONE*4)
	for x in range(floor(vrect.position.x/granularity)*granularity,ceil(vrect.end.x/granularity)*granularity,granularity):
		for y in range(floor(vrect.position.y/granularity)*granularity,ceil(vrect.end.y/granularity)*granularity,granularity):
#			draw_line(to_local(Vector2(x,vrect.position.y)),to_local(Vector2(x,vrect.end.y)),Color.webgreen)
#			draw_line(to_local(Vector2(vrect.position.x,y)),to_local(Vector2(vrect.end.x,y)),Color.webgreen)
			velocity = wind.get_wind_velocity_at_point(to_global(Vector2(x,y)))
			velocity = velocity/wind.wind_strength
#			max_strength = max(velocity.length(),max_strength)
#			min_strength = min(velocity.length(),min_strength)
			var color = Color(velocity.x+1.0/2.0,velocity.y+1.0/2.0,velocity.length())
			color = Color.from_hsv(velocity.angle()/PI,1,velocity.length())
			var bold = false
			if abs(1.0-velocity.length_squared())<0.2:
				color=Color.white
				bold = true
			if abs(velocity.length_squared())<0.001:
				color=Color.red
#				bold = true
			velocity = velocity*(granularity*4.0)
			var thickness = 1.0
			if bold:
				thickness = 4.0
			draw_line(to_local(Vector2(x,y)),to_local(Vector2(x,y)+velocity),color,thickness)
			mini_rect.position = Vector2(x,y)+velocity-Vector2.ONE
			draw_rect(mini_rect,color)
#	prints(min_strength,max_strength)
#	draw_arc(Vector2.ZERO,16,TAU*0,TAU*(wind.time/wind.loop_range),32,Color.white,3.0,true)
