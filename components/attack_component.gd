class_name AttackComponent
extends Node2D

@export var attack: Attack
@export var hitbox_shape: CollisionShape2D
@export var parent_body: CharacterBody2D

@onready var attack_timer: Timer = Timer.new()

var target: HitboxComponent

func _ready():
	add_child(hitbox_shape)
	add_child(attack_timer)
	attack_timer.wait_time = attack.cooldown
	attack_timer.connect("timeout", _on_attack_timer_timeout)


func _on_attack_timer_timeout():
	print("timout!", self)
	if target:
		do_attack(target)



func do_attack(hitbox: HitboxComponent):
	print("spanking a hitbox ", hitbox)
	hitbox.damage(attack)
	attack_timer.start()


func _on_area_entered(area):
	if area is HitboxComponent:
		if !area.is_friendly(parent_body.colony):
			target = area
			do_attack(area)


func _on_area_exited(area):
	if area is HitboxComponent:
		if !area.is_friendly(parent_body.colony):
			target = null
