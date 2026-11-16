extends Node
var httprequester : HTTPRequest

const current_release = "1.0.0-alpha"
const api = "https://api.github.com/repos/Mejolov24/Adachi-Deski/releases/latest"
const web = "https://github.com/Mejolov24/Adachi-Deski/releases/latest"

func _ready() -> void:
	httprequester = HTTPRequest.new()
	add_child(httprequester)
	httprequester.request_completed.connect(_request_completed)
	httprequester.request(api)

func _request_completed(result, response_code, headers, body):
	if result != 0: return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if !(json is Dictionary): return
	if !(json.has("name")): return
	var latest_release : String =  json["name"]
	if(current_release == latest_release): return
	send_update_message()

func send_update_message():
	var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = load("res://resources/audio/rei/new update.wav")
	add_child(audio_player)
	audio_player.play()
	OS.shell_open(web)
