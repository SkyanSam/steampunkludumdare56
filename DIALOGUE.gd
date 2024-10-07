extends Panel  # Since the script is attached to the "dialogue box" Panel node

@onready var game_manager = get_node("/root/Main/GameManager")
@onready var dialogue_text : RichTextLabel = get_node("DialogueText")
@onready var npc_icon : TextureRect = get_node("NPCIcon")  # NEEDS A TEXTURE SAMMMMMMMM
@onready var okay : Button = get_node("Okay")  # Okay button is to move on

# Initialize the dialogue with an NPC
func initialize_with_npc(_npc_texture):  # Accept a texture for the NPC
	dialogue_text.text = ""
	okay.disabled = true
	self.visible = true  # Show the dialogue box
	print("successful npc dialogue")

	# Set NPC icon texture
	if _npc_texture != null:
		npc_icon.texture = _npc_texture  # Assign the NPC texture to the TextureRect

# Function called when the "Okay" button is pressed
func _on_okay_pressed():
	self.visible = false  # Hide the dialogue box when Okay is pressed

# Function to handle NPC dialogue display
func _on_npc_talk(npc_dialogue):
	dialogue_text.text = npc_dialogue
	okay.disabled = false

# Check for the "M" key press to trigger the dialogue
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_M:
		if not self.visible:
			initialize_with_npc(null)  # Trigger the dialogue when the "M" key is pressed
			print("LOLWEBALL")
		else:
			self.visible = false  # Hide the dialogue box if it's already visible
			print("LOLWENOTBALLIN")
