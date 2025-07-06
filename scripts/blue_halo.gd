extends AnimatedSprite2D

# Add these to your character script
var time: float = 0.0
var wiggle_offset: Vector2 = Vector2.ZERO
var base_position: Vector2  # Store the character's intended position
var phase_offset: float

@onready var area: Area2D = self.get_parent()

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	base_position = global_position
	phase_offset = randf() * TAU

func _on_area_entered():
	#self.scale = Vector2(4,4)
	print('working')

func _process(delta):
	time += delta * 3
		
	# Layered sine waves for natural wiggle
	var wiggle_x = sin(time * 2.3 + phase_offset) * 0.8 + sin(time * 4.7) * 0.3
	var wiggle_y = cos(time * 1.9 + phase_offset) * 0.6 + cos(time * 5.1) * 0.4
	
	# Vary intensity over time (oscillating intensity)
	var intensity = 5.25 + sin(time * 0.7) * 0.3  # 0.2 to 0.8 range
	
	wiggle_offset = Vector2(wiggle_x, wiggle_y) * intensity
	global_position = base_position + wiggle_offset
