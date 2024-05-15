@tool
class_name WalletAuth
extends Node

const API_URL = "http://localhost:3000/api";
const AUTH_URL = "http://localhost:3000/auth";

var handshake: String = "";
var poll_timer: Timer;
var handshake_request: HTTPRequest;
var polling_request: HTTPRequest;
var project_key: String;
var assets: Array;

signal success;
signal loaded;
#signal error;

func init(_project_key: String):
	project_key = _project_key;
	return self;
	
func _ready():
	handshake_request = HTTPRequest.new();
	add_child(handshake_request);
	handshake_request.request_completed.connect(_on_handshake_completed)

func cancel():
	handshake = "";
	if poll_timer:
		poll_timer.stop()
	#emit_signal('canceled')
	
func start():
	if handshake_request:
		handshake_request.request(API_URL + "/handshake?projectKey=" + project_key)
	else:
		print("Error: handshake_request is not initialized")
	
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
		#$Label.text = "Verified!"
		poll_timer.stop()
		#$CancelButton.hide()
		save_jwt(json.token.jwt)
		emit_signal('success')
		print("load", load_jwt())

func save_jwt(jwt: String):
	var file = FileAccess.open("user://jwt.dat", FileAccess.WRITE)
	file.store_string(jwt)

func load_jwt():
	var file = FileAccess.open("user://jwt.dat", FileAccess.READ)
	var jwt = file.get_as_text()
	return jwt;

func load_assets():
	var jwt = load_jwt();
	var assets_request = HTTPRequest.new();
	add_child(assets_request);
	assets_request.request_completed.connect(_on_assets_loaded)
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + jwt
	]
	
	assets_request.request(API_URL + "/assets", headers)

func _on_assets_loaded(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	assets = json.assets
	print("Loaded ", assets.size(), " assets")
	emit_signal('loaded', assets)
