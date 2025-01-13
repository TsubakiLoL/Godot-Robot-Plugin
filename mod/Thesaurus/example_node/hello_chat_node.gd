extends ChatNode

var test_var:String="default"

#节点初始化
func _init(root:NodeRoot) -> void:
	#父类初始化
	super._init(root)
	#输入节点类型数组
	input_port_array=["Bool"]
	#输出节点类型数组
	output_port_array=["Bool","String","String"]
	#需要使用节点UI控制的变量队列
	variable_name_array=["test_var"]
	#节点变量控制使用的控件
	#TYPE_BOOL为开关
	#TYPE_STRING为多行输入文本框
	#TYPE_SELECT为多选一，通过variable_type_more来补充待选项，类型为字符串
	#如variable_type_more=[[["name","uid","message"],["发信人名字","发信人UID","发信人信息内容"]]]
	#就确定了三个待选项，真实值name对外表现为"发信人名字"，选中发信人名字则将变量的值设置为字符串name，外层的数组对应上面变量队列的顺序，不需要则置空
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	#补充
	variable_type_more=[]
	#对外提示文本队列
	variable_name_view=["测试文本"]
	init_input()


#当全部输入就绪时调用
#处理输入，输入的为状态机的标识ID，大部分情况为用户ID
func process_input(id:String):
	#第0个端口的输入数据，获取方式以此类推
	input_port_data[0]
	if input_port_data[0] is bool and input_port_data[0]:
		#将true发送到第0个输出端口，并传入ID
		sent_data_to_out(true,0,id)
		#将"hello starbot"发送到第1个输出端口
		sent_data_to_out("hello starbot!",1,id)
		#将自己的UI输入发送到第2个端口
		sent_data_to_out(test_var,2,id)

#从硬盘中加载数据
func load_from_data(data:Dictionary):
	#父类
	super.load_from_data(data)
	#如果字典中存在这个数据，就进行载入
	if data.has("test_var"):
		var _test_var=data["test_var"]
		test_var=_test_var
#将输入保存到硬盘
func export_data(data:Dictionary):
	#父类
	super.export_data(data)
	#保存
	data["test_var"]=test_var
	

