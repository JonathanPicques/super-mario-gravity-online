var server := false
var instance: NetworkedMultiplayerPeer
var was_connected := false

# create_server creates a new NetworkedMultiplayerPeer server.
# @impure
func create_server() -> NetworkedMultiplayerPeer:
	server = true
	instance = WebSocketServer.new()
	return instance

# create_client creates a new NetworkedMultiplayerPeer client.
# @impure
func create_client() -> NetworkedMultiplayerPeer:
	server = false
	instance = WebSocketClient.new()
	return instance

# @impure
func host(ip: String, port: int, max_peers = 4) -> bool:
	return instance.listen(port, [], true) == 0

# @impure
func join(ip: String, port: int) -> bool:
	return instance.connect_to_url("ws://" + ip + ":" + String(port), [], true) == 0

# @impure
func poll():
	if instance:
		instance.poll()

# @impure
func close():
	match server:
		true: instance.stop()
		false: instance.disconnect_from_host()
	server = false
	instance = null
	was_connected = false