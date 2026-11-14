extends RigidBody2D
@export var area : Area2D
@export var follow_force: float = 1024.0
@export var max_speed: float = 512.0
@export var damping: float = 32.0
@export var sprite : Sprite2D
@export var sprite_2 : Sprite2D
@export var collision_1 : CollisionShape2D
@export var collision_2 : CollisionShape2D
var holding : bool = false;
var hovering : bool = false;

func set_karage_type(type : bool):
	sprite.visible = !type
	sprite_2.visible = type

func set_size(size : float):
	var _scale = Vector2(size, size)
	sprite.scale = _scale
	sprite_2.scale = _scale
	collision_1.scale = _scale
	collision_2.scale = _scale

func _ready() -> void:
	area.mouse_entered.connect(entered)
	area.mouse_exited.connect(exited)
	set_karage_type(randi_range(0,1))
	set_size(randf_range(1,2))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				holding = hovering
			else:
				holding = false
func entered():
	hovering = true
func exited():
	hovering = false

func _physics_process(delta: float) -> void:
	if(!holding) : return
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	var force = direction * follow_force
	force -= linear_velocity * damping
	
	apply_central_force(force)

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
