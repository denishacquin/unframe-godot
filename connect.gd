extends Node2D

@onready var label: Label = $Label
@onready var connect_button: Button = $ConnectButton
@onready var cancel_button: Button = $CancelButton

const API_URL = "http://localhost:3000/api";
const AUTH_URL = "http://localhost:3000/auth";

var handshake: String = "";
var poll_timer: Timer;
var polling_request;
var handshake_request;

func _ready() -> void:
	$ConnectButton.connect("pressed", _on_connect_pressed)
	$CancelButton.connect("pressed", _on_cancel_pressed)
	$CancelButton.hide()
	print("jwt??", load_jwt())
	
func _on_connect_pressed() -> void:
	init_handshake();

func _on_cancel_pressed() -> void:
	cancel_connect()

func cancel_connect():
	handshake = "";
	if poll_timer:
		poll_timer.stop()
	$CancelButton.hide()
	$ConnectButton.show()
	$Label.text = ""
	
func init_handshake():
	handshake_request = HTTPRequest.new();
	add_child(handshake_request);
	handshake_request.request_completed.connect(_on_handshake_completed)
	handshake_request.request(API_URL + "/handshake")
	$ConnectButton.hide()
	$CancelButton.show()
	
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
	polling_request = HTTPRequest.new();
	add_child(polling_request);
	polling_request.request_completed.connect(_on_poll_completed)
	init_poll_timer()
	poll_timer.start()

func poll():
	print("poll")
	polling_request.request(API_URL + "/poll?handshake=" + handshake)
	
func _on_poll_completed(result, response_code, headers, body):
	print("polled")
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if json and json["token"]["verified"]:
		print('VERIFIED !')
		$Label.text = "Verified!"
		poll_timer.stop()
		$CancelButton.hide()
