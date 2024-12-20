extends ChatNode
##状态转换器节点，输入为Bool类型，输出为ChangeState类型，当Bool为真时，通知下方state执行转换
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=7
	input_port_array=["Bool"]
	output_port_array=["ChangeState"]
	init_input()
func process_input(id:String)->bool:
	if input_port_data[0] is bool:
		sent_data_to_out(input_port_data[0],0,id)
		return true
	else:
		return false
	pass
