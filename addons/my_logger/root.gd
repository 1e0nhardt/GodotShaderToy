@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Logger"

func _enter_tree():
    add_autoload_singleton(AUTOLOAD_NAME , "res://addons/my_logger/logger.gd")


func _exit_tree():
    remove_autoload_singleton(AUTOLOAD_NAME)
