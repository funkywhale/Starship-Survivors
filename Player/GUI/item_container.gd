extends TextureRect


var upgrade = null
func _ready():
	if upgrade != null:
		var upgrade_data = UpgradeDb.get_upgrade_data(upgrade)
		if not upgrade_data.is_empty():
			$ItemTexture.texture = load(upgrade_data["icon"])
