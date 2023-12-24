extends Node


func clear_group(group_name: String):
	for object in get_tree().get_nodes_in_group(group_name):
		if is_instance_valid(object):
			object.call_deferred("queue_free")


func clear_parent(parent:Node):
	for object in parent.get_children():
		if is_instance_valid(object):
			object.call_deferred("queue_free")
