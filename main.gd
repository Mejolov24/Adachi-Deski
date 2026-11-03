extends Control
@export var head : AnimatedSprite2D
@export var blush : Sprite2D
@export var pat_area : Control
enum head_t {
	NORMAL,
	BLINK
}
func set_head(value : head_t):
	head.frame = value
	pass

var blink_timer : Timer
@export var min_blink_interval : float = 4.0
@export var max_blink_interval : float = 6.0
@export var blink_duration : float = 0.12
var blinking_in_progress = false
var is_mouse_inside = false
var blush_tween : Tween

@export var pat_target : float = 412.0   # The threshold required to trigger pat()
@export var pat_decay_rate : float = 48.0   # How fast the accumulation drains per second when not moving fast enough
@export var pat_multiplier : float = 0.5
var pat_accumulation : float = 0.0

func set_blush(state):
	if blush_tween and blush_tween.is_running():
		blush_tween.kill()
	blush_tween = create_tween()
	blush_tween.tween_property(blush, "modulate:a",state,1)

func on_blink():
	blinking_in_progress = !blinking_in_progress
	if(blinking_in_progress):
		blink_timer.wait_time = blink_duration
		set_head(head_t.NORMAL)
	else:
		blink_timer.wait_time = randf_range(min_blink_interval, max_blink_interval)
		set_head(head_t.BLINK)

func mouse_pat_in() -> void:
	is_mouse_inside = true
	print("IN")
func mouse_pat_out() -> void:
	is_mouse_inside = false
	print("OUT")

func setup_pat_area():
	pat_area.mouse_entered.connect(mouse_pat_in)
	pat_area.mouse_exited.connect(mouse_pat_out)

func setup_blink_timer():
	blink_timer = Timer.new()
	blink_timer.wait_time = max_blink_interval
	blink_timer.timeout.connect(on_blink)
	add_child(blink_timer)
	blink_timer.start()


func pat_process(intensity : int, delta : float):
	pat_accumulation += (intensity * pat_multiplier) * delta
	pat_accumulation = max(0.0, pat_accumulation - (pat_decay_rate * delta))
	var pat_percentage = clamp(pat_accumulation / pat_target, 0.0, 1.0)
	
	if pat_accumulation >= pat_target:
		pass
	print("Accumulation: ", pat_accumulation, "Percentage: ", pat_percentage)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_blink_timer()
	setup_pat_area()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var mouse_speed = 0.0
func _process(delta: float) -> void:
	if is_mouse_inside:
		var mouse_velocity = Input.get_last_mouse_velocity()
		mouse_speed = mouse_velocity.length()
	else:
		mouse_speed = 0
	pat_process(mouse_speed,delta);
	#print("Pat speed: ", speed)
	
