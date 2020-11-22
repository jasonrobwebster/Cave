extends State

const IMAGE_VBUFFER := 5

var velocity: Vector2 = Vector2.ZERO

var _rng = RandomNumberGenerator.new()

onready var pivot: Position2D = owner.get_node("BodyPivot")
onready var sprite: Sprite = owner.get_node("BodyPivot/Sprite")
onready var anim_player: AnimationPlayer = owner.get_node("AnimationPlayer")
onready var start_pos: Vector2 = owner.global_position
onready var player_detection: Area2D = owner.get_node("PlayerDetection")
onready var player_chase: Area2D = owner.get_node("PlayerChase")
onready var line_of_sight: RayCast2D = owner.get_node("LineOfSight")


func _ready():
	_rng.randomize()
	player_detection.connect("body_entered", self, "_on_PlayerDetection_body_entered")
	player_detection.connect("body_exited", self, "_on_PlayerDetection_body_exited")
	player_chase.connect("body_entered", self, "_on_PlayerChase_body_entered")
	player_chase.connect("body_exited", self, "_on_PlayerChase_body_exited")


func update(delta):
	_move()
	_update_image()


func _move():
	velocity = owner.move_and_slide(
		velocity
	)


func _update_image():
	if velocity.x <= -IMAGE_VBUFFER:
		pivot.scale.x = -1
	elif velocity.x >= IMAGE_VBUFFER:
		pivot.scale.x = 1


func _on_PlayerDetection_body_entered(body: Node):
	pass


func _on_PlayerDetection_body_exited(body: Node):
	pass


func _on_PlayerChase_body_entered(body: Node):
	pass


func _on_PlayerChase_body_exited(body: Node):
	pass
