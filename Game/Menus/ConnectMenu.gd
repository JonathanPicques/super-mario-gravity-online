extends Control

# stop_game is emitted when cancel button is pressed.
signal stop_game

onready var MessageLabel = $"Message Label"

enum ConnectState {
	Connecting,
	ConnectionLost,
	ConnectionKicked,
	ConnectionFailed,
	ConnectionAborted,
}

var state = ConnectState.Connecting

# set_state changes the error menu state.
# @impure
func set_state(new_state: int):
	state = new_state
	match state:
		ConnectState.Connecting: MessageLabel.text = "Connecting..."
		ConnectState.ConnectionLost: MessageLabel.text = "Connection lost"
		ConnectState.ConnectionKicked: MessageLabel.text = "Kicked!"
		ConnectState.ConnectionFailed: MessageLabel.text = "Connection failed"
		ConnectState.ConnectionAborted: MessageLabel.text = "Connection aborted"

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("stop_game")