extends TextureRect

@onready var lblName = $lbl_name
@onready var lblDescription = $lbl_description
@onready var lblLevel = $lbl_level
@onready var itemIcon = $ColorRect/ItemIcon

var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == null:
		item = "heal"
	var upgrade_data = UpgradeDb.get_upgrade_data(item)
	if not upgrade_data.is_empty():
		lblName.text = upgrade_data["displayname"]
		lblDescription.text = upgrade_data["details"]
		lblLevel.text = upgrade_data["level"]
		itemIcon.texture = load(upgrade_data["icon"])
	
func _input(event):
	if event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
