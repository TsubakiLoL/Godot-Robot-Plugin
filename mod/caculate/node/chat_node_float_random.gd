extends ChatNode
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=30
	input_port_array=["Dictionary"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	sent_data_to_out(randf(),0,id)
	return true
