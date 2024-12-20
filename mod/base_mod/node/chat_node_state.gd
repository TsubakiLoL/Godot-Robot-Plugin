extends ChatNode



var is_init:bool=false:
	set(val):
		if not is_init and val:
			#print("设置状态：",val)
			root.set_init_state(self)
			is_init=val
		if is_init and not val:
			#print("设置状态：",val)
			is_init=val
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=0
	variable_name_array=["is_init"]
	variable_type_array=[ChatNode.variable_type.TYPE_BOOL]
	variable_type_more=[]
	variable_name_view=["进入状态"]
	input_port_array=["ChangeState"]
	output_port_array=["StateWithTriger"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is bool and input_port_data[0]:
		if root!=null:
			root.change_state(id,self)
	return false
	

##收到消息
func prompt_message(id:String,triger_type:String,mes:Dictionary):
	sent_data_to_out([triger_type,mes],0,id)
	VLR(id)

	

#func bullet_message(mes:Dictionary):
	#if mes.has("uid"):
		#sent_data_to_out([triger_type.TYPE_BULLET,mes],0,mes["uid"])
		#VLR(mes["uid"])
#func room_message(mes:Dictionary):
	#print("状态收到房间消息",mes)
	#if mes.has("uid"):
		##print("存在uid")
		#sent_data_to_out([triger_type.TYPE_ROOM,mes],0,mes["uid"])
		#VLR(mes["uid"])
#func side_message(mes:Dictionary):
	#if mes.has("uid"):
		#sent_data_to_out([triger_type.TYPE_SIDE,mes],0,mes["uid"])
		#VLR(mes["uid"])
#
#func enter_state(id:String):
	#sent_data_to_out([triger_type.TYPE_ENTER,{}],0,id)
#
#
#func exit_state(id:String):
	#sent_data_to_out([triger_type.TYPE_EXIT,{}],0,id)

##循环代替递归调用
func VLR(id:String):
	var stack:Array[ChatNode]=[]
	var stack_index:Array[int]
	var stack_data:Array=[]
	
	stack.append(self)
	stack_index.append(0)
	stack_data.append(output_port_data)
	while stack.size()!=0:
		print("VLR循环")
		while stack_index[stack_index.size()-1]<stack[stack.size()-1].next_node_array.size():
			print("内层循环")
			var now_next=stack[stack.size()-1].next_node_array[stack_index[stack_index.size()-1]]
			var now_node:ChatNode=now_next[0]
			var parent_node:ChatNode=stack.back()
			var parent_index:int=stack_index.back()
			var parent_data=stack_data.back()
			now_node.act(parent_data[parent_node.next_node_array[parent_index][1]],parent_node.next_node_array[parent_index][2],id)
			stack_index[stack_index.size()-1]+=1
			if now_node.next_node_array.size()!=0 and now_node.is_out_ready:
				stack.append(now_next[0])
				stack_index.append(0)
				stack_data.append(now_node.output_port_data)
			now_node.is_out_ready=false
		stack.pop_back()
		stack_index.pop_back()
		stack_data.pop_back()
