extends Node

@onready var timerDisplaySec:Label = $Control/VBoxContainer/Timering/TimerDisplaySec
@onready var timerDisplayFormat:Label = $Control/VBoxContainer/Timering/TimerDisplayFormat
@onready var logDisplay:RichTextLabel = $Control/VBoxContainer/Logs
@onready var counterDisplay:Label = $Control/VBoxContainer/HBoxContainer/Counter
@onready var resetButton:Button = $Control/VBoxContainer/Buttons/Reseter
@onready var lapButton:Button = $Control/VBoxContainer/Buttons/Lapper
@onready var startButton:Button = $Control/VBoxContainer/Buttons/StartStop
@onready var beepSpeaker:AudioStreamPlayer = $Beeper
@onready var backPanel:Panel = $Control/Bgron
@onready var settingWindow:Window = $Control/SettingWindow
@onready var settingContent:IdiotStopWatchSetting = $Control/SettingWindow/IdiotStopwatchSetting
@onready var beepSound:AudioStream = preload("res://GameDVDCardtridge/IdiotStopwatch/do-amarac.ogg")

@export var timerBeepsAtSecond:float = 9.0
@export var savePath:String = "user://Simpan/IdiotStopwatch/IdiotStopwatch.json"
@export var saveDir:String = "user://Simpan/IdiotStopwatch/"

var started:bool = false
var countingNumber:int = 0
var timering:float = 0.0
var hadBeeped:bool = false
var saveData:Dictionary = {
	currentTimer = 0,
	logs = [0,0,0],
	counter = 0,
}

var timerLogs:PackedFloat64Array = [0,0,0]

var defaultButtonColor:Color = Color.DIM_GRAY
var startedButtonColor:Color = Color.PINK
var stoppedButtonColor:Color = Color.DIM_GRAY
var resetReadyButtonColor:Color = Color.GREEN

var defaultButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGray.tres")
var startedButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDPink.tres")
var startedButtonStyleHover:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDPinkDark.tres")
var stoppedButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGray.tres")
var resetReadyButtonStyle:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGreen.tres")
var resetReadyButtonStyleHover:StyleBox = preload("res://GameDVDCardtridge/IdiotStopwatch/LedColor/ButtonStyleboxLEDGreenDark.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
#	resetButton.add_theme_stylebox_override("normal",defaultButtonStyle)
	loaden()
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
	if DirAccess.dir_exists_absolute(saveDir):
		pass
	else:
		DirAccess.make_dir_recursive_absolute(saveDir)
	
	saveData = {
		currentTimer = timering,
		logs = timerLogs,
		counter = countingNumber,
	}
	var saveJSON:String = JSON.stringify(saveData,"\t")
	var file = FileAccess.open(savePath, FileAccess.WRITE)
#	printerr(FileAccess.get_open_error())
	file.store_string(saveJSON)
	file.close()
	pass

func loaden():
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		saveData = JSON.parse_string(content)
		if saveData.has('currentTimer'):
			timering = saveData['currentTimer']
			pass
		if saveData.has('logs'):
			timerLogs = saveData['logs']
			pass
		if saveData.has('counter'):
			countingNumber = saveData['counter']
			pass
		refreshLogDisplay()
		
	pass

func beep():
	beepSpeaker.stream = beepSound
	beepSpeaker.play()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timerDisplaySec.text = String.num(timering)
	timerDisplayFormat.text = toTimeFormat(timering)
	counterDisplay.text = String.num_int64(countingNumber)
	
	if started:
		timering += delta
		
		
		pass
	else:
		
		pass
	
	if timering >= timerBeepsAtSecond:
		if not hadBeeped:
			beep()
			backPanel.self_modulate = resetReadyButtonColor
			resetButton.add_theme_stylebox_override("normal",resetReadyButtonStyle)
			resetButton.add_theme_stylebox_override("hover",resetReadyButtonStyleHover)
			hadBeeped = true
			pass
		pass
	else:
		if hadBeeped:
			backPanel.self_modulate = Color.WHITE
			resetButton.remove_theme_stylebox_override("normal")
			resetButton.remove_theme_stylebox_override("hover")
			hadBeeped = false
			pass
		pass
	pass

func refreshLogDisplay():
	"""
	https://docs.godotengine.org/en/4.1/tutorials/ui/bbcode_in_richtextlabel.html
	"""
	logDisplay.text = ''
	logDisplay.clear()
#	logDisplay.append_text('[color=green]%0.9d[right]%s[/right][/color]\n' % [timerLogs[0], toTimeFormat(timerLogs[0])])
	logDisplay.append_text('[color=green]{timeSec}\t\t\t\t\t\t{timeFormat}[/color]\n'.format({"timeSec":timerLogs[0],"timeFormat":toTimeFormat(timerLogs[0])}))
	for i in range(1,timerLogs.size()):
#		logDisplay.append_text('%d[right]%s[/right]\n' % [timerLogs[i], toTimeFormat(timerLogs[i])])
		logDisplay.append_text('{timeSec}\t\t\t\t\t\t{timeFormat}\n'.format({"timeSec":timerLogs[i],"timeFormat":toTimeFormat(timerLogs[i])}))
		pass
	pass

func logTimer():
	timerLogs.insert(0,timering)
	refreshLogDisplay()
	save()
	pass

func resetTimer():
	logTimer()
	timering = 0
	if started:
		countingNumber+=1
	save()
	pass

func openSettingWindow():
	print('windowwwww')
	settingContent.setBufferCounter(countingNumber)
	settingWindow.popup_centered()
	pass

func closeSettingWindow():
	settingWindow.hide()
	pass

func toggleTimer():
	started = not started
	if started:
		startButton.add_theme_stylebox_override("normal",startedButtonStyle)
		startButton.add_theme_stylebox_override("hover",startedButtonStyleHover)
		pass
	else:
		startButton.remove_theme_stylebox_override("normal")
		startButton.remove_theme_stylebox_override("hover")
		pass
	save()
	pass

func addCounter():
	countingNumber+=1
	pass

func decreaseCounter():
	countingNumber-=1
	pass

func setCounter(to:int):
	countingNumber = to
	save()
	pass

func _on_reseter_pressed():
	resetTimer()
	pass # Replace with function body.


func _on_lapper_pressed():
	logTimer()
	pass # Replace with function body.


func _on_start_stop_pressed():
	toggleTimer()
	pass # Replace with function body.


func _on_add_pressed():
	addCounter()
	pass # Replace with function body.


func _on_decrease_pressed():
	decreaseCounter()
	pass # Replace with function body.


func _on_settinger_pressed():
	openSettingWindow()
	pass # Replace with function body.


func _on_idiot_stopwatch_setting_change_counter(to):
	setCounter(to)
	pass # Replace with function body.


func _on_setting_window_close_requested():
	closeSettingWindow()
	pass # Replace with function body.
