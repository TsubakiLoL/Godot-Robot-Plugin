extends ChatNode
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=9
	input_port_array=["Bool","String"]
	output_port_array=[]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is bool and input_port_data[1] is String and input_port_data[0]:
		ModLoader.get_autoload("iirose").sent_room_message(input_port_data[1])
		return true
	else:
		return false
