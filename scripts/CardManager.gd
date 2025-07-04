extends Node2D

var card_being_dragged: Node2D
var drag_offset = Vector2.ZERO
var is_hovering_on_card
var index_dragged_from := 0

const COLLISION_CARD_MASK = 1
const HOVER_SCALE_AMOUNT = 1.1
const DEFAULT_SCALE = 1
const DEFAULT_SCALE_AMOUNT = Vector2(DEFAULT_SCALE, DEFAULT_SCALE)
const HOVER_TWEEEN_SPEED = 0.08  # smaller == faster
const MAX_X = 1920
const MAX_Y = 1080

func clamp_mouse(mouse_pos: Vector2):
	return Vector2(clamp(mouse_pos.x, 0, MAX_X), clamp(mouse_pos.y, 0, MAX_Y))

func _process(_delta):
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position() + drag_offset
		card_being_dragged.global_position = clamp_mouse(mouse_pos)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var card = raycast_check_for_card()
		if event.pressed:
			if card:
				drag_offset = card.global_position - get_global_mouse_position()
				start_drag(card)
		else: # ON RELEASE
			if card_being_dragged:
				finish_drag(card)
				#$"../Background/Camera2D".trigger_shake()
				#$"CardDropSound".play()

func start_drag(card):
	card_being_dragged = card
	card.scale = DEFAULT_SCALE_AMOUNT
	#var hand_array: Array = playerhand_node.player_hand
	#index_dragged_from = hand_array.find(card)
	#hand_array.erase(card)
	#playerhand_node.update_hand_positions()

func finish_drag(card: Node):
	if card:
		card_being_dragged.scale = Vector2(HOVER_SCALE_AMOUNT, HOVER_SCALE_AMOUNT)
	if card:
		var cardarea: Area2D = card.find_child("Area2D")
		if card.is_in_group("playing_cards"):
			var overlapping = cardarea.get_overlapping_areas()
			#if not overlapping.any(func(elem): return elem.is_in_group("glyph")):
				# return to hand
				#playerhand_node.add_card_to_hand(card, 0)
				#playerhand_node.update_hand_positions()
	
	card_being_dragged = null

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card_being_dragged:		
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	var target_scale = Vector2(HOVER_SCALE_AMOUNT, HOVER_SCALE_AMOUNT) if hovered else DEFAULT_SCALE_AMOUNT
	var target_z = 2 if hovered else 1
	card.z_index = target_z
	var tween = card.create_tween()
	tween.tween_property(card, "scale", target_scale, HOVER_TWEEEN_SPEED).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_CARD_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	# Assume first is highest
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index	
	# Loop through rest checking for higher
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
