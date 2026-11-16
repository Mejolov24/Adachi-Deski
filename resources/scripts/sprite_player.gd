class_name QuickSpritePlayer
extends Sprite2D
@export var FPS : int = 16
@export var start_frame : int = 0
@export var end_frame : int = 0
@export var looping : bool = false
@export var auto_start : bool = false
@export var hide_on_stop : bool = true
var playing : bool = false
var current_frame : int = 0
var time_accumulator : float = 0.0

signal finished

func play():
	frame = start_frame
	current_frame = start_frame
	time_accumulator = 0.0
	playing = true
	if(hide_on_stop): show()

func stop() -> void:
	playing = false
	time_accumulator = 0.0
	if(hide_on_stop): hide()

func _ready() -> void: if (auto_start): play()

func _process(delta: float) -> void:
	if(!playing): return
	var frame_duration : float = 1.0 / float(FPS)
	time_accumulator += delta
	
	if time_accumulator < frame_duration: return
	
	time_accumulator -= frame_duration
	current_frame += 1
	
	if current_frame >= end_frame:
		if looping: current_frame = start_frame
		else:
			if(hide_on_stop): hide()
			playing = false
			finished.emit()
	frame = current_frame
