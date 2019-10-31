extends Control

# stop_game is emitted when cancel button is pressed.
signal stop_game

onready var Game = get_node("/root/Game")
onready var error = Game.StopError.none
onready var MessageLabel: Label = $"Message Label"

# set_error changes the connect menu error.
# @impure
func set_error(new_error: int):
	error = new_error
	match error:
		Game.StopError.none: MessageLabel.text = "Connecting..."
		Game.StopError.hosting_failed: MessageLabel.text = "Hosting failed"
		Game.StopError.joining_failed: MessageLabel.text = "Joining failed"
		Game.StopError.connection_lost: MessageLabel.text = "Connection lost"
		Game.StopError.connection_failed: MessageLabel.text = "Connection failed"

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("stop_game")