extends ChatNode
var mes:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=8
	variable_name_array=["mes"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_type_more=[]
	variable_name_view=["判定字符串"]
	input_port_array=["String"]
	output_port_array=["Bool"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is String:
		sent_data_to_out(input_port_data[0]==mes,0,id)
		return true
	else:
		return false
	pass


func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("mes"):
		var new_mes=data["mes"]
		mes=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["mes"]=mes
