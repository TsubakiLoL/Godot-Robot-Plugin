#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------

extends Control
#用于存储蔷薇账号的文件地址
var account_file:String="user://iirose_account.txt"
func _ready() -> void:
	var f=FileAccess.open(account_file,FileAccess.READ)
	if f==null:
		f=FileAccess.open(account_file,FileAccess.WRITE)
		f.close()
	else:
		f.close()
		load_account()
	print(get_iirose())
	$MarginContainer/Control/login.pressed.connect(_on_login_request)
	
	ModLoader.get_autoload("iirose").login_success.connect(set_color.bind(Color.GREEN))
func load_account():
	var f=FileAccess.open(account_file,FileAccess.READ)
	if f!=null:
		var txt=f.get_as_text()
		var res=JSON.parse_string(txt)
		if res is Array and res.size()==3 and res[0] is String and res[1] is String and res[2] is String:
			$MarginContainer/Control/name.text=res[0]
			$MarginContainer/Control/password.text=res[1]
			$MarginContainer/Control/room.text=res[2]
	pass


func get_iirose():
	return ModLoader.get_autoload("iirose")


func _on_login_request():
	var _name=$MarginContainer/Control/name.text
	var p=$MarginContainer/Control/password.text
	var r=$MarginContainer/Control/room.text
	get_iirose().set_information(_name,p,r)
	get_iirose().start_connect()
	get_iirose().need_debug_message=true
	if $MarginContainer/Control/shouldsave.button_pressed:
		save_account(_name,p,r)
	
	pass

func save_account(n:String,p:String,r:String):
	var f=FileAccess.open(account_file,FileAccess.WRITE)
	if f!=null:
		var res=[n,p,r]
		var str=JSON.stringify(res)
		f.store_string(str)
		f.close()
	pass

func set_color(color:Color):
	$MarginContainer/Control/flag.modulate=color
