tool
extends TextureRect

#Señales 
signal Joystick_Start;
signal Joystick_End;
signal Joystick_Updated;

export (float) var radius = 30;

export (bool) var use_screen_rectangle = false;
export (bool) var use_all_screen = false;
export (Rect2) var screen_rectangle = Rect2();
export (Color) var editor_color = Color(1, 0, 0, 1);
var joystick_vector = Vector2();
var joystick_touch_id = null;
var joystick_active = false;


var joystick_ring;

func _draw():
	# This code will only run in the editor!
	if (Engine.editor_hint == true):
		
		var draw_screen_rect = screen_rectangle;
		draw_screen_rect.position -= rect_global_position;
		
		draw_line(draw_screen_rect.position, draw_screen_rect.position + Vector2(0, draw_screen_rect.size.y), editor_color, 4);
		draw_line(draw_screen_rect.position + Vector2(0, draw_screen_rect.size.y), draw_screen_rect.position + Vector2(draw_screen_rect.size.x, draw_screen_rect.size.y), editor_color, 4);
		draw_line(draw_screen_rect.position, draw_screen_rect.position + Vector2(draw_screen_rect.size.x, 0), editor_color, 4);
		draw_line(draw_screen_rect.position + Vector2(draw_screen_rect.size.x, 0), draw_screen_rect.position + Vector2(draw_screen_rect.size.x, draw_screen_rect.size.y), editor_color, 4);
		
		# Draw the radius circle.
		draw_circle( get_center_of_joystick(), radius, Color8(256,256,256,128));


func _ready():
	joystick_ring = get_node("BolaAnalogo");
	joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
	joystick_vector = Vector2(0, 0);
	
	#visible = false
	
	if use_all_screen:
		screen_rectangle = Rect2(0,0,1280,720)
		print( "Rect " + String(screen_rectangle) )
		
	
	
func get_center_of_joystick():
	return (get_rect().position + get_rect().size/2) - rect_global_position;


func _input(event):
	# If the event is a press/touch...
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		
		# We need to figure out if this is a press, or a release
		var event_is_press = true;
		
		# Figure out if this is a press or a release based on the type of input event.
		# (They happen to have the same property in this case, but it is good habit to
		# not assume they will, and therefore treat them separately)
		if event is InputEventScreenTouch:
			event_is_press = event.pressed;
		elif event is InputEventMouseButton:
			event_is_press = event.pressed;
		
		# If the event is a press...
		if (event_is_press == true):
			# If this joystick is not yet active...
			if (joystick_active == false):
				
				# Check to see if this joystick uses a portion of the screen, or if it is just static.
				# If it does use a portion of the screen...
				if (use_screen_rectangle == true):
					
					# We need to figure out where the event happened and get the event's ID
					var event_position = Vector2();
					var event_ID = null;
					
					# Get the event position and ID
					if event is InputEventScreenTouch:
						event_position = event.position;
						event_ID = event.index;
					elif event is InputEventMouseButton:
						event_position = get_global_mouse_position();
						event_ID = null;
					
					# Check if the event happened within the screen rectangle
					if (screen_rectangle.has_point(event_position)):
						
						# Move the joystick to the event position so the joystick
						# appears under the mouse/touch.
						rect_global_position = event_position - (rect_size/2);
						
						# Set the joystick event ID.
						joystick_touch_id = event_ID;
						
						# Set the joystick as active, and make it visible.
						joystick_active = true;
						visible = true;
						
						# dejar bola del analogo en el centro
						joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
						
						# Reset the joystick vector (since the joystick ring is in the center)
						joystick_vector = Vector2(0,0);
						
						# Now the joystick has just been activated, emit Joystick_Start.
						emit_signal("Joystick_Start");
						print ("Inicio el joitck");
				
				
				# Otherwise, we just need to check if the event is within the radius of the joystick
				else:
					
					# We need to figure out where the event happened and get the event's ID
					var event_position = Vector2();
					var event_ID = null;
					
					# Get the event position and ID
					if event is InputEventScreenTouch:
						event_position = event.position;
						event_ID = event.index;
					elif event is InputEventMouseButton:
						event_position = get_global_mouse_position();
						event_ID = null;
					
					# If the event is within the radius of the joystick.
					if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
						
						# Set the joystick event ID.
						joystick_touch_id = event_ID;
						
						# Make the joystick active.
						joystick_active = true;
						
						# Calculate the new joystick vector value, using some math to make a vector pointing from the
						# center of the joystick to the event's position, and then divide it by the joystick radius to get
						# a normalized vector.
						joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
						
						# Set the joystick's position
						joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2);
						
						# Now the joystick has just been activated, emit Joystick_Start.
						emit_signal("Joystick_Start");
				
				
			
		
		# If the event is a release...
		else:
			# If the joystick is active...
			if (joystick_active == true):
				
				# We need to figure out if the event has the Index we are bound to
				var event_ID = null;
				
				# Get the event ID
				if event is InputEventScreenTouch:
					event_ID = event.index;
				elif event is InputEventMouseButton:
					event_ID = null;
				
				# Figure out if it is this joystick's event
				if (joystick_touch_id == event_ID):
					
					# Reset everything, and if we are using a portion of the screen, then become
					# invisible
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
					joystick_vector = Vector2(0, 0);
					
					joystick_touch_id = null;
					joystick_active = false;
					
					if (use_screen_rectangle == true):
						visible = false;
					
					# Emit the Joystick_End signal because the joystick is now inactive.
					emit_signal("Joystick_End");
					print ("Solte el joystick")
		
	
	# If the event is a motion event... (mouse/finger is moving on/across the screen)
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		
		# Only bother to update if we are active/in-use
		if (joystick_active == true):
			
			# We need to figure out if the event has the Index we are bound to
			# and we need to get the position of the event
			var event_ID = null;
			var event_position = Vector2();
			
			# Get the event ID and position
			if event is InputEventScreenDrag:
				event_ID = event.index;
				event_position = event.position;
			elif event is InputEventMouseMotion:
				event_ID = null;
				event_position = get_global_mouse_position();

			#print (event_position);
			
			# If this event is this joystick's event.
			if (event_ID == joystick_touch_id):
				
				# Check to see if the event position is within the joystick's radius.
				# If it is, update the position of the inner ring, update joystick_vector with the new values,
				# and emit the Joystick_Updated signal.
				if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
					joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2);
					
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
					emit_signal("Joystick_Updated");
				
				# If the event position is NOT within the joystick radius, we need to calculate the values
				# differently, but within the radius of the joystick (even though the event is outside it)
				#
				# We calculate the joystick vector using a normalized vector,
				# We use a normalized direction from the center to the event position and multiply it by the joystick's
				# radius so that it is on the edge of the joystick,
				# and emit the Joystick_Updated signal.
				else:
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position).normalized()
					
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
					joystick_ring.rect_global_position -= joystick_vector * radius;
					
					emit_signal("Joystick_Updated");
					
				print (joystick_vector);
	
