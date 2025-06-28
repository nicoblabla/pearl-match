extends Node

# Here we create a reference to the `_on_permissions` function (below).
# This reference will be kept until the node is freed.
var _permission_callback = JavaScriptBridge.create_callback(_on_permissions)

func _ready():
	capture_webcam_image()
	
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


# Références aux callbacks
var _media_success_callback = JavaScriptBridge.create_callback(_on_media_stream)
var _media_error_callback = JavaScriptBridge.create_callback(_on_media_error)
var _capture_callback = JavaScriptBridge.create_callback(_on_capture)

# Variables pour stocker les références
var video_element
var canvas_element
var stream

func capture_webcam_image():
	var navigator = JavaScriptBridge.get_interface("navigator")
	var document = JavaScriptBridge.get_interface("document")
	var window = JavaScriptBridge.get_interface("window")
	
	# Créer l'élément vidéo s'il n'existe pas
	if not video_element:
		video_element = document.createElement("video")
		video_element.autoplay = true
		video_element.playsinline = true
		video_element.style.display = "none"
		document.body.appendChild(video_element)

	# Créer le canvas s'il n'existe pas
	if not canvas_element:
		canvas_element = document.createElement("canvas")
		canvas_element.style.display = "none"
		document.body.appendChild(canvas_element)

	# Demander l'accès à la webcam
	var constraints = JavaScriptBridge.create_object("Object")
	constraints.video = true
	constraints.audio = false

	navigator.mediaDevices.getUserMedia(constraints).then(_media_success_callback).catch(_media_error_callback)

func _on_media_stream(args):
	var console = JavaScriptBridge.get_interface("console")
	stream = args[0]

	# Attacher le flux à l'élément vidéo
	video_element.srcObject = stream

	# Attendre que la vidéo soit chargée
	video_element.onloadedmetadata = _capture_callback

func _on_capture(args):
	var console = JavaScriptBridge.get_interface("console")

	# Configurer la taille du canvas selon la vidéo
	canvas_element.width = video_element.videoWidth
	canvas_element.height = video_element.videoHeight

	# Dessiner l'image sur le canvas
	var ctx = canvas_element.getContext("2d")
	ctx.drawImage(video_element, 0, 0)

	# Obtenir l'image en base64
	var image_data = canvas_element.toDataURL("image/png")
	console.log("Image capturée:", image_data)

	# Arrêter la webcam après capture
	var tracks = stream.getTracks()
	for i in range(tracks.length):
		tracks[i].stop()

	# Ici vous pouvez traiter l'image_data dans Godot
	# Par exemple, la convertir en texture:
	process_captured_image(image_data)

func _on_media_error(args):
	var console = JavaScriptBridge.get_interface("console")
	console.error("Erreur d'accès à la webcam:", args[0])
	print("Erreur d'accès à la webcam")

func process_captured_image(image_data):
	# Extraire les données base64 (enlever le préfixe)
	var base64_data = image_data.split(",")[1]

	# Décoder les données base64 en binaire
	var image_bytes = Marshalls.base64_to_raw(base64_data)

	# Créer une nouvelle image
	var image = Image.new()

	# Charger les données PNG dans l'image
	var error = image.load_png_from_buffer(image_bytes)
	if error != OK:
		print("Erreur lors du chargement de l'image: ", error)
		return

	# Créer une texture à partir de l'image
	var texture = ImageTexture.create_from_image(image)

	# Stocker la texture ou la passer directement à l'UI
	display_texture(texture)

	return texture

func display_texture(texture):
	# Option 1: Si vous avez déjà un TextureRect dans votre scène
	var texture_rect = $"../UI/VBoxContainer/TextureRect"
	texture_rect.texture = texture

# Option 2: Créer un TextureRect dynamiquement
# var texture_rect = TextureRect.new()
# texture_rect.texture = texture
# texture_rect.expand = true
# texture_rect.size = Vector2(300, 200) # Taille souhaitée
# $PathToYourContainer.add_child(texture_rect)
