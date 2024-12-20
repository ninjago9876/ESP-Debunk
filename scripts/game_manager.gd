extends Control

@onready var attemptCounter: Label = $"../AttemptCounter"
@onready var score_counter: Label = $"../ScoreCounter"

@onready var ping_sound_effect: AudioStreamPlayer2D = $"../PingSoundEffect"
@onready var dud_sound_effect: AudioStreamPlayer2D = $"../DudSoundEffect"

@onready var image = $"../Image"

var request_processing = false

var success = null

var score: int = 0
var attempts: int = 0

var rounds = {
	"rounds": [
		
	]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('Hello')
	restart_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (success == true and not request_processing):
		success = false
		print("SUCCESS!")
		flush_local_data()
	
	attemptCounter.text = str(attempts) + " / 24"
	score_counter.text = str(score)

func try_send_data() -> bool:
	if (request_processing):
		return false
	
	var data_json_string = JSON.stringify(rounds, "   ")

	#var url = JavaScriptBridge.eval("return window.origin")
	var request_error = $"../HTTP".request(
		"http://192.168.0.162:8000/api/put_round", ["Content-Type: application/json"],
		HTTPClient.METHOD_PUT,
		data_json_string
	)
	
	if (request_error != OK):
		success = false
		push_error("HTTP Request error: ", request_error)
		return false
	
	request_processing = true
	
	success = true
	
	return true

func sync_data_locally():
	var file = FileAccess.open("user://cached_rounds.json", FileAccess.WRITE_READ)
	if file == null:
		print("Failed to open the file.")
		return
		
	var content = file.get_as_text()
	if (content.is_empty()):
		file.store_string(JSON.stringify(rounds))
		file.close()
		return
	var present_data = JSON.parse_string(content)
	if (present_data == null):
		file.store_string(JSON.stringify(rounds))
		file.close()
		return
	if (len(present_data) < len(rounds)):
		file.store_string(JSON.stringify(rounds))
	else:
		rounds = present_data
	file.close()

func flush_local_data():
	var file = FileAccess.open("user://cached_rounds.json", FileAccess.WRITE)
	if (not file):
		return
	rounds.rounds = []
	file.close()
	
func restart_game():
	attempts = 0
	score = 0

func on_press():
	if attempts >= 24:
		rounds.rounds.append({
			"score": score,
			"timestamp": (int)(Time.get_unix_time_from_system() * 1000)
		})
		sync_data_locally()
		try_send_data()
		restart_game()
		return
	attempts += 1
	if (randi_range(0, 3) == 0):
		ping_sound_effect.play()
		image.show_image()
		score += 1
	else:
		dud_sound_effect.play()


func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	request_processing = false
	if (result != HTTPRequest.RESULT_SUCCESS):
		success = false
		return
	
	success = true
