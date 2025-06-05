class_name GameAudioPlayer
extends AudioStreamPlayer3D

func play_audio(new_stream: AudioStream, new_volume_db: float = 0.0, new_seek: float = 0.0) -> void:
	if has_stream_playback():
		stop()
	stream = new_stream
	volume_db = new_volume_db
	play()
	if new_seek > 0.0:
		seek(new_seek)

func stop_audio() -> void:
	if has_stream_playback():
		stop()
		stream = null
		volume_db = 0.0
		seek(0.0)
	else:
		print("No audio is currently playing.")

