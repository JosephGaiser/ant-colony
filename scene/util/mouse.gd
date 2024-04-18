extends Node2D

@onready var phantom_camera_2d: PhantomCamera2D = %PhantomCamera2D

func _process(delta):
	position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		phantom_camera_2d.set("zoom", phantom_camera_2d.get("zoom") + Vector2(0.1, 0.1))
	elif event.is_action_pressed("zoom_out"):
		phantom_camera_2d.set("zoom", phantom_camera_2d.get("zoom") - Vector2(0.1, 0.1))
