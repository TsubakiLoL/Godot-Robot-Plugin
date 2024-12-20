extends ChatNode

func _init(root:NodeRoot) -> void:
	super._init(root)
	type=22
	input_port_array=["Float"]
	output_port_array=["String"]
	init_input()

func process_input(id:String)->bool:
	sent_data_to_out(str(input_port_data[0]),0,id)
	return true
	pass
