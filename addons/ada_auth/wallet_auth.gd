@tool
class_name WalletAuth
extends Node

#const BASE_URL = "https://unfra.me";
const BASE_URL = "http://localhost:3000";

const API_URL = BASE_URL + "/api";
const AUTH_URL = BASE_URL + "/auth";
const JWT_PATH = "user://jwt.dat";

var handshake: String = "";
var poll_timer: Timer;
var handshake_request: HTTPRequest;
var polling_request: HTTPRequest;
var project_key: String;
var assets: Array;
#var isLoggedIn: bool = false;

signal success;
signal loaded;
signal logout;
signal error;

func init(_project_key: String):
	project_key = _project_key;
	init_user_state();
	return self;
	
func reset():
	assets.clear();
	delete_jwt();
	emit_signal("logout");
	
func _ready():
	handshake_request = HTTPRequest.new();
	add_child(handshake_request);
	handshake_request.request_completed.connect(_on_handshake_completed);

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
	var json = handle_http_response(result, response_code, headers, body)
	print(json)
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
	var json = handle_http_response(result, response_code, headers, body)
	print(json)
	if json and json["token"]["verified"]:
		print('VERIFIED !')
		#$Label.text = "Verified!"
		poll_timer.stop()
		#$CancelButton.hide()
		save_jwt(json.token.jwt)
		emit_signal('success')
		load_assets()
		#print("load", load_jwt())

func save_jwt(jwt: String):
	var file = FileAccess.open(JWT_PATH, FileAccess.WRITE)
	file.store_string(jwt)
	file.close()

func load_jwt():
	var file = FileAccess.open(JWT_PATH, FileAccess.READ)
	if file:
		var jwt = file.get_as_text()
		file.close()
		return jwt;
	else:
		return null;

func delete_jwt():
	DirAccess.remove_absolute(JWT_PATH);

func load_assets():
	var jwt = load_jwt();
	var assets_request = HTTPRequest.new();
	add_child(assets_request);
	assets_request.request_completed.connect(_on_assets_loaded)
	print(jwt)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + jwt
	]
	
	assets_request.request(API_URL + "/assets", headers)

func _on_assets_loaded(result, response_code, headers, body):
	var json = handle_http_response(result, response_code, headers, body)
	#print(json)
	if json:
		assets = json.get("assets")
		print("Loaded ", assets.size(), " assets")
		emit_signal('loaded', assets)
	else:
		print('wtf')
func init_user_state():
	if load_jwt():
		#isLoggedIn = true;
		load_assets();
	#else:
		#isLoggedIn = false;

func handle_http_response(result, response_code, headers, body):
	print(result)
	print(response_code)
	#print(headers)
	var error;
	
	if response_code >= 400:
		error = "Request error"

	var json = JSON.parse_string(body.get_string_from_utf8())
	#print(json)
	if json:
		if json.has("error"):
			error = json.error;
		if json.has("message"):
			error = json.message;
	else:
		error = "Unexpected JSON format.";
		
	if error:
		print("handle - error")
		emit_signal('error', error)
		return null;
	else:
		print("handle - json")
		return json;

