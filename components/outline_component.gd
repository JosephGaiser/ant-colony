class_name OutlineComponent
extends Node

@export var sprite: Sprite2D
@export var line_color: Color = Color.AQUA
@export var line_thickness: float =  40.0
@export var material: ShaderMaterial

var material_dupe: ShaderMaterial

func _ready():
	material_dupe = material.duplicate()
	set_line_color(line_color)
	update_material()


func update_material():
	material_dupe.set_shader_parameter("line_color", line_color)	
	material_dupe.set_shader_parameter("line_thickness", line_thickness)
	sprite.set_material(material_dupe)


func set_line_color(color: Color):
	line_color = color
	update_material()


func set_line_thickness(thickness: float):
	line_thickness = thickness
	update_material()

