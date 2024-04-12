class_name Ant
extends CharacterBody2D

# Ant properties
@export var colony_location: Marker2D
@export var current_state: AntState = AntState.SEARCHING
@export var move_speed: float = 50
@export var lerp_speed: float = 0.1
@export var max_velocity: float = 10.0
@export var rotation_speed: float = 2 * PI / 5  # 5 seconds to complete a full circle
@export var carry_capacity: float = 100.00
@export var defend_radius: float = 100.0
@export var leading: bool = false
# Random walk variables
@export var random_walk_distance: float = 100.0
@export var random_walk_delay: float = 1.0

# References to other nodes
@onready var reach: Area2D = %Reach
@onready var vision: Area2D = %Vision
@onready var swarm: Area2D = %Swarm
@onready var colony = %Colony

# Internal variables
var target
var carry_weight: float         = 0.00
var previous_state: AntState    = current_state
var inventory: Array            = []
var seen_food: Array            = []
var current_angle: float        = 0.0
var time_since_last_walk: float = 0.0
var swarming: bool              = false
var leader: Ant                 = null
var ant_in_front: Ant           = null
var followers: Array            = []
# Enum for Ant states
enum AntState {
	SEARCHING,
	GOING_TO_TARGET,
	CARRYING_FOOD,
	RETURNING_TO_NEST,
	DEFENDING_NEST,
	FOLLOWING,
	IDLE,
}


func get_details() -> Array[Dictionary]:
	return [
		{"name": "Current State", "value": AntState.find_key(current_state)},
		{"name": "Target", "value": str(target)},
		{"name": "Position", "value": str(global_position)},
		{"name": "Velocity", "value": str(velocity)},
		{"name": "Rotation", "value": str(rotation)},
		{"name": "Carry Weight", "value": str(carry_weight)},
		{"name": "Carry Capacity", "value": str(carry_capacity)},
		{"name": "Inventory", "value": str(inventory.size())},
		{"name": "Seen Food", "value": str(seen_food.size())},
		{"name": "Leading", "value": str(leading)},
		{"name": "Swarming", "value": str(swarming)},
		{"name": "Followers", "value": str(followers.size())},
		{"name": "Leader", "value": str(leader)},
		{"name": "Ant in Front", "value": str(ant_in_front)},
	]


func _physics_process(delta):
	time_since_last_walk += delta
	match current_state:
		AntState.DEFENDING_NEST:
			defend_nest(delta)
		AntState.SEARCHING:
			search_for_food(delta)
		AntState.GOING_TO_TARGET:
			go_to_target()
		AntState.CARRYING_FOOD:
			carry_food()
		AntState.RETURNING_TO_NEST:
			return_to_nest()
		AntState.FOLLOWING:
			follow_leader()
		AntState.IDLE:
			pass

	if velocity != Vector2.ZERO: # Currently Moveing
		set_rotation(lerp(rotation, velocity.angle(), lerp_speed))
	if target != null:
		var direction = (target - global_position).normalized()
		velocity = direction * move_speed
	if move_and_slide():
		# If we hit something while moving, stop moving
		velocity = Vector2.ZERO
		# if we are searching for food and we hit a wall, change direction
		if current_state == AntState.SEARCHING:
			current_angle += PI
			current_angle = fmod(current_angle, 2 * PI)  # Keep the angle between 0 and 2*PI

func defend_nest(delta):
	if colony_location == null:
		set_state(AntState.SEARCHING)
	else:
		current_angle += rotation_speed * delta
		current_angle = fmod(current_angle, 2 * PI)  # Keep the angle between 0 and 2*PI
		target = colony_location.global_position + Vector2(cos(current_angle), sin(current_angle)) * defend_radius
		var direction = (target - position).normalized()
		velocity = direction * move_speed


func search_for_food(_delta):
	if seen_food.is_empty():
		if time_since_last_walk >= random_walk_delay:
			# Pick an angle between 90 degrees from the current angle so we don't walk back on ourselves
			var angle: float = current_angle + (PI / 2) + randf_range(-PI / 4, PI / 4)
			target = position + Vector2(cos(angle), sin(angle)) * random_walk_distance
			time_since_last_walk = 0.0
	else:
		target = seen_food[0]
		set_state(AntState.GOING_TO_TARGET)


func go_to_target() -> void:
	if target == null:
		set_state(AntState.SEARCHING)
	if target != null && position.distance_to(target) < 20:
		print("Reached target: ", target)
		seen_food.erase(target)
		target = null


func carry_food():
	if carry_weight >= carry_capacity:
		set_state(AntState.RETURNING_TO_NEST)
	else:
		set_state(AntState.SEARCHING)


func return_to_nest() -> void:
	if colony_location == null:
		set_state(AntState.IDLE)
		return
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
		set_state(AntState.GOING_TO_TARGET)


func follow_leader() -> void:
	if leader == null:
		print("Lost leader!")
		set_state(AntState.SEARCHING)
		return
	if ant_in_front == null:
		print("Lost ant in front!")
		set_state(AntState.SEARCHING)
		return
	# target behind the ant in front
	target = ant_in_front.global_position - (ant_in_front.velocity.normalized() * 50)


func set_state(state: AntState) -> void:
	if state == current_state:
		return
	if current_state == AntState.FOLLOWING:
		stop_following()
	previous_state = current_state
	current_state = state
	print("State change: ", AntState.find_key(previous_state), " to ", AntState.find_key(current_state))


func stop_following():
	leader.remove_follower(self)
	leader = null # Stop following the leader
	swarming = false


func get_ant_to_follow() -> Ant:
	if followers.is_empty():
		print("IM THE LEADER!")
		return self # If we have no followers, we are the ant to follow
	print(followers.back(), "is the ant_in_front")
	return followers.back()  # Return the last follower in the list


func set_leader(new_leader: Ant) -> void:
	print("new leader! ", new_leader)
	swarming = true
	leader = new_leader
	ant_in_front = leader.get_ant_to_follow()
	leader.add_follower(self)
	set_state(AntState.FOLLOWING)


func is_leading() -> bool:
	return leading


func add_follower(follower: Ant) -> void:
	followers.append(follower)
	print("Added follower: ", follower)


func remove_follower(follower: Ant) -> void:
	followers.erase(follower)
	print("Removed follower: ", follower)


func _on_reach_body_entered(body):
	if body.is_in_group("food"):
		pickup_food(body)


func _on_vision_body_entered(body):
	if body.is_in_group("food"):
		see_food(body)


func _on_swarm_body_entered(body) -> void:
	if is_leading():
		return # TODO Follow if they are a leader and have move followers
	if swarming == true:
		return
	if body.has_method("is_leading"):
		print("possible new leader ", body)
		if leader == null && body.is_leading():
			set_leader(body)
