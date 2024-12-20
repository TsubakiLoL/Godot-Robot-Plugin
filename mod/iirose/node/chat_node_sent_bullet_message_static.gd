extends ChatNode
var mes:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=3
	variable_name_array=["mes"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_type_more=[]
	variable_name_view=["信息"]
	input_port_array=["Bool"]
	output_port_array=[]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is bool and input_port_data[0]:
		ModLoader.get_autoload("iirose").sent_bullet_message(mes)
		return true
	else:
		return false

func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("mes"):
		var new_mes=data["mes"]
		mes=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["mes"]=mes
