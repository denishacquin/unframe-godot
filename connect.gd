extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	if OS.has_feature('web'):
		#var console = JavaScriptBridge.get_interface("console")
		var cardano = JavaScriptBridge.get_interface("cardano")
		cardano.enable()
	else:
		print("The JavaScriptBridge singleton is NOT available")

