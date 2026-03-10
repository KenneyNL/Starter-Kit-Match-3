extends GPUParticles2D

# Functions

func _ready():
	emitting = true
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
