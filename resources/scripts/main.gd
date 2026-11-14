extends Control
@export var head : AnimatedSprite2D
@export var mouth : AnimatedSprite2D
@export var blush : Sprite2D
@export var pat_area : Area2D
@export var pat_bar : ProgressBar
@export var food_bar : ProgressBar
@export var chiken_bucket : Button
@export var chiken_scene : PackedScene
@export var rei_audio : AudioStreamPlayer
@export var other_audio : AudioStreamPlayer
enum head_t {
	NORMAL,
	BLINK
}
enum mouth_t {
	NORMAL,
	OPEN
}
var current_head = head_t.NORMAL
var blink_timer : Timer
@export var min_blink_interval : float = 4.0
@export var max_blink_interval : float = 6.0
@export var blink_duration : float = 0.12
var blinking_in_progress = false
var is_mouse_inside = false
var food_inside = false
var blush_tween : Tween

@export var pat_threshold : float = 412.0   # The threshold required to trigger pat()
@export var pat_decay_rate : float = 16.0   # How fast the accumulation drains per second when not moving fast enough
@export var pat_multiplier : float = 0.25
@export var blush_threshold : float = 0.5 # in perecentage 
@export var face_change_threshold : float = 0.75 # in perecentage

@export var eat_threshold : float = 412.0   # The threshold required to trigger pat()
@export var eat_decay_rate : float = 5   # How fast the accumulation drains per second when not moving fast enough

@export var eat_sounds : Array[AudioStream]
@export var rei_sounds : Array[AudioStream]
@export var eat_sounds_2 : Array[AudioStream]
var eat_accumulation : float = 0.0
var pat_accumulation : float = 0.0
var current_food
var finished_sound : bool = true

func set_head(value : head_t):
	head.frame = value
	current_head = value
func set_mouth(value : mouth_t):
	mouth.frame = value
func blink_head():
	if(current_head == head_t.NORMAL):
		head.frame = head_t.BLINK
	else:
		head.frame = head_t.NORMAL
func restore_head():
	head.frame = current_head

func set_blush(state):
	if blush_tween and blush_tween.is_running():
		blush_tween.kill()
	blush_tween = create_tween()
	blush_tween.tween_property(blush, "modulate:a",state,1)

func on_blink():
	blinking_in_progress = !blinking_in_progress
	if(blinking_in_progress):
		blink_timer.wait_time = blink_duration
		restore_head()
	else:
		blink_timer.wait_time = randf_range(min_blink_interval, max_blink_interval)
		blink_head()

func area_in(area : Area2D):
	if(area.is_in_group("food")):
		food_inside = true
		current_food = area.get_parent()
		rei_audio.stream = rei_sounds.pick_random()
		rei_audio.play()
		set_mouth(mouth_t.OPEN)
func area_out(area : Area2D):
	food_inside = false
	set_mouth(mouth_t.NORMAL)

func mouse_pat_in() -> void:
	is_mouse_inside = true
func mouse_pat_out() -> void:
	is_mouse_inside = false

func eat():
	eat_accumulation += 100
	pat_accumulation += 50
	current_food.queue_free()
	other_audio.stream = eat_sounds.pick_random()
	other_audio.play()
	rei_audio.stream = eat_sounds_2.pick_random()
	rei_audio.play()
	set_mouth(mouth_t.NORMAL)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pass
			else:
				if(food_inside):
					eat()

func setup_pat_area():
	pat_area.mouse_entered.connect(mouse_pat_in)
	pat_area.mouse_exited.connect(mouse_pat_out)
	pat_area.area_entered.connect(area_in)
	pat_area.area_exited.connect(area_out)

func setup_blink_timer():
	blink_timer = Timer.new()
	blink_timer.wait_time = max_blink_interval
	blink_timer.timeout.connect(on_blink)
	add_child(blink_timer)
	blink_timer.start()

func eat_process(delta : float):
	eat_accumulation = max(0.0, eat_accumulation - (eat_decay_rate * delta))
	var eat_percentage = clamp(eat_accumulation / eat_threshold, 0.0, 1.0)
	food_bar.value = eat_percentage

func pat_process(intensity : int, delta : float):
	pat_accumulation += (intensity * pat_multiplier) * delta
	pat_accumulation = max(0.0, pat_accumulation - (pat_decay_rate * delta))
	var pat_percentage = clamp(pat_accumulation / pat_threshold, 0.0, 1.0)
	var blush_percentage = remap(pat_percentage, blush_threshold, 1.0, 0.0, 1.0)
	blush_percentage = clamp(blush_percentage, 0.0, 1.0)
	set_blush(blush_percentage)
	if (pat_percentage >= face_change_threshold) and is_mouse_inside:
		set_head(head_t.BLINK)
		if(finished_sound):
			finished_sound = false
			rei_audio.stream = rei_sounds.pick_random()
			rei_audio.play()
	else:
		finished_sound = true
		set_head(head_t.NORMAL)
	
	pat_bar.value = pat_percentage

func spawn_chiken():
	var chiken = chiken_scene.instantiate()
	chiken.position = get_global_mouse_position()
	chiken.hovering = true
	chiken.holding = true
	add_child(chiken)

func _ready() -> void:
	setup_blink_timer()
	setup_pat_area()
	
	chiken_bucket.button_down.connect(spawn_chiken)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var mouse_speed = 0.0
func _process(delta: float) -> void:
	if is_mouse_inside:
		var mouse_velocity = Input.get_last_mouse_velocity()
		mouse_speed = mouse_velocity.length()
	else:
		mouse_speed = 0
	pat_process(mouse_speed,delta);
	eat_process(delta)
	#print("Pat speed: ", speed)
