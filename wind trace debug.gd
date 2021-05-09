tool
extends Node2D
const WindType = preload("res://wind.gd")

class Trace:
	export var position:Vector2
	export var velocity:Vector2
	export var points:PoolVector2Array
	export var color:Color
	export var life:float
	func _init(default_color:Color,default_life:float):
		points = PoolVector2Array()
		position = Vector2.ZERO
		velocity = Vector2.ZERO
		color = default_color
		life = default_life
	func add_point():
		points.append(position)
	func remove_point():
		points.remove(0)
	func empty():
		return points.empty()
		
#export var default_trace_color = Color.red
export var trace_length = 100
export var active_trace_num = 2
export var active_traces:Array
export var static_traces:Array
export var max_lifetime = 3.0

func do_add_point():

	for i in range(active_traces.size()-1,-1,-1):
		var trace = active_traces[i]
		trace.add_point()
		if trace.life>max_lifetime:
			trace.life=max_lifetime
		if trace.life<=0:
			active_traces.remove(i)
			static_traces.append(trace)
	for i in range(static_traces.size()-1,-1,-1):
#		assert(i<static_traces.size())
		var trace = static_traces[i]
		if not trace.empty():
			trace.remove_point()
		if trace.empty():
			static_traces.remove(i)
		
	for trace in active_traces+static_traces:
		while trace.points.size()>trace_length:
			trace.remove_point()
		
	while active_traces.size()<active_trace_num:
		var vrect = get_viewport_rect()
		var wind = get_wind()
		var trace = Trace.new(Color.from_hsv(randf(),1,1),max_lifetime)
		trace.position = vrect.position+vrect.size*Vector2(randf(),randf())
		trace.velocity = Vector2.RIGHT.rotated(TAU*randf())*wind.wind_strength*randf()*pow(0.9,2)
		active_traces.append(trace)
	while active_traces.size()>active_trace_num:
		var i = randi()%(active_traces.size())
		assert(i<active_traces.size())
		static_traces.append(active_traces[i])
		active_traces.remove(i)
		
#	prints("points added",get_script(),"static traces",static_traces,"active traces",active_traces)
	update()
	
#	get_tree().create_timer(1.0).connect("timeout",self,"do_add_point")
func _ready():
	active_traces = []
	static_traces = []
	var script = get_script()
#	connect("script_changed",self,"_ready",[],CONNECT_ONESHOT)
	do_add_point()
	pass
	var add_point_timer = Timer.new()
	add_child(add_point_timer)
	add_point_timer.start(0.1)
	add_point_timer.connect("timeout",self,"do_add_point")
	request_ready()
	print("wind trace ready method called!")
func get_wind()->WindType:
	return (get_parent() as WindType)
	
func _process(delta: float) -> void:
	var wind = get_wind()
	var vrect = get_viewport_rect()
	
	for i in range(active_traces.size()-1,-1,-1):
		assert(i<active_traces.size())
		var trace = active_traces[i]
		trace.velocity*=0.9
		trace.velocity+=wind.get_wind_velocity_at_point(trace.position) * delta
		trace.position+=trace.velocity*delta
		trace.life-=delta
		if not vrect.has_point(trace.position):
			active_traces.remove(i)
			static_traces.append(trace)
			
	
func _get_configuration_warning():
	if not get_parent() is WindType:
		return "Parent must be WindType"
	return ""
func _draw():
#	var point_color = default_trace_color
	for trace in static_traces+active_traces:
		if trace.points.size()>=2:
			var trace_colors = PoolColorArray()
			var num_points = trace.points.size()
			var color = trace.color
			trace_colors.resize(num_points)
			for i in range(num_points):
				color.a = float(i)/float(num_points)
				assert(i<trace_colors.size())
				trace_colors[i]=color
			draw_polyline_colors(trace.points,trace_colors,2,true)
