extends Node2D

#############
# THIS IS A WORK IN PROGRESS #
# Do not use in production #
#############

#############
# One-line setup for wallet authentication using project key
@onready var auth = Ada.auth.init("5a79ed29-7140-4f8c-9f54-434a415d8c61")
#############

@onready var label: Label = $Control/CenterContainer/VBoxContainer/Label
@onready var connect_button: Button = $Control/CenterContainer/VBoxContainer/ConnectButton
@onready var load_button: Button = $Control/CenterContainer/VBoxContainer/LoadButton
@onready var cancel_button: Button = $Control/CenterContainer/VBoxContainer/CancelButton
@onready var item_list: ItemList = $Control/CenterContainer/VBoxContainer/ItemList


const API_URL = "http://localhost:3000/api";
const AUTH_URL = "http://localhost:3000/auth";

var handshake: String = "";
var poll_timer: Timer;
var polling_request;
var handshake_request;

func _ready() -> void:
	auth.connect("success", _on_auth_success)
	auth.connect("loaded", _on_load_success)
	connect_button.connect("pressed", _on_connect_pressed)
	cancel_button.connect("pressed", _on_cancel_pressed)
	load_button.connect("pressed", _on_load_pressed)
	cancel_button.hide()
	label.text = "Log in with your wallet"
	
func _on_connect_pressed() -> void:
	auth.start()
	connect_button.hide()
	cancel_button.show()
	label.text = "Waiting for auth..."
	
func _on_cancel_pressed() -> void:
	auth.cancel();
	cancel_button.hide()
	connect_button.show()
	label.text = ""
	
func _on_auth_success() -> void:
	cancel_button.hide()
	load_button.show()
	label.text = "Verified !"

func _on_load_pressed() -> void:
	auth.load_assets()
	label.text = "Loading assets..."
	load_button.hide()
	
func _on_load_success(assets: Array) -> void:
	label.text = "Loaded " + str(assets.size()) + " assets!"
	item_list.show()
	for asset in assets:
		if asset and asset.onchain_metadata:
			if "name" in asset.onchain_metadata:
				item_list.add_item(asset.onchain_metadata["name"])
			elif "title" in asset.onchain_metadata:
				item_list.add_item(asset.onchain_metadata["title"])
			
