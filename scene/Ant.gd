class_name Ant
extends CharacterBody2D

# Ant properties
@export var move_speed: int = 50
@export var lerp_speed: float = 0.1
@export var rotation_speed: float = 2 * PI / 5  # 5 seconds to complete a full circle
@export var carry_capacity: float = 100.00
@export var colony_location: Marker2D
@export var defend_radius: float = 100.0
@export var current_state: AntState = AntState.DEFENDING_NEST
@export var size: Vector2 = Vector2(0.2, 0.2)
@export var leading: bool = false

# Random walk variables
@export var random_walk_distance: float = 100.0
@export var random_walk_delay: float = 1.0

# References to other nodes
@onready var reach: Area2D = %Reach
@onready var vision: Area2D = %Vision
@onready var swarm: Area2D = %Swarm

# Internal variables
var target
var carry_weight: float         = 0.00
var previous_state: AntState    = current_state
var inventory: Array            = []
var seen_food: Array            = []
var current_angle: float        = 0.0
var time_since_last_walk: float = 0.0
var swarming: bool = false
var leader: Ant

# Enum for Ant states
enum AntState {
	SEARCHING,
	GOING_TO_FOOD,
	CARRYING_FOOD,
	RETURNING_TO_NEST,
	DEFENDING_NEST,
	FOLLOWING,
}

func _ready():
	scale = size

func _physics_process(delta):
	time_since_last_walk += delta

	match current_state:
		AntState.DEFENDING_NEST:
			defend_nest(delta)
		AntState.SEARCHING:
			search_for_food(delta)
		AntState.GOING_TO_FOOD:
			go_to_food()
		AntState.CARRYING_FOOD:
			carry_food()
		AntState.RETURNING_TO_NEST:
			return_to_nest()
		AntState.FOLLOWING:
			follow_leader()
		_:
			pass
	if velocity != Vector2.ZERO:
		rotation = lerp(rotation, velocity.angle(), lerp_speed)
	if target != null:
		var direction = (target - global_position).normalized()
		velocity = direction * move_speed
	move_and_slide()


func defend_nest(delta):
	if colony_location == null:
		set_state(AntState.SEARCHING)
	else:
		current_angle += rotation_speed * delta
		current_angle = fmod(current_angle, 2 * PI)  # Keep the angle between 0 and 2*PI
		target = colony_location.global_position + Vector2(cos(current_angle), sin(current_angle)) * defend_radius
		var direction = (target - global_position).normalized()
		velocity = direction * move_speed


func search_for_food(_delta):
	if seen_food.is_empty():
		if time_since_last_walk >= random_walk_delay:
			# Select a random direction to walk in
			var angle: float = randf_range(0, 2 * PI)
			target = position + Vector2(cos(angle), sin(angle)) * random_walk_distance
			time_since_last_walk = 0.0
	else:
		set_state(AntState.GOING_TO_FOOD)


func go_to_food():
	if seen_food.is_empty():
		set_state(AntState.SEARCHING)
	if target == null && !seen_food.is_empty():
		target = seen_food[0]
	if target != null && position.distance_to(target) < 15:
		print("Reached target: ", target)
		seen_food.erase(target)
		target = null
		set_state(AntState.SEARCHING)


func carry_food():
	if carry_weight >= carry_capacity:
		set_state(AntState.RETURNING_TO_NEST)
	else:
		set_state(AntState.SEARCHING)


func return_to_nest():
	target = colony_location.global_position
	if position.distance_to(target) < 75:
		if inventory.is_empty():
			set_state(previous_state)
		else:
			for item in inventory:
				print("dropping item: ", item)
				carry_weight -= 25.00
			inventory.clear()


func pickup_food(body):
	print("Picking up: ", body)
	inventory.append(body)
	seen_food.erase(body.global_position)
	carry_weight += 25.00 # TODO: food.weight
	body.queue_free()
	set_state(AntState.CARRYING_FOOD)


func see_food(body):
	print("Saw: ", body)
	if !seen_food.has(body.global_position):
		seen_food.append(body.global_position)
		target = body.global_position
		set_state(AntState.GOING_TO_FOOD)
	else:
		print("already aware of: ", body)


func follow_leader() -> void:
	if leader == null:
		set_state(AntState.SEARCHING)
		return
	print("following ", leader)
	target = leader.global_position
	

func set_state(state: AntState):
	if current_state == AntState.FOLLOWING:
		leader = null
	previous_state = current_state
	current_state = state
	print("State change: ", AntState.find_key(previous_state), " to ", AntState.find_key(current_state))


func set_leader(ant: Ant):
	swarming = true
	leader = ant
	set_state(AntState.FOLLOWING)


func is_leading() -> bool:
	print("leader check!")
	return leading


func _on_reach_body_entered(body):
	if current_state == AntState.GOING_TO_FOOD:
		if body.is_in_group("food"):
			pickup_food(body)


func _on_vision_body_entered(body):
	if body.is_in_group("food"):
		see_food(body)


func _on_swarm_body_entered(body):
	if is_leading():
		return # TODO Follow if they are a leader and have move followers
	if swarming == true:
		print("already swarming")
		return
	if body.has_method("is_leading"):
		if body.is_leading():
			print("new leader! ", body)
			set_leader(body)


func _on_swarm_body_exited(_body):
	pass
