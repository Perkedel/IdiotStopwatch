extends Node

const version:String = '2024.01'

@onready var timerDisplaySec:Label = $Control/VBoxContainer/TimeringOver/Timering/TimerDisplaySec
@onready var timerDisplayFormat:Label = $Control/VBoxContainer/TimeringOver/Timering/TimerDisplayFormat
@onready var logDisplay:RichTextLabel = $Control/VBoxContainer/Logs
@onready var counterDisplay:Label = $Control/VBoxContainer/HBoxContainer/CounterOverscroll/HBoxContainer/Counter
@onready var resetButton:Button = $Control/VBoxContainer/Buttons/Reseter
@onready var lapButton:Button = $Control/VBoxContainer/Buttons/Lapper
@onready var startButton:Button = $Control/VBoxContainer/Buttons/StartStop
@onready var beepSpeaker:AudioStreamPlayer = $Beeper
@onready var backPanel:Panel = $Control/Bgron
@onready var settingWindow:Window = $Control/SettingWindow
@onready var confirmWindow:ConfirmationDialog = $Control/AreYouSure
@onready var settingContent:IdiotStopWatchSetting = $Control/SettingWindow/IdiotStopwatchSetting
@onready var appIcon:TextureRect = $Control/VBoxContainer/TimeringOver/Timering/AppIcon
@onready var muteIcon:TextureRect = $Control/VBoxContainer/TimeringOver/Timering/MuteIcon
@onready var isOnTopIcon:TextureRect = $Control/VBoxContainer/TimeringOver/Timering/IsOnTopIcon
@onready var copyExtrasButton:MenuButton = $Control/VBoxContainer/HBoxContainer/CopyExtras
@onready var beepSound:AudioStream = preload("res://GameDVDCardtridge/IdiotStopwatch/do-amarac.ogg")

@export var timerBeepsAtSecond:float = 9.0
@export var muteSound:bool = false
@export var savePath:String = "user://Simpan/IdiotStopwatch/IdiotStopwatch.json"
@export var saveDir:String = "user://Simpan/IdiotStopwatch/"

var started:bool = false # is stopwatch running
var countingNumber:int = 0 # number of reset while the stopwatch running
var timering:float = 0.0 # main timer
var hadBeeped:bool = false # beep once flag
var saveData:Dictionary = {
	currentTimer = 0,
	logs = [0,0,0],
	counter = 0,
	beepInSec = 9.0,
	alwaysOnTop = true,
	mute= false,
}
var dialogDoThe:String = ''

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
	# https://forum.godotengine.org/t/how-is-menubutton-node-supposed-to-work/1559/4?u=joelwindows7
	copyExtrasButton.get_popup().id_pressed.connect(_on_CopyExtras_Selected)
	appIcon.tooltip_text = "Idiot Stopwatch v"+version
	loaden()
	resetButton.grab_focus()
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

func getIsOnTop()->bool:
	var isOnTop = false
	var parent = get_parent()
	isOnTop = ProjectSettings.get_setting("display/window/size/always_on_top",true)
	if parent is Window:
		isOnTop = parent.always_on_top
		pass
	return isOnTop

#func setIsOnTop(to:bool):
	#var parent = get_parent()
	#if parent is Window:
		#parent.always_on_top = to
	#pass

func checkDir():
	if DirAccess.dir_exists_absolute(saveDir):
		pass
	else:
		DirAccess.make_dir_recursive_absolute(saveDir)
	pass

func save():
	refreshStatusDisplay()
	checkDir()
	
	var parent = get_parent()
	var isOnTop:bool = getIsOnTop()
	
	
	saveData = {
		currentTimer = timering,
		logs = timerLogs,
		counter = countingNumber,
		beepInSec = timerBeepsAtSecond,
		alwaysOnTop = isOnTop,
		mute = muteSound,
	}
	var saveJSON:String = JSON.stringify(saveData,"\t")
	var file = FileAccess.open(savePath, FileAccess.WRITE)
#	printerr(FileAccess.get_open_error())
	file.store_string(saveJSON)
	file.close()
	pass

func loaden():
	checkDir()
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		print('Settings are:\n'+content)
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
		if saveData.has('beepInSec'):
			timerBeepsAtSecond = saveData['beepInSec']
			pass
		if saveData.has('alwaysOnTop'):
			var parent = get_parent()
			if parent is Window:
				parent.always_on_top = saveData['alwaysOnTop']
				isOnTopIcon.visible = parent.always_on_top
			#setOnTop(saveData['alwaysOnTop'])
			pass
		if saveData.has('mute'):
			muteSound = saveData['mute']
	getIsOnTop()
	refreshLogDisplay()
	refreshStatusDisplay()
		
	pass

func beep():
	if not muteSound:
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

func getDocument()->String:
	var toBeCopied:String = ''
	toBeCopied += '# Idiot Stopwatch v'+version+"\n\n"
	toBeCopied += 'Counter = **'+String.num_int64(countingNumber)+"** \n"
	toBeCopied += 'Last Timer = '+String.num(timering)+' ('+toTimeFormat(timering)+')\n\n'
	toBeCopied += '(c) Perkedel Technologies  \nhttps://github.com/Perkedel/IdiotStopwatch\n\n'
	toBeCopied += '## Logs\n\n'
	toBeCopied += '| Seconds | HH:MM::SS.MMM |\n'
	toBeCopied += '| --- | --- |\n'
	var logsing:String = ''
	for i in range(0,timerLogs.size()):
		logsing += '| '+String.num(timerLogs[i])+' | '+toTimeFormat(timerLogs[i])+' |\n'
		pass
	toBeCopied += logsing
	return toBeCopied

func copyEverything():
	DisplayServer.clipboard_set(getDocument())
	pass

func copyExtrasMenu(which:int)->String:
	var toBeCopied:String = ''
	match(which):
		0:
			# copy counter
			toBeCopied = String.num_int64(countingNumber)
			pass
		1:
			# copy logs plain
			for i in range(0,timerLogs.size()):
				toBeCopied += String.num(timerLogs[i]) + "\t\t\t" + toTimeFormat(timerLogs[i]) + "\n"
				pass
			pass
		2:
			# copy logs markdown table
			toBeCopied += '| Seconds | HH:MM::SS.MMM |\n'
			toBeCopied += '| --- | --- |\n'
			var logsing:String = ''
			for i in range(0,timerLogs.size()):
				logsing += '| '+String.num(timerLogs[i])+' | '+toTimeFormat(timerLogs[i])+' |\n'
				pass
			toBeCopied += logsing
			pass
		3:
			# copy logs markdown list
			var logsing:String = ''
			for i in range(0,timerLogs.size()):
				logsing += '- '+String.num(timerLogs[i])+'\t\t\t'+toTimeFormat(timerLogs[i])+'\n'
				pass
			toBeCopied += logsing
			pass
		4:
			# copy Last Timer
			toBeCopied += String.num(timering)
			pass
		5:
			# copy last timer format
			toBeCopied += toTimeFormat(timering)
			pass
		6:
			# copy last timer full
			toBeCopied += String.num(timering) + "\n\n\n" + toTimeFormat(timering)
			pass
		_:
			pass
	DisplayServer.clipboard_set(toBeCopied)
	return toBeCopied

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

func refreshStatusDisplay():
	muteIcon.visible = muteSound
	pass

func confirmReset(the:String):
	setTimer(false)
	dialogDoThe = the
	closeSettingWindow()
	confirmWindow.dialog_text = 'Are you sure to reset ' + the + '?'
	confirmWindow.popup_centered()
	pass

func respondReset(whichIs:StringName):
	setTimer(false)
	match(whichIs):
		'cancel':
			pass
		'yes':
			resetDo(dialogDoThe)
			pass
		_:
			pass
	dialogDoThe = ''
	confirmWindow.hide()

func resetDo(the:String):
	match(the):
		'counter':
			countingNumber = 0
			pass
		'logs':
			timerLogs = [0,0,0]
			refreshLogDisplay()
			pass
		_:
			pass
	save()
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
	print('Setting')
	setTimer(false)
	settingContent.setBufferCounter(countingNumber)
	settingContent.setBufferBeepInSec(timerBeepsAtSecond)
	settingContent.setBufferOnTop(getIsOnTop())
	settingContent.setBufferMute(muteSound)
	settingContent.setBufferVersion(version)
	settingWindow.always_on_top = getIsOnTop()
	settingWindow.reset_size()
	settingWindow.popup_centered()
	pass

func closeSettingWindow():
	settingWindow.hide()
	setOnTop(getIsOnTop())
	setTimer(false)
	save()
	pass

func _timerCondition():
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

func setTimer(to:bool):
	started = to
	_timerCondition()

func toggleTimer():
	started = not started
	_timerCondition()
	pass

func addCounter():
	countingNumber+=1
	save()
	pass

func decreaseCounter():
	countingNumber-=1
	save()
	pass

func setCounter(to:int):
	countingNumber = to
	save()
	pass

func setBeepInSec(to:float):
	timerBeepsAtSecond = to
	save()
	pass

func setOnTop(to:bool):
	print('set on top to ')
	var parent = get_parent()
	if parent is Window:
		parent.always_on_top = to
		isOnTopIcon.visible = parent.always_on_top
		pass
	else:
		pass
	save()
	pass

func setMuteBeep(to:bool):
	muteSound = to
	save()
	pass

func _on_CopyExtras_Selected(id:int):
	copyExtrasMenu(id)
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


func _on_idiot_stopwatch_setting_change_counter(to:int):
	setCounter(to)
	pass # Replace with function body.


func _on_setting_window_close_requested():
	closeSettingWindow()
	pass # Replace with function body.


func _on_idiot_stopwatch_setting_offer_reset(the:String):
	confirmReset(the)
	pass # Replace with function body.


func _on_are_you_sure_canceled():
	respondReset('cancel')
	pass # Replace with function body.


func _on_are_you_sure_confirmed():
	respondReset('yes')
	pass # Replace with function body.


func _on_are_you_sure_custom_action(action):
	respondReset(action)
	pass # Replace with function body.


func _on_copy_now_pressed():
	copyEverything()
	pass # Replace with function body.


func _on_idiot_stopwatch_setting_change_beep_in_sec(to:float):
	setBeepInSec(to)
	pass # Replace with function body.


func _on_idiot_stopwatch_setting_change_on_top(to):
	#print('wahuuuu')
	setOnTop(to)
	pass # Replace with function body.


func _on_idiot_stopwatch_setting_change_mute(to):
	setMuteBeep(to)
	pass # Replace with function body.
