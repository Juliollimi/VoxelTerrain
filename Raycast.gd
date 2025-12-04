extends RayCast3D

@export var cooldown : float = 0.2
var timer : float = 0.0

func _process(delta):
	timer += delta


func try_dig():
	if timer < cooldown:
		return
	
	if not is_colliding():
		return
		
	const AIR := 0

	var collider = get_collider()
	
	if collider.is_class("VoxelTerrain"):
		
		# Punto del impacto
		var hit_point = get_collision_point()

		# Empujar punto 0.01 dentro del bloque
		# Esto evita pegarle a los bordes
		var inset_point = hit_point - (get_collision_normal() * 0.01)

		var tool = collider.get_voxel_tool()

		if tool:
			tool.channel = VoxelBuffer.CHANNEL_TYPE

			# Convertir a coordenada interna
			var local_hit = collider.to_local(inset_point)

			var voxel_pos = Vector3i(
				int(floor(local_hit.x)),
				int(floor(local_hit.y)),
				int(floor(local_hit.z))
			)
			
			tool.set_voxel(voxel_pos, AIR)

			print("Bloque eliminado:", voxel_pos)
			timer = 0.0
