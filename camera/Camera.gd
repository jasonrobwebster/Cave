extends Camera2D

export(NodePath) var player_path setget set_player

var _player: KinematicBody2D


func _ready():
	_player = get_node(player_path)


func set_player(player: NodePath):
	player_path = player
	_player = get_node(player_path)


func follow_player():
	_player.get_node("RemoteTransform2D").remote_path = self.get_path()
