extends Node

@onready var timerDisplaySec:Label = $Control/VBoxContainer/Timering/TimerDisplaySec
@onready var timerDisplayFormat:Label = $Control/VBoxContainer/Timering/TimerDisplayFormat
@onready var resetButton:Button = $Control/VBoxContainer/Buttons/Reseter
@onready var lapButton:Button = $Control/VBoxContainer/Buttons/Lapper
@onready var startButton:Button = $Control/VBoxContainer/Buttons/StartStop
@onready var beepSpeaker:AudioStreamPlayer = $Beeper
@onready var beepSound:AudioStream = preload("res://GameDVDCardtridge/IdiotStopwatch/do-amarac.ogg")

@export var timerBeepsAtSecond:float = 9.0

var started:bool = false
var countingNumber:int = 0
var timering:float = 0.0
var hadBeeped:bool = false

var startedButtonColor:Color = Color.PINK
var stoppedButtonColor:Color = Color.DIM_GRAY
var resetReadyButtonColor:Color = Color.GREEN

var defaultButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGray.tres")
var startedButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDPink.tres")
var stoppedButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGray.tres")
var resetReadyButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGreen.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	resetButton.add_theme_stylebox_override("normal",defaultButtonStyle)
	pass # Replace with function body.

func toTimeFormat(numbering:float)->String:
	"""
	https://forum.godotengine.org/t/formatting-a-timer/6482
	https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174/2
	https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174
	https://forum.godotengine.org/t/formatting-a-timer/6482/3
	https://stackoverflow.com/a/1459683/9079640 Java exclusive advantage
	https://currentmillis.com/
	"""
#	return ""+String.num(floorf(numbering)/3600,0).pad_zeros(2)+":"+String.num(fmod((floorf(numbering)/60),60),0).pad_zeros(2)+":"+String.num(fmod(floorf(numbering),60),0).pad_zeros(2)+"."
	var seconds = fmod(numbering,60)
	var milisec = fmod(seconds*1000,1000)
	var minutes = fmod((numbering/60),60)
	var hours = (numbering/60)/60
	
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d.%03d" % [hours, minutes, seconds, milisec]
	pass

func save():
	pass

func beep():
	beepSpeaker.stream = beepSound
	beepSpeaker.play()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timerDisplaySec.text = String.num(timering)
	timerDisplayFormat.text = toTimeFormat(timering)
	
	if started:
		timering += delta
		
		
		pass
	else:
		
		pass
	
	if timering >= timerBeepsAtSecond:
		if not hadBeeped:
			beep()
			resetButton.add_theme_stylebox_override("normal",resetReadyButtonStyle)
			resetButton.add_theme_stylebox_override("hover",resetReadyButtonStyle)
			hadBeeped = true
			pass
		pass
	else:
		if hadBeeped:
			resetButton.remove_theme_stylebox_override("normal")
			resetButton.remove_theme_stylebox_override("hover")
			hadBeeped = false
			pass
		pass
	pass

func toggleTimer():
	started = not started
	if started:
		startButton.add_theme_stylebox_override("normal",startedButtonStyle)
		startButton.add_theme_stylebox_override("hover",startedButtonStyle)
		pass
	else:
		startButton.remove_theme_stylebox_override("normal")
		startButton.remove_theme_stylebox_override("hover")
		pass
	pass


func _on_reseter_pressed():
	pass # Replace with function body.


func _on_lapper_pressed():
	pass # Replace with function body.


func _on_start_stop_pressed():
	toggleTimer()
	pass # Replace with function body.
