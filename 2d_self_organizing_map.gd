extends Node2D

var screen_size : Vector2

var data_size : int = 1024
var map_size : int = 64

var data_point_scene
var map_point_scene
var data_points : Array[Node2D]
var map_points : Array[Node2D]

func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	data_point_scene = preload("res://data_point.tscn")
	map_point_scene = preload("res://map_point.tscn")
	
	initialize_data("sin")
	initialize_map("linear")

func initialize_data(data_type: String) -> void:
	# initialize the random data
	if data_type == "sin":
		for i in data_size:
			var x : float = randf()*screen_size.x
			var y : float = 0.5*(sin(x) + 1)*screen_size.y
			var point_instance = data_point_scene.instantiate()
			point_instance.position = Vector2(x,y)
			add_child(point_instance)
			point_instance.get_node("TextureRect").material.set_shader_parameter("colour", Vector4(1.0, 1.0, 1.0, 1.0))
			data_points.append(point_instance)

func initialize_map(map_type: String) -> void:
	if map_type == "linear":
		for i in map_size:
			var x : float = (float(i)/float(map_size))*screen_size.x
			var y : float = screen_size.y/2
			var point_instance = map_point_scene.instantiate()
			point_instance.position = Vector2(x,y)
			add_child(point_instance)
			point_instance.get_node("TextureRect").material.set_shader_parameter("colour", Vector4(1.0, 0.0, 0.0, 1.0))
			map_points.append(point_instance)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
