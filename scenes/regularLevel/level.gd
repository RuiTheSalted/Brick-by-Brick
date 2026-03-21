extends Node2D

# ALL THIS CODE IS JUST TO TAKE A SCREENSHOT.
# LEAVE IT ALONE UNLESS YOU NEED TO ADD A SCRIPT BUT LET MARTIN KNOW
# SCREENSHOT IS TAKEN WITH "T" AND STORED IN PROJECT -> OPEN USER DATA FOLDER

func _input(event):
	# Trigger the screenshot when the 'screenshot' action is pressed
	if event.is_action_pressed("screenshot"):
		take_screenshot()

func take_screenshot():
	# It is recommended to wait for the frame to finish rendering to ensure a complete capture
	await RenderingServer.frame_post_draw 
	
	# Get the image data from the current viewport
	var image = get_viewport().get_texture().get_image()

	# Generate a unique file name using the system date and time
	# Replace invalid characters (like ":" and ".") for cross-platform compatibility
	var date_string = Time.get_date_string_from_system().replace(".", "_")
	var time_string = Time.get_time_string_from_system().replace(":", "")
	var screenshot_path = "user://screenshot_" + date_string + "_" + time_string + ".png"

	# Save the image to the user directory
	image.save_png(screenshot_path)
	print("Screenshot saved to: ", screenshot_path)
