extends ChatNode

static func get_triger_type_name(type:String)->String:
	
	if triger_type_name.has(type):
		return str(triger_type_name[type])
	else:
		return "未命名触发器类型"+str(type)
	pass
var triget_t:String
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=1
	variable_name_array=["triget_t"]
	variable_type_array=[ChatNode.variable_type.TYPE_SELECT]
	var triger_type_arr=[]
	var triger_type_name_arr=[]
	var all_triger=ModLoader.get_all_triger()
	triget_t=all_triger[0]
	for i in all_triger:
		triger_type_name_arr.append(ModLoader.get_triger_name(i))
	variable_type_more=[[all_triger,triger_type_name_arr]]
	variable_name_view=["模式"]
	input_port_array=["StateWithTriger"]
	output_port_array=["Dictionary"]
	init_input()

func process_input(id:String)->bool:
	var data=input_port_data[0]
	if data is Array and data.size()==2:
		var t=data[0]
		if t==triget_t and data[1] is Dictionary:
			sent_data_to_out(data[1],0,id)
			return true
	return false
	pass

func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("triger_t"):
		var new_triger_t=data["triger_t"]
		#print(new_triger_t)
		var all_triger=ModLoader.get_all_triger()
		if new_triger_t in all_triger:
			triget_t=new_triger_t
func export_data(data:Dictionary):
	super.export_data(data)
	data["triger_t"]=triget_t
