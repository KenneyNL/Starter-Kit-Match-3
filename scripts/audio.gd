extends Node

# Code adapted from KidsCanCode

var num_players = 12
var bus = "master"

var available = []
var queue = []

var active_sounds = {}

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(player):
	for path in active_sounds.keys():
		if active_sounds[path].has(player):
			active_sounds[path].erase(player)
			if active_sounds[path].is_empty():
				active_sounds.erase(path)
			break
	available.append(player)

func play(sound_path: String, allow_overlap: bool = false, pitch: float = 1.0, volume: float = 1.0):
	if allow_overlap:
		queue.append({"path": sound_path, "overlap": true, "pitch": pitch, "volume": volume})
	else:
		if not active_sounds.has(sound_path) and not _is_in_queue(sound_path):
			queue.append({"path": sound_path, "overlap": false, "pitch": pitch, "volume": volume})

func _is_in_queue(sound_path: String) -> bool:
	for item in queue:
		if item["path"] == sound_path:
			return true
	return false

func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		var data = queue.pop_front()
		var sound_path = data["path"]
		var player = available[0]
		available.pop_front()
		
		if not data["overlap"]:
			if not active_sounds.has(sound_path):
				active_sounds[sound_path] = []
			active_sounds[sound_path].append(player)
		
		player.stream = load(sound_path)
		player.pitch_scale = data["pitch"]
		
		player.volume_db = linear_to_db(data["volume"])
		
		player.play()

# Utility for decibels

func linear_to_db(linear: float) -> float:
	if linear > 0:
		return 20.0 * log(linear) / log(10.0)
	return -80.0
