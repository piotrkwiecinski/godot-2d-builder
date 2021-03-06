class_name GroundEntity
extends Node2D

var blueprint: BlueprintEntity

onready var area := $Area2D
onready var animation := $AnimationPlayer
onready var sprite := $Sprite
onready var tween := $Tween


func setup(_blueprint: BlueprintEntity, location: Vector2) -> void:
	blueprint = _blueprint
	var blueprint_sprite := blueprint.get_node("Sprite")
	sprite.texture = blueprint_sprite.texture
	sprite.region_enabled = blueprint_sprite.region_enabled
	sprite.region_rect = blueprint_sprite.region_rect
	sprite.centered = blueprint_sprite.centered
	global_position = location
	_pop()


func do_pickup(target: KinematicBody2D) -> void:
	var elapsed_time := 0.1
	area.hide()
	while true:
		var distance_to_target := global_position.distance_to(target.global_position)
		if distance_to_target < 5.0:
			queue_free()
			return

		global_position = global_position.move_toward(target.global_position, elapsed_time)
		elapsed_time += 0.1
		yield(get_tree(), "idle_frame")


func _pop() -> void:
	var direction := Vector2.UP.rotated(rand_range(-PI, PI))
	direction.y /= 2.0
	direction *= rand_range(20, 70)

	var target_position := global_position + direction
	var height_position := global_position + direction * Vector2(0.5, 2 * -sign(direction.y))

	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		height_position,
		0.15,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "global_position", height_position, target_position, 0.25, 0, Tween.EASE_IN, 0.15
	)
	tween.start()
	yield(tween, "tween_all_completed")
	animation.play("Float")
