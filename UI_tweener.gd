class_name  UITweener
extends Area2D

@export var target : Node
@export var hide_position : Vector2
@export var show_position : Vector2
@export var duration : float = 0.5
@export var easing : Tween.EaseType
@export var transition : Tween.TransitionType
@export var hide_timeout : float = 1
var tweener : Tween
var timer : Timer

func set_value(value : bool):
	if(value):show_anim()
	else: hide_anim()

func show_anim():
	timer.stop()
	if tweener and tweener.is_valid(): tweener.kill()
	tweener = create_tween()
	tweener.set_ease(easing)
	tweener.set_trans(transition)
	tweener.tween_property(target,"position",show_position,duration)

func on_exit_area():
	timer.wait_time = hide_timeout
	timer.start()

func hide_anim():
	if tweener and tweener.is_valid(): tweener.kill()
	tweener = create_tween()
	tweener.set_ease(easing)
	tweener.set_trans(transition)
	tweener.tween_property(target,"position",hide_position,duration)

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = hide_timeout
	timer.timeout.connect(hide_anim)
	add_child(timer)
	target.position = hide_position
	mouse_entered.connect(show_anim)
	mouse_exited.connect(on_exit_area) 
