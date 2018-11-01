extends Control

# error_cancel is emitted when cancel button is pressed.
signal connecting_aborted

onready var ErrorMessageLabel = $"Error Message Label"

enum ErrorState {
	Connecting,
	ConnectionLost,
	ConnectionKicked,
	ConnectionFailed,
	ConnectionAborted,
}

var state = ErrorState.Connecting

# set_state changes the error menu state.
# @impure
func set_state(new_state: int):
	state = new_state
	match state:
		ErrorState.Connecting: ErrorMessageLabel.text = "Connecting..."
		ErrorState.ConnectionLost: ErrorMessageLabel.text = "Connection lost"
		ErrorState.ConnectionKicked: ErrorMessageLabel.text = "Kicked!"
		ErrorState.ConnectionFailed: ErrorMessageLabel.text = "Connection failed"
		ErrorState.ConnectionAborted: ErrorMessageLabel.text = "Connection aborted"

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("connecting_aborted")