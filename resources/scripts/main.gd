extends Control
@export_group("Nodes")
@export var head : AnimatedSprite2D
@export var body : Sprite2D
@export var mouth : AnimatedSprite2D
@export var blush : Sprite2D
@export var pat_area : Area2D
@export var pat_bar : ProgressBar
@export var food_bar : ProgressBar
@export var chiken_bucket : Button
@export var chiken_scene : PackedScene
@export var rei_audio : AudioStreamPlayer
@export var other_audio : AudioStreamPlayer
@export var karage_container : Node


@export_group("Parameters")
@export var min_blink_interval : float = 4.0
@export var max_blink_interval : float = 6.0
@export var blink_duration : float = 0.12

@export var pat_threshold : float = 412.0   # The threshold required to trigger pat()
@export var pat_hard_cap : float = 412.0  # If pat'ed faster than this, doesnt count (to prevent accidental pats)
@export var pat_decay_rate : float = 16.0   # How fast the accumulation drains per second when not moving fast enough
@export var pat_multiplier : float = 0.25
@export_range(0,1) var blush_threshold : float = 0.5 # in perecentage 
@export_range(0,1) var face_change_threshold : float = 0.75 # in perecentage
@export var disable_resonance_fix : bool = false
const resonance_clear_threshold : int = 100

@export var eat_threshold : float = 412.0   # The threshold required to trigger pat()
@export var eat_decay_rate : float = 5   # How fast the accumulation drains per second when not moving fast enough

@export_group("Resources")

@export var eat_sounds : Array[AudioStream]
@export var rei_sounds : Array[AudioStream]
@export var eat_sounds_2 : Array[AudioStream]

var blinking_in_progress = false
var is_mouse_inside = false
var food_inside = false
var blush_tween : Tween

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

var eat_accumulation : float = 0.0
var pat_accumulation : float = 0.0
var current_food
var finished_sound : bool = true
var mouse_speed = 0.0
var is_mouse_held : bool = false
## -- setters -- ##
func set_head(value : head_t):
	head.frame = value
	current_head = value

func set_mouth(value : mouth_t):
	mouth.frame = value

func set_blush(state):
	if blush_tween and blush_tween.is_running():
		blush_tween.kill()
	blush_tween = create_tween()
	blush_tween.tween_property(blush, "modulate:a",state,1)

func blink_head():
	if(current_head == head_t.NORMAL):
		head.frame = head_t.BLINK
	else:
		head.frame = head_t.NORMAL
func restore_head():
	head.frame = current_head

## -- callbacks -- ##

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

func area_out(_area : Area2D):
	food_inside = false
	if(!is_mouse_held): eat()
	set_mouth(mouth_t.NORMAL)


func eat():
	eat_accumulation += 100
	pat_accumulation += 10
	if(current_food): current_food.queue_free()
	other_audio.stream = eat_sounds.pick_random()
	other_audio.play()
	rei_audio.stream = eat_sounds_2.pick_random()
	rei_audio.play()
	set_mouth(mouth_t.NORMAL)

## -- processes -- ##

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_mouse_held = true
			else:
				is_mouse_held = false
				if(food_inside):
					eat()

func eat_process(delta : float):
	eat_accumulation = max(0.0, eat_accumulation - (eat_decay_rate * delta))
	var eat_percentage = clamp(eat_accumulation / eat_threshold, 0.0, 1.0)
	food_bar.value = eat_percentage

func pat_process(intensity : int, delta : float):
	if(intensity > pat_hard_cap): intensity = pat_hard_cap
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
	# check if we have an overlaping chiken to avoid accidental click
	var spawn_pos = get_global_mouse_position()
	if(!disable_resonance_fix):
		for child in karage_container.get_children():
			if child.global_position.distance_to(spawn_pos) < 30: return
	
	var chiken = chiken_scene.instantiate()
	chiken.position = spawn_pos
	chiken.hovering = true
	chiken.holding = true
	chiken.disable_resonance_fix = disable_resonance_fix
	karage_container.add_child(chiken)

## -- setups -- ##

func setup_pat_area():
	pat_area.mouse_entered.connect(func(): is_mouse_inside = true)
	pat_area.mouse_exited.connect(func(): is_mouse_inside = false)
	pat_area.area_entered.connect(area_in)
	pat_area.area_exited.connect(area_out)

func setup_blink_timer():
	blink_timer = Timer.new()
	blink_timer.wait_time = max_blink_interval
	blink_timer.timeout.connect(on_blink)
	add_child(blink_timer)
	blink_timer.start()

func _ready() -> void:
	setup_blink_timer()
	setup_pat_area()
	chiken_bucket.button_down.connect(spawn_chiken)


func _process(delta: float) -> void:
	if is_mouse_inside: mouse_speed = Input.get_last_mouse_velocity().length()
	else: mouse_speed = 0
	
	pat_process(mouse_speed,delta);
	eat_process(delta)
	print(karage_container.get_children().size())


func _on_happynes_value_changed(value: float) -> void:
	pat_decay_rate = value


func _on_food_value_changed(value: float) -> void:
	eat_decay_rate = value

func _on_check_button_toggled(toggled_on: bool) -> void:
	disable_resonance_fix = !toggled_on
	for child in karage_container.get_children():
		child.disable_resonance_fix = !toggled_on
		if(toggled_on):
			child.delete_timer.start()
		else:
			child.delete_timer.stop()


func _on_flip_toggled(value: bool) -> void:
	head.flip_h = value
	body.flip_h = value
	mouth.flip_h = value
	if(value):
		head.offset.x = 90
		mouth.offset.x = 90
	else:
		head.offset.x = 0
		mouth.offset.x = 0


func _on_happynes_max_value_changed(value: float) -> void:
	pat_threshold = value


func _on_food_max_value_changed(value: float) -> void:
	eat_threshold = value
