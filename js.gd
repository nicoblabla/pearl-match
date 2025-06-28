extends Node

# Here we create a reference to the `_on_permissions` function (below).
# This reference will be kept until the node is freed.
var _permission_callback = JavaScriptBridge.create_callback(_on_permissions)

func _ready():
	# NOTE: This is done in `_ready` for simplicity, but SHOULD BE done in response
	# to user input instead (e.g. during `_input`, or `button_pressed` event, etc.),
	# otherwise it might not work.

	var window = JavaScriptBridge.get_interface("window")
	window.open("https://docs.godotengine.org/", "_blank", "noopener noreferrer")

	# Get the `window.Notification` JavaScript object.
	var notification = JavaScriptBridge.get_interface("Notification")
	print(notification)
	# Call the `window.Notification.requestPermission` method which returns a JavaScript
	# Promise, and bind our callback to it.
	notification.requestPermission().then(_permission_callback)

func _on_permissions(args):
	# The first argument of this callback is the string "granted" if the permission is granted.
	var permission = args[0]
	if permission == "granted":
		print("Permission granted, sending notification.")
		# Create the notification: `new Notification("Hi there!")`
		#JavaScriptBridge.create_object("Notification", "Hi there!")
		
		askLocationPermission()
		
	else:
		print("No notification permission.")
		
var _success_callback = JavaScriptBridge.create_callback(success)
var _error_callback = JavaScriptBridge.create_callback(error)

func askLocationPermission():
	var navigator = JavaScriptBridge.get_interface("navigator")
	print(navigator)
	
	navigator.geolocation.getCurrentPosition(_success_callback, _error_callback);
	


func success(args) :
	var console = JavaScriptBridge.get_interface("console")
	# Call the `window.console.log()` method.
	console.log(args[0])
	var pos = args[0]
	console.log(pos.coords)
	var crd = pos.coords;
	var lat = crd.latitude
	var lon = crd.longitude
	var acc = crd.accuracy

	print(lat)
	print("Your current position is:")
	print("Latitude: ", lat)
	print("`Longitude: ", lon)
	print("`More or less ", acc," meters")
	
	var format_string = "This you ? %f, %f " % [lat, lon]
	JavaScriptBridge.create_object("Notification", format_string)

func error(args) :
	print("No notification permission.")
	#console.warn(`ERROR(${err.code}): ${err.message}`)
