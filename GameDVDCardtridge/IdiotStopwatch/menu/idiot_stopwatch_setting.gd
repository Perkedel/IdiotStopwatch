extends Control

class_name IdiotStopWatchSetting

var activo:bool = false
var _bufferCounter:int = 0
var _bufferBeepInSec:float = 9
var _bufferOnTop:bool = true
var _bufferMute:bool = false
var _bufferVersion:String = '???'

@onready var counterSpin:SpinBox = $ScrollContainer/VBoxContainer/SetBar/CounterSpinBox
@onready var counterSpinBeepInSec:SpinBox = $ScrollContainer/VBoxContainer/SetBarBeepInSec/CounterSpinBox
@onready var toggleAlwaysOnTop:CheckButton = $ScrollContainer/VBoxContainer/AlwaysOnTop
@onready var toggleMute:CheckButton = $ScrollContainer/VBoxContainer/MuteBeep
@onready var aboutText:RichTextLabel = $ScrollContainer/VBoxContainer/AboutText
@onready var backButton:Button = $ScrollContainer/VBoxContainer/Titler/BackButton

@export var handoverSystemItself:NodePath

signal changeCounter(to:int)
signal changeBeepInSec(to:float)
signal changeOnTop(to:bool)
signal changeMute(to:bool)
signal offerReset(the:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setBufferCounter(to:int):
	_bufferCounter = to
	pass

func setBufferBeepInSec(to:float):
	_bufferBeepInSec = to
	pass

func setBufferOnTop(to:bool):
	_bufferOnTop = to
	pass

func setBufferMute(to:bool):
	_bufferMute = to
	pass

func setBufferVersion(to:String):
	_bufferVersion = to
	pass

func refreshAbout():
	# https://docs.godotengine.org/en/4.1/tutorials/ui/bbcode_in_richtextlabel.html
	var content:String = ''
	content += '[img=100]res://GameDVDCardtridge/IdiotStopwatch/sprites/IdiotStopwatch.png[/img] Idiot Stopwatch [b]v'+_bufferVersion+'[/b]\n\n'
	content += 'by [url=https://perkedel.netlify.app/@JOELwindows7]JOELwindows7[/url]\n'
	content += '[url=https://perkedel.netlify.app][img=32]res://GameDVDCardtridge/IdiotStopwatch/sprites/Perkedel Icon.png[/img] Perkedel Technologies[/url]\n'
	content += 'Codes = [url=https://www.gnu.org/licenses/gpl-3.0.html]GNU GPL v3[/url]\n'
	content += 'Assets = [url=https://creativecommons.org/licenses/by-sa/4.0/]CC4.0-BY-SA[/url]\n\n'
	content += 'Source code: [url]https://github.com/Perkedel/IdiotStopwatch[/url]\n'
	content += 'Sounds generated with [url=https://sfbgames.itch.io/chiptone]Chiptone from SFBGames[/url]\n'
	content += '\n'
	content += 'Made with [img=20]res://icon.svg[/img] Godot Engine [url=https://godotengine.org/license](MIT License)[/url].'
	aboutText.text = content
	pass

func goBack():
	var parent = get_parent()
	if parent is Window:
		parent.emit_signal('close_requested')
	#elif parent is Control:
		#var grandparent = parent.get_parent()
		#if grandparent.has_method('closeSettingWindow'):
			#grandparent.call('closeSettingWindow')
		#pass
	else:
		if handoverSystemItself:
			print('Tryain get backing')
			var itself = get_node(handoverSystemItself)
			if itself.has_method('closeSettingWindow'):
				itself.call('closeSettingWindow')
			pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		activo = false
		if visible:
			counterSpin.value = _bufferCounter
			counterSpinBeepInSec.value = _bufferBeepInSec
			toggleAlwaysOnTop.button_pressed = _bufferOnTop
			toggleMute.button_pressed = _bufferMute
			
			# self itself also must be always on top per setting
			#var parent = get_parent()
			#if parent is Window:
				#parent.always_on_top = _bufferOnTop
			
			refreshAbout()
			backButton.grab_focus()
			activo = true
			pass
		else:
			activo = false
			pass

func _on_spin_box_value_changed(value):
	if activo:
		emit_signal("changeCounter",value)
		pass
	pass # Replace with function body.


func _on_clear_counter_pressed():
	emit_signal("offerReset",'counter')
	pass # Replace with function body.


func _on_clear_log_pressed():
	emit_signal('offerReset','logs')
	pass # Replace with function body.


func _on_counter_spin_box_value_changed(value):
	if activo:
		emit_signal("changeBeepInSec",value)
		pass
	pass # Replace with function body.


func _on_about_text_meta_clicked(meta):
	OS.shell_open(meta)
	pass # Replace with function body.


func _on_back_button_pressed():
	goBack()
	pass # Replace with function body.


func _on_always_on_top_toggled(toggled_on):
	if activo:
		var parent = get_parent()
		if parent is Window:
			parent.always_on_top = toggled_on
		emit_signal("changeOnTop",toggled_on)
		pass
	pass # Replace with function body.


func _on_mute_beep_toggled(toggled_on):
	if activo:
		emit_signal("changeMute",toggled_on)
		pass
	pass # Replace with function body.
