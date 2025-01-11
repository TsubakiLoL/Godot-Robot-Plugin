extends ChatNode
var mes:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	variable_name_array=["mes"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_type_more=[]
	variable_name_view=["输出"]
	input_port_array=["Dictionary"]
	output_port_array=["String"]
	init_input()

func process_input(id:String)->bool:
	sent_data_to_out(mes,0,id)
	return true
	


func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("mes"):
		var new_mes=data["mes"]
		mes=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["mes"]=mes
