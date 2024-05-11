extends Node2D

@onready var label: Label = $Label

var _my_js_callback = JavaScriptBridge.create_callback(myCallback) # This
var externalator = JavaScriptBridge.get_interface("externalator")
var cardano = JavaScriptBridge.get_interface("cardano")

func _ready() -> void:
	pass;
	#externalator.addGodotFunction('enableWallet',myCallback)

func _process(delta: float) -> void:
	pass

func check_wallets() -> void:
	if OS.has_feature('web'):
	
		if cardano.nami:
			#godotFunctions.enableWallet()
			#cardano.nami.isEnabled.connect(myCallback)
			cardano.nami.isEnabled().then(myCallback)
			#print(test)
			print("lol")
			
			label.text = "Nami"
		else:
			label.text = "-"
	else:
		print("The JavaScriptBridge singleton is NOT available")

func myCallback(args):
	print('callback!!')
	

func _on_timer_timeout() -> void:
	check_wallets()
