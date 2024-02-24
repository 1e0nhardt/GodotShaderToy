class_name DialogNode
extends RefCounted

var id: int
var character: String
var character_state: String
var text: String
var next_node: int


func enter(scene: Node):
    setup(scene)


func setup(scene: Node):
    scene.show_character_picture(character, character_state)
    scene.show_dialog_text(text)
