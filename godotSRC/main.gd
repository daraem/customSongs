extends Node


const RETRY_INTERVAL = 0.5

var boombox = null
var audio_player: AudioStreamPlayer3D  

var panel_scene
var panel_instance
var visiblePanel = false

var directory_path := ""
var song_list: Array = []

func _ready():

	directory_path = OS.get_executable_path().get_base_dir() + "/songs"
	check_world_scene()
	load_songs()

func load_songs():
	var dir := Directory.new()
	if dir.open(directory_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():  
				song_list.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()


func check_world_scene():

	boombox = get_node_or_null("/root/world/Viewport/main/entities/boombox")
	
	if boombox:
		print("OLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
		audio_player = boombox.get_node("./AudioStreamPlayer3D") 
		print(audio_player)

		var interactable = boombox.get_node("./Interactable")
		interactable.connect("_activated", self, "_on_Interactable__activated")
		
		yield(get_tree().create_timer(RETRY_INTERVAL), "timeout")
		check_world_scene()
	else:

		yield(get_tree().create_timer(RETRY_INTERVAL), "timeout")
		check_world_scene()

func display_songs():
	if panel_instance:
		var song_container = panel_instance.get_node("Panel2/ScrollContainer/VBoxContainer")
		for child in song_container.get_children():
			song_container.remove_child(child)
			child.queue_free()
		
		for song in song_list:
			var button = Button.new()

			button.text = song
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.connect("pressed", self, "_on_button_pressed", [song])
			song_container.add_child(button)

func _on_button_pressed(song_name):

	var file_path = directory_path + "/" + song_name

	var ogg = AudioStreamOGGVorbis.new()
	var file = File.new()
	file.open(file_path, File.READ)
	ogg.data = file.get_buffer(file.get_len())
	file.close()
	audio_player.stream = ogg
	audio_player.play()
	audio_player.playing = true


func _on_Interactable__activated():
	if not panel_scene:
		panel_scene = load("res://mods/csong/menutest.tscn")
	
	if panel_scene:
		if not visiblePanel:
			panel_instance = panel_scene.instance()
			get_node("/root").add_child(panel_instance)
			display_songs()
			visiblePanel = true
		else:
			panel_instance.queue_free()
			panel_instance = null
			visiblePanel = false

