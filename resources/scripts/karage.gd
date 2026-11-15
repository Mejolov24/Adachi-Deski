extends RigidBody2D
@export var delete_time : float = 15
@export var follow_force: float = 1024.0
@export var max_speed: float = 512.0
@export var damping: float = 32.0

@export var area : Area2D
@export var sprite : Sprite2D
@export var sprite_2 : Sprite2D
@export var collision_1 : CollisionShape2D
@export var collision_2 : CollisionShape2D
@export var disable_resonance_fix : bool = false
var delete_timer : Timer
var delete_tween : Tween

var holding : bool = false;
var hovering : bool = false;

func delete():
	delete_tween = create_tween()
	delete_tween.finished.connect(queue_free)
	delete_tween.tween_property(self, "modulate:a",0,1)

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
	area.mouse_entered.connect(func(): hovering = true)
	area.mouse_exited.connect(func(): hovering = false)
	set_karage_type(randi_range(0,1))
	set_size(randf_range(1,2))
	
	delete_timer =  Timer.new()
	delete_timer.wait_time = delete_time
	delete_timer.timeout.connect(delete)
	add_child(delete_timer)
	if(disable_resonance_fix): return
	delete_timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				holding = hovering
			else:
				holding = false

func _physics_process(_delta: float) -> void:
	if(!holding) : return
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	var force = direction * follow_force
	force -= linear_velocity * damping
	
	apply_central_force(force)

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
