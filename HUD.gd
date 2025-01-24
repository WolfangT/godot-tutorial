extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
signal connect_to_game(ip_address)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartButton.pressed.connect(_on_start_button_pressed)
	$ConnectButton.pressed.connect(_on_connect_button_pressed)
	$MessageTimer.timeout.connect(_on_message_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func hide_buttons():
	$StartButton.hide()
	$ConnectButton.hide()
	$IPAddress.hide()

func _on_start_button_pressed():
	hide_buttons()
	start_game.emit()

func _on_connect_button_pressed():
	hide_buttons()
	var ip_address = $IPAddress.get_line(0)
	connect_to_game.emit(ip_address)

func _on_message_timer_timeout():
	$Message.hide()
