extends Sprite2D

@export var images: Array[Texture2D]

@export var fade = 0.5
@export var hold = 5

var target = 0
var timer = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	target = 0
	if (timer > fade):
		target = 1
	if (timer > fade + hold):
		target = 0
	modulate.a += (target - modulate.a) * delta / fade
	
func show_image():
	if (timer > fade * 2 + hold):
		texture = images.pick_random()
		timer = 0
