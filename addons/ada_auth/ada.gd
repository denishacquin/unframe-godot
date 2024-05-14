@tool
extends Node

var auth : WalletAuth

func _ready() -> void:
	load_nodes()

func load_nodes() -> void:
	auth = WalletAuth.new()
	add_child(auth)
