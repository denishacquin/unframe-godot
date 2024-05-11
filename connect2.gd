extends Node2D

@onready var handshake_request: HTTPRequest = $HandshakeRequest
@onready var polling_request: HTTPRequest = $PollingRequest
@onready var label: Label = $Label

const API_URL = "http://localhost:3000/api";
const AUTH_URL = "http://localhost:3000/auth";

var handshake = "";
var poll_timer;

func _ready() -> void:
	pass;
	
func _on_button_pressed() -> void:
	init_handshake();
	
func init_handshake():
	$HandshakeRequest.request_completed.connect(_on_handshake_completed)
	$HandshakeRequest.request(API_URL + "/handshake")
	
func _on_handshake_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json.handshake)
	handshake = json.handshake
	navigate_to_auth(json.handshake)

func navigate_to_auth(handshake: String):
	OS.shell_open(AUTH_URL + "?handshake=" + handshake)
	start_polling()

func init_poll_timer():
	poll_timer = Timer.new()
	poll_timer.wait_time = 2
	poll_timer.one_shot = false
	poll_timer.timeout.connect(poll)
	add_child(poll_timer)
	
func start_polling():
	print("polling...")
	$Label.text = "Waiting for auth..."
	$PollingRequest.request_completed.connect(_on_poll_completed)
	init_poll_timer()
	poll_timer.start()

func poll():
	print("poll")
	$PollingRequest.request(API_URL + "/poll?handshake=" + handshake)
	
func _on_poll_completed(result, response_code, headers, body):
	print("polled")
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if json and json["token"]["verified"]:
		print('VERIFIED !')
		$Label.text = "Verified!"
		poll_timer.stop()
