extends Control

# stop_game is emitted when cancel button is pressed.
signal stop_game

onready var Game = get_node("/root/Game")
onready var MessageLabel: Label = $"Message Label"

enum ConnectState {
	HostingFailed,

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
		ConnectState.HostingFailed: MessageLabel.text = "Hosting failed\n\nPort " + str(Game.current_port) + "\nalready in use"
		ConnectState.Connecting: MessageLabel.text = "Connecting..."
		ConnectState.ConnectionLost: MessageLabel.text = "Connection lost"
		ConnectState.ConnectionKicked: MessageLabel.text = "Kicked!"
		ConnectState.ConnectionFailed: MessageLabel.text = "Connection failed"
		ConnectState.ConnectionAborted: MessageLabel.text = "Connection aborted"

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("stop_game")