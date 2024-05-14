@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Ada"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/ada_auth/ada.gd")

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
