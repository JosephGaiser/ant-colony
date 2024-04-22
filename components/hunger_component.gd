class_name HungerComponent
extends Node2D

signal hungry(sasiation: float) # emits hunger %

@export var health_component: HealthComponent
@export var min_hunger_damange: float = 1.0
@export var max_hunger_damange: float = 5.0
@export var hunger_tick_length: float = 5.0
@export var rate_of_depleation: float = 1.0
@export var max_sasitation: float = 100
@export var sasiation_threshold: float = .75

@onready var hunger_timer: Timer = $HungerTimer

var current_sasiation: float = 0.00

func _ready():
	hunger_timer.set_wait_time(hunger_tick_length)
	hunger_timer.start()
	current_sasiation = max_sasitation # start at max sasiation


func hunger_pain():
	var damage: float = randf_range(min_hunger_damange, max_hunger_damange)
	health_component.take_damage(damage)


func eat(food: Food) -> float:
	if food:
		current_sasiation += food.get_value()
		food.consumed_by(self)
	return get_sasiation()


# Current Sasiation %
func get_sasiation() -> float:
	return current_sasiation / max_sasitation


func is_hungry() -> bool:
	if get_sasiation() <= sasiation_threshold:
		return true
	return false


func _on_hungar_timer_timeout():
	if current_sasiation > 0:
		current_sasiation -= rate_of_depleation
	if current_sasiation <= 0:
		current_sasiation = 0
		hunger_pain()
	if is_hungry():
		hungry.emit(get_sasiation())

