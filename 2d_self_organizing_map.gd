extends Node2D

# hyperparameters
var neighbourhood_size : float = 100
var learning_rate : float = 0.5

# screen size used for rendering 
var screen_size : Vector2

# size of the data and map
@export var data_size : int = 1024
@export var map_size : int = 256

# scenes (used to instantiate stuff)
var data_point_scene
var map_point_scene

# array of points
var data_points : Array[Node2D]
var map_points : Array[Node2D]
var neighbourhood : Node2D

# boolean used to control the speed of visualization
var paused : bool = false

# parameters for the visualization
@export var colour_selection : bool = true 
@export var show_arrows : bool = true
@export var show_neighbourhood : bool = true

func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	data_point_scene = preload("res://data_point.tscn")
	map_point_scene = preload("res://map_point.tscn")
	
	initialize_data("spiral")
	initialize_map("linear")
	initialize_box()

func initialize_data(data_type: String) -> void:
	# initialize the random data according to the desired structure
	if data_type == "sin":
		# parameters used by the data structure
		var FREQUENCY : float = screen_size.x / (8.0*PI)
		var NOISE_MAG : Vector2 = 100.0*Vector2(1, 1)
		for i in data_size:
			# assign the point a location offset by some amount of noise
			var x : float = 0.8*randf()*screen_size.x + 0.1*screen_size.x
			var y : float = (0.35*sin(x / FREQUENCY) + 0.5)*screen_size.y
			var noise_offset : Vector2 = (randf()**2)*NOISE_MAG.rotated(2*PI*randf())
			# make sure it fits in the box we want to look at
			var out_of_bounds : bool = true
			while out_of_bounds:
				if ((Vector2(x,y) + noise_offset).x > screen_size.x*0.9) or ((Vector2(x,y) + noise_offset).x < screen_size.x*0.1) or ((Vector2(x,y) + noise_offset).y < screen_size.y*0.1) or ((Vector2(x,y) + noise_offset).y > screen_size.y*0.9):
					# if we're out of the box just try again. We only run this once so it's fine to be a bit inefficient
					x = 0.8*randf()*screen_size.x + 0.1*screen_size.x
					y = (0.35*sin(x / FREQUENCY) + 0.5)*screen_size.y
					noise_offset = (randf()**2)*NOISE_MAG.rotated(2*PI*randf())
				else:
					out_of_bounds = false
			# make the point
			var point_instance = data_point_scene.instantiate()
			point_instance.position = Vector2(x,y)  + noise_offset
			# godot stuff to add the object to the scene
			add_child(point_instance)
			point_instance.get_node("TextureRect").material.set_shader_parameter("colour", 0.5*Vector4(1.0, 1.0, 1.0, 1.0))
			data_points.append(point_instance)
			
	elif data_type == "spiral":
		var NUM_SPIRALS : float = 5.0
		for i in data_size:
			var theta : float = 2*PI*NUM_SPIRALS*float(i)/float(data_size)
			var r : float = 0.5*0.8*screen_size.y*float(i)/float(data_size)
			
			
			# make the point
			var point_instance = data_point_scene.instantiate()
			point_instance.position = 0.5*screen_size + r*Vector2.RIGHT.rotated(theta) # + noise_offset
			# godot stuff to add the object to the scene
			add_child(point_instance)
			point_instance.get_node("TextureRect").material.set_shader_parameter("colour", 0.5*Vector4(1.0, 1.0, 1.0, 1.0))
			data_points.append(point_instance)

func initialize_map(map_type: String) -> void:
	if map_type == "linear":
		# create all the map points along the x axis with no noise
		for i in map_size:
			var x : float = (float(i)/float(map_size))*screen_size.x*0.4 + screen_size.x*0.3
			var y : float = screen_size.y/2
			var point_instance = map_point_scene.instantiate()
			point_instance.position = Vector2(x,y)
			$line_between_map_points.add_point(Vector2(x,y))
			add_child(point_instance)
			point_instance.get_node("TextureRect").material.set_shader_parameter("colour", Vector4(1.0, 0.0, 0.0, 1.0))
			map_points.append(point_instance)

func initialize_box():
	$box_to_draw_in.add_point(screen_size*0.09)
	$box_to_draw_in.add_point(Vector2(screen_size.x*0.91, screen_size.y*0.09))
	$box_to_draw_in.add_point(screen_size*0.91)
	$box_to_draw_in.add_point(Vector2(screen_size.x*0.09, screen_size.y*0.91))
	$box_to_draw_in.add_point(screen_size*0.09)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("pause"):
		paused = not paused

func _process(_delta) -> void:
	if not paused:
		# select a random data point
		var i : int = randi_range(0, data_size-1)
		var j : int = select_point(i)
		
		if colour_selection:
			data_points[i].get_node("TextureRect").material.set_shader_parameter("colour", Vector4(0.0,0.0,1.0,1.0))
			map_points[j].get_node("TextureRect").material.set_shader_parameter("colour", Vector4(0.0,0.0,1.0,1.0))
		
		if show_arrows:
			var TICK_LENGTH : float = 20.0
			$arrow.clear_points()
			var arrow_dir: Vector2 = (data_points[i].position - map_points[j].position).normalized()
			$arrow.add_point(map_points[j].position)
			$arrow.add_point(data_points[i].position)
			$arrow.add_point(data_points[i].position + arrow_dir.rotated(0.75*PI)*TICK_LENGTH)
			$arrow.add_point(data_points[i].position)
			$arrow.add_point(data_points[i].position + arrow_dir.rotated(-0.75*PI)*TICK_LENGTH)
		
		if show_neighbourhood:
			remove_child(neighbourhood)
			neighbourhood = data_point_scene.instantiate()
			neighbourhood.position = map_points[j].position
			neighbourhood.scale = Vector2(1,1)*neighbourhood_size/10.0
			neighbourhood.get_node("TextureRect").material.set_shader_parameter("colour", Vector4(0.2,0.7,0.2,0.5))
			add_child(neighbourhood)
		
		var points_in_neighbourhood : Array[int]
		for k in map_size:
			if (map_points[j].position - map_points[k].position).length() < 3*neighbourhood_size:
				points_in_neighbourhood.append(k)
		
		# do the winning point last so we update the others with the old value
		for k in points_in_neighbourhood:
			if k != j:
				var kernel : float = neighbourhood_kernel( (map_points[j].position - map_points[k].position).length() )
				map_points[k].position = map_points[k].position + learning_rate * kernel * ( data_points[i].position - map_points[k].position )
				$line_between_map_points.set_point_position(k, map_points[k].position)
		map_points[j].position = map_points[j].position + learning_rate * ( data_points[i].position - map_points[j].position )
		$line_between_map_points.set_point_position(j, map_points[j].position)
		learning_rate = learning_rate*0.999
		#paused = true
		

func select_point(i: int) -> int:
	# find the nearest map point to a point i
	var nearest_map_point : int = 0
	var shortest_dist : float = 1000000.0
	for j in map_size:
		var dist : float = (data_points[i].position - map_points[j].position).length()
		if dist < shortest_dist:
			nearest_map_point = j
			shortest_dist = dist
			
	return nearest_map_point


func neighbourhood_kernel(d: float) -> float:
	print("----------------------")
	print(d)
	print(neighbourhood_size)
	print(((d/neighbourhood_size)**2)/2.0)
	print(exp((-(d/neighbourhood_size)**2)/2.0))
	return exp((-(d/neighbourhood_size)**2)/2.0)
	#return max((1.0 - (d/neighbourhood_size)**2.0)**3.0, 0.0)
