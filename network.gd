extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost

var server = null
var client = null

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_server(player_name: String):
	server = ENetMultiplayerPeer.new()
	players[server.get_unique_id()] = player_name
	var error = server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error:
		return error
	multiplayer.multiplayer_peer = server
	
func join_server(address: String, player_name: String):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	client = ENetMultiplayerPeer.new()
	players[client.get_unique_id()] = player_name
	var error = client.create_client(address, DEFAULT_PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = client

func _connected_to_server() -> void:
	print("Successfully connected to the server")

func _server_disconnected() -> void:
	# Server kicked us; show error and abort.
	print("Disconnected from the server")
		
func _connection_failed():
	# Could not even connect to server; abort.
	reset_network_connection()

func reset_network_connection() -> void:
	multiplayer.multiplayer_peer = null

func _on_player_connected(id: int):
	print("Player conected")
	print(id)

func _on_player_disconnected(id: int):
	print("Player disconected")
	print(id)
