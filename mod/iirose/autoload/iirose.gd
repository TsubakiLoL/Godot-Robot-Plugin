#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Node
@export var buffer_size:int=1048560*8
var ws =WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var stock_message=[0,0,0]  #总股数，总金，单股价格
#房间信息缓存
var room_message_cache:Array=[]
#房间信息缓存大小
var room_message_cache_size:int=30
#添加缓存
func put_room_cache(room_mes_dic:Dictionary):
	room_message_cache.append(room_mes_dic)
	if room_message_cache.size()>room_message_cache_size:
		room_message_cache.pop_front()

var inpackeg={
	"r":"66234e757a3ce", #房间标识
	"n":"",				#名字
	"p":"",				#密码
	"cp":"",
	"nt":"",
	"st":"n",
	"mo":"",
	"mb":"1",
	"mu":"01",
	"rp":"",
	"vc":"1092",
	"fp":"@"
}
var next_room:String=""
var is_login:bool=false
var is_in_logging:bool=false
var ping_timer: Timer
signal connected_to_server
signal connection_closed(rea:Array)
signal message_received(pac:PackedByteArray)
signal login_success
signal room_message_received(arr:Array)
signal side_message_received(arr:Array)
signal bullet_message_received(arr:Array)
signal stock_update
signal debug_message(tex:String)
#是否需要打印debug信息
var need_debug_message:bool=false
func re_init_export():
	inpackeg["p"]=inpackeg["p"].md5_text()
	inpackeg["fp"]="@"+str(randf()).md5_text()
##设置信息
func set_information(name_:String,p:String,room:String):
	inpackeg["r"]=room
	inpackeg["n"]=name_
	inpackeg["p"]=p
	re_init_export()
func set_buffer_size(innum:int):
	ws.inbound_buffer_size=innum
	ws.outbound_buffer_size=innum
func start_connect():
	ws=null
	is_in_logging=true
	ws=WebSocketPeer.new()
	set_buffer_size(buffer_size)
	last_state = WebSocketPeer.STATE_CLOSED
	is_login=false
	ws.connect_to_url("ws://m1.iirose.com:8777",TLSOptions.client())
	if need_debug_message:
		print("》》》》正在链接到蔷薇世界")
		debug_message.emit("》》》》正在链接到蔷薇世界")
func send_in_pack():
	if need_debug_message:
		print("》》》》正在向蔷薇发送登陆包")
		debug_message.emit("》》》》正在向蔷薇发送登陆包")
	if ws.get_ready_state()==WebSocketPeer.STATE_OPEN:
		var str=("*"+JSON.stringify(inpackeg)).to_utf8_buffer()
		ws.send(str)
		if need_debug_message:
			print_rich("[color=green]》》》》登陆包发送成功[/color]")
			debug_message.emit("[color=green]》》》》登陆包发送成功[/color]")
	else:
		if need_debug_message:
			print_rich("[color=red]》》》》错误：还未与蔷薇建立链接或链接已断开[/color]")
			debug_message.emit("[color=red]》》》》错误：还未与蔷薇建立链接或链接已断开[/color]")
func _ready() -> void:
	set_buffer_size(buffer_size)
	ping_timer=Timer.new()
	add_child(ping_timer)
	ping_timer.one_shot=false
	ping_timer.timeout.connect(ping)
	ping_timer.wait_time=30
	ping_timer.start()
func _process(delta: float) -> void:
	poll()
func get_gzip(pkg:PackedByteArray):
	var gzip=StreamPeerGZIP.new()
	gzip.clear()
	gzip.start_compression(buffer_size)
	gzip.put_partial_data(pkg)
	var new_pck=PackedByteArray()
	gzip.finish()
	while(gzip.get_available_bytes()>0):
		new_pck.append_array(gzip.get_partial_data(gzip.get_available_bytes())[1])
	gzip.clear()
	return new_pck
func get_string_from_packeg(pkg:PackedByteArray):
	var text:String
	if pkg[0]==1:
		#text=get_ungzip(pkg).get_string_from_utf8()
		var new_pkg=pkg
		new_pkg.remove_at(0)
		new_pkg=new_pkg.decompress_dynamic(-1,3)
		text=new_pkg.get_string_from_utf8()
		pass
	else:
		text=pkg.get_string_from_utf8()
	exe_message(text)
	pass

func want_stock():
	if need_debug_message:
		print_rich("[color=yellow]》》》》尝试向蔷薇申请股票信息[/color]")
		debug_message.emit("[color=yellow]》》》》尝试向蔷薇申请股票信息[/color]")
	sent_str(">#")
func _on_ping_timeout() -> void:
	if ws.get_ready_state()==WebSocketPeer.STATE_OPEN:
		ws.send_text("s")
	pass # Replace with function body.


func exe_message(txt:String):
	var dic:Array=[]
	if txt.begins_with('%*"'): 			#"#注释
		match txt[3]:
			"*":
				if not is_login:
					if need_debug_message:
						print_rich("[color=green]》》》》登录成功！[/color]")
						debug_message.emit("[color=green]》》》》登录成功！[/color]")
					is_login=true
					login_success.emit()
			"s":
				if not is_login:
					if need_debug_message:
						print_rich("[color=yellow]》》》》房间错误，尝试断开与新房间重新建立链接。。。[/color]")
						debug_message.emit("[color=yellow]》》》》房间错误，尝试断开与新房间重新建立链接。。。[/color]")
					var new_room=txt.split(">")[0]
					new_room=new_room.right(new_room.length()-4)
					inpackeg["r"]=new_room
					ws.close()
		#%*"0	名字被占用
		#%*"1	用户不存在
		#%*"2	密码错误
		#%*"4	今日可尝试登录次数达到上限
		#%*"5	房间密码错误
		#%*"x(到期时间)#(原因)	账户被封禁
		#%*"6	房间不存在
			"0":
				if need_debug_message:
					print_rich("[color=red]》》》》名字被占用，请重新登录[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("名字被占用，请重新登录")
				ws.close()
				ws=null
				pass
			"1":
				if need_debug_message:
					print_rich("[color=red]》》》》用户不存在，请重新登录[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("用户不存在，请重新登录")
				ws.close()
				pass
			"2":
				if need_debug_message:
					print_rich("[color=red]》》》》密码错误，请重新登录[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("密码错误")
				ws.close()
				pass
			"3":
				if need_debug_message:
					print_rich("[color=red]》》》》尝试登录次数达到上限[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("登录上限")
				ws.close()
				pass
			"4":
				if need_debug_message:
					print_rich("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("房间错误")
				ws.close()
				pass
			"5":
				if need_debug_message:
					print_rich("[color=red]》》》》房间密码错误[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("房间密码错误")
				ws.close()
				pass
			"6":
				if need_debug_message:
					print_rich("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
					debug_message.emit("[color=red]》》》》房间错误，请重新输入房间信息[/color]")
				is_in_logging=false
				Toast.popup("房间错误")
				ws.close()
	elif txt.begins_with('"'):
		
		var new_text=txt.right(txt.length()-1)
		if new_text.begins_with('"'):
			new_text=txt.right(txt.length()-1)
			if need_debug_message:
				print_rich("[color=white]《《《《私聊信息：[/color]"+new_text)
				debug_message.emit("[color=white]《《《《私聊信息：[/color]"+new_text)
			var txt_arr=new_text.split("<")
			var side_dic_array:Array[Dictionary]=[]
			for i in txt_arr:
				var new_dic={}
				var spl=i.split(">")
				new_dic["name"]=spl[2]
				new_dic["message"]=spl[4]
				new_dic["head"]=spl[3]
				new_dic["uid"]=spl[1]
				side_dic_array.append(new_dic)
			if need_debug_message:
				print_rich("[color=white]《《《《私聊信息处理结果：[/color]",side_dic_array)
				debug_message.emit("[color=white]《《《《私聊信息处理结果：[/color]"+str(side_dic_array))
			side_message_received.emit(side_dic_array)
			_on_side_message_received(side_dic_array)
		else:
			if need_debug_message:
				print_rich("[color=yellow]《《《《房间信息：[/color]"+new_text)
				debug_message.emit("[color=yellow]《《《《房间信息：[/color]"+new_text)
			var txt_arr=new_text.split("<")
			var room_dic_array:Array[Dictionary]=[]
			for i in txt_arr:
				var new_dic={}
				var spl=i.split(">")
				new_dic["name"]=spl[2]
				new_dic["message"]=spl[3]
				new_dic["head"]=spl[1]
				new_dic["uid"]=spl[8]
				room_dic_array.append(new_dic)
			if need_debug_message:
				print_rich("[color=yellow]《《《《房间信息处理结果：[/color]",room_dic_array)
				debug_message.emit("[color=yellow]《《《《房间信息处理结果：[/color]"+str(room_dic_array))
			room_message_received.emit(room_dic_array)
			_on_room_message_received(room_dic_array)
	elif txt.begins_with("="):
		var new_text=txt.right(txt.length()-1)
		if need_debug_message:
			print_rich("[color=blue]《《《《弹幕信息：[/color]"+new_text)
			debug_message.emit("[color=blue]《《《《弹幕信息：[/color]"+new_text)
		var txt_arr=new_text.split("<")
		var bullet_dic_array:Array[Dictionary]=[]
		for i in txt_arr:
			var new_dic={}
			var spl=i.split(">")
			new_dic["name"]=spl[0]
			new_dic["message"]=spl[1]
			new_dic["head"]=spl[5]
			new_dic["uid"]=spl[7]
			bullet_dic_array.append(new_dic)
		bullet_message_received.emit(bullet_dic_array)
		_on_bullet_message_received(bullet_dic_array)
		if need_debug_message:
			print_rich("[color=blue]《《《《弹幕信息处理结果：[/color]",bullet_dic_array)
			debug_message.emit("[color=blue]《《《《弹幕信息处理结果：[/color]"+str(bullet_dic_array))
	elif txt.begins_with(">"):
		var new_text=txt.right(txt.length()-1)
		if need_debug_message:
			print_rich("[color=teal]《《《《股票消息：[/color]"+new_text)
			debug_message.emit("[color=teal]《《《《股票消息：[/color]"+new_text)
		var spl=new_text.split('"') #"#抱歉这里就先用注释顶一下了，高亮文本有错误
		stock_message[0]=int(spl[0])
		stock_message[1]=float(spl[1])
		stock_message[2]=float(spl[2])
		if need_debug_message:
			print_rich("[color=teal]《《《《股票消息处理结果：[/color]",stock_message)
			debug_message.emit("[color=teal]《《《《股票消息处理结果：[/color]"+str(stock_message))
		stock_update.emit()
	elif txt.begins_with("m"):
		if txt.length()==1:
			inpackeg["r"]=next_room
			ws.close()
			pass
		
		pass
	else:
		if txt.length()>=100:
			if not is_login:
				if need_debug_message:
					print_rich("[color=green]》》》》登录成功！[/color]")
					debug_message.emit("[color=green]》》》》登录成功！[/color]")
				is_login=true
				login_success.emit()
		else:
			#print(txt)
			#debug_message.emit(txt)
			pass
	pass
func poll() -> void:
	if ws.get_ready_state() != ws.STATE_CLOSED:
		ws.poll()
	var state = ws.get_ready_state()
	if last_state != state:
		last_state = state
		if state == ws.STATE_OPEN:
			connected_to_server.emit()
			connected()
		elif state == ws.STATE_CLOSED:
			var code = ws.get_close_code()
			var reason = ws.get_close_reason()
			var res=[code, reason]

			connection_closed.emit(res)
			closed(res)
	while ws.get_ready_state() == ws.STATE_OPEN and ws.get_available_packet_count():
		var mes_data=get_message()
		message_received.emit(mes_data)
		get_mes(mes_data)
func get_message() -> PackedByteArray:
	if ws.get_available_packet_count() < 1:
		return PackedByteArray()
	var pkt = ws.get_packet()
	#print(str(pkt))
	return pkt
func connected():
	if need_debug_message:
		print("[color=green]》》》》成功链接到蔷薇[/color]")
		debug_message.emit("[color=green]》》》》成功链接到蔷薇[/color]")
	send_in_pack()
func closed(res:Array):
	if is_in_logging:
		is_login=false
		ws.connect_to_url("ws://m1.iirose.com:8777",TLSOptions.client())
		if need_debug_message:
			print_rich("[color=red]》》》》断开链接[/color]")
			debug_message.emit("[color=red]》》》》断开链接[/color]")
			print(str(res))
			print("重新链接中。。。")
			debug_message.emit("重新链接中。。。")
func get_mes(pac:PackedByteArray):
	get_string_from_packeg(pac)
func sent_popup(mes:String):
	var x:Dictionary={
		"t":"test","c":"040b02","v":0

	}
	x["t"]=mes
	ws.send_text("~"+JSON.stringify(x))
func sent_tu(uid:String,mes:String=""):
	if need_debug_message:
		print("》》》》尝试给用户"+uid+"点赞")
		debug_message.emit("》》》》尝试给用户"+uid+"点赞")
	if ws.get_ready_state()==WebSocketPeer.STATE_OPEN:
		sent_str("+*"+uid+""+mes)
func sent_str(txt:String):
	if ws.get_ready_state()==WebSocketPeer.STATE_OPEN:
		var err=ws.send_text(txt)
		if err==OK:
			if need_debug_message:
				print_rich("[color=green]发送成功！[/color]")
				debug_message.emit("[color=green]发送成功！[/color]")
		else:
			if need_debug_message:
				print_rich("[color=red]发送失败，遇到未知错误！[/color]")
				debug_message.emit("[color=red]发送失败，遇到未知错误！[/color]")
	else:
		if need_debug_message:
			print_rich("[color=red]发送失败，未链接到蔷薇！[/color]")
			debug_message.emit("[color=red]发送失败，未链接到蔷薇！[/color]")
func sent_room_message(mes:String,color:String="ffffff"):
	if need_debug_message:
		print("》》》》尝试向蔷薇发送房间消息："+mes)
		debug_message.emit("》》》》尝试向蔷薇发送房间消息："+mes)
	var room_dic={}	 #{"m":"(消息内容)","mc":"(消息颜色)","i":"(随机数)"}	
	room_dic["m"]=mes
	room_dic["mc"]=color
	var z=str(randf())
	z=z.left(14)
	z=z.right(z.length()-2)
	room_dic["i"]=z
	sent_str(JSON.stringify(room_dic))
func sent_bullet_message(mes:String,color:String="ffffff"):
	if need_debug_message:
		print("》》》》尝试向蔷薇发送弹幕消息："+mes)
		debug_message.emit("》》》》尝试向蔷薇发送弹幕消息："+mes)
	var bullet_dic={} #~{"t":"(消息内容)","c":"(消息颜色)","v":0}
	bullet_dic["t"]=mes
	bullet_dic["c"]=color
	bullet_dic["v"]=0
	sent_str("~"+JSON.stringify(bullet_dic))
func sent_side_message(uid:String,mes:String,color:String="ffffff"):
	if need_debug_message:
		print("》》》》尝试向用户["+uid+"]发送私聊消息："+mes)
		debug_message.emit("》》》》尝试向用户["+uid+"]发送私聊消息："+mes)
	var side_dic={} 
	side_dic["g"]=uid
	side_dic["m"]=mes
	side_dic["mc"]=color
	var z=str(randf())
	z=z.left(14)
	z=z.right(z.length()-2)
	side_dic["i"]=z
	sent_str(JSON.stringify(side_dic))
func ping():
	if ws.get_ready_state()==WebSocketPeer.STATE_OPEN:
		sent_str("s")
func get_self_name()->String:
	return inpackeg["n"]



func move_to_room(r:String):
	next_room=r
	sent_str("m"+r)


func _on_bullet_message_received(arr: Array) -> void:
	for i in arr:
		var id:String=i["name"]
		if id!=get_self_name():
			PromptMessageControler.prompt(id,"iirose_triger_bullet",i)
			
	pass # Replace with function body.


func _on_room_message_received(arr: Array) -> void:
	for i in arr:
		var id:String=i["name"]
		put_room_cache(i)
		if id!=get_self_name():
			PromptMessageControler.prompt(id,"iirose_triger_room",i)
	pass # Replace with function body.


func _on_side_message_received(arr:Array) -> void:
	for i in arr:
		var id:String=i["name"]
		if id!=get_self_name():
			PromptMessageControler.prompt(id,"iirose_triger_side",i)