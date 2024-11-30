extends AudioStreamPlayer2D

func play_audio():
	stop()
	pitch_scale = randf_range(0.8, 1.2)
	play()
