extends Node2D

@onready var phantom_camera_2d: PhantomCamera2D = %PhantomCamera2D
@export var max_zoom: Vector2 = Vector2(2.0, 2.0)
@export var min_zoom: Vector2 = Vector2(0.2, 0.2)

func _process(_delta):
	set_position(get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		phantom_camera_2d.set("zoom", clamp(phantom_camera_2d.get("zoom") + Vector2(0.1, 0.1), 	min_zoom, max_zoom))
	elif event.is_action_pressed("zoom_out"):
		phantom_camera_2d.set("zoom", clamp(phantom_camera_2d.get("zoom") - Vector2(0.1, 0.1), 	min_zoom, max_zoom))
	pass
