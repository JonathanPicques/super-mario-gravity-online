var instance: NetworkedMultiplayerPeer

# create_server creates a new NetworkedMultiplayerPeer server.
# @impure
func create_server() -> NetworkedMultiplayerPeer:
	instance = NetworkedMultiplayerENet.new()
	return instance

# create_client creates a new NetworkedMultiplayerPeer client.
# @impure
func create_client() -> NetworkedMultiplayerPeer:
	instance = NetworkedMultiplayerENet.new()
	return instance

# @impure
func host(ip: String, port: int, max_peers = 4) -> bool:
	return instance.create_server(port, max_peers) == 0

# @impure
func join(ip: String, port: int) -> bool:
	return instance.create_client(ip, port) == 0

# @impure
func poll():
	pass

# @impure
func close():
	instance.close_connection()
	instance = null