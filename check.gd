extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	if OS.has_feature('web'):
		#var _get_data_callback = JavaScriptBridge.create_callback(_get_state_data)
		#var cardano = JavaScriptBridge.get_interface("cardano")
		#var _get_data_callback = JavaScriptBridge.create_callback(_get_state_data)
		var cardano = JavaScriptBridge.get_interface("cardano")
		var res = await cardano.isEnabled()
		print(res)
		
	else:
		print("The JavaScriptBridge singleton is NOT available")


func myCallback(args):
	# Will be called with the parameters passed to the "forEach" callback
	# [0, 0, [JavaScriptObject:1173]]
	# [255, 1, [JavaScriptObject:1173]]
	# ...
	# [0, 9, [JavaScriptObject:1180]]
	print(args)
