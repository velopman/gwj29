class_name Slime extends KinematicBody2D

const JUMP_MAX_VELOCITY = 450.0
const JUMP_TIME_MAX = 2.0
const TARGET_DISTANCE_MAX = 250.0
const TARGET_MAX_VELOCITY = 100.0
const DAMAGE_RADIUS = 10.0


var health: int = 3

var damaged_timer: float = 0.0

var target = null

var velocity: Vector2 = Vector2.ZERO

var drag: float = 0.1
var gravity: float = -30

onready var jump_offset = randf() * self.JUMP_TIME_MAX


func _ready() -> void:
	self.add_to_group( "enemies" )
	$sprite.scale.x = 1 if randi() % 2 else -1


func _physics_process(delta: float) -> void:
	if self.damaged_timer:
		self.__handle_damaged()
	else:
		self.__handle_movement()


func __handle_damaged() -> void:
		if !PhysicsTime.on_timestamp( self.damaged_timer ):
			if PhysicsTime.on_interval( 0.1, 0.0 ):
				$sprite.visible = !$sprite.visible

			self.set_text("Gnomore, please!")
		else:
			self.damaged_timer = 0.0
			$sprite.visible = true
			self.set_text("")

			if self.health <= 0:
				self.call_deferred( "queue_free" )


func __handle_movement() -> void:
	# Move towards the player if player has been spotted
	# bounce in place otherwise

	if !self.target:
		if self.is_on_floor() && randi() % 50 == 0:
			self.velocity.y = -self.JUMP_MAX_VELOCITY
		var distance = self.position.distance_to(Globals.player_instance.position)
		if distance < self.TARGET_DISTANCE_MAX:
			self.target = Globals.player_instance
			self.set_text("Hugs please?")
	else:
		if self.is_on_floor() && PhysicsTime.on_interval(self.JUMP_TIME_MAX, self.jump_offset):
			var direction = self.position.direction_to(self.target.position)

			self.velocity.y = -self.JUMP_MAX_VELOCITY
			self.velocity.x = sign(direction.x) * self.TARGET_MAX_VELOCITY


	self.velocity.y -= self.gravity

	if self.velocity.x:
		$sprite.scale.x = sign(self.velocity.x)


	if self.is_on_floor():
		self.velocity = lerp( self.velocity, Vector2.ZERO, self.drag)


	self.move_and_slide(PhysicsTime.scale_vector2(self.velocity), Vector2.UP)


func damage() -> void:
	self.health -= 1
	self.damaged_timer = PhysicsTime.elapsed_time + 0.5
	$sprite.visible = false

	if self.health <= 0:
		self.remove_from_group( "enemies" )


func set_text(text: String) -> void:
	$Label.text = text
	$Label.rect_size.x = 0
	$Label.rect_position.x = -$Label.rect_size.x * 0.5
