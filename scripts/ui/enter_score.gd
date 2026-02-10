extends LineEdit
class_name EnterScoreInput

@export var allowed_characters: String = "[A-Z]+"

var _reg_ex: RegEx = RegEx.new()

func _ready():
	_reg_ex.compile(allowed_characters)
	self.grab_focus()

func _on_text_changed(new_text: String):
	new_text = new_text.to_upper()
	
	# Remember the position of the caret.
	var caret_position: int = caret_column
	
	# Filter the new text according to the regular expession.
	var filtered: String = ""
	for result: RegExMatch in _reg_ex.search_all(new_text):
		filtered += result.strings[0]
	
	# If anything was filtered, restore the caret position accordingly.
	if filtered != new_text:
		text = filtered
		caret_column = caret_position - (new_text.length() - filtered.length())

func _on_text_change_rejected(rejected_substring: String):
	rejected_substring = rejected_substring.to_upper()
	
	var result: RegExMatch = _reg_ex.search(rejected_substring)
	if result:
		text = text.substr(1) + rejected_substring

func _on_visibility_changed():
	self.grab_focus()
