import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
gi.require_version('GdkPixbuf', '2.0')
from gi.repository import Gtk, Gdk, GtkLayerShell, GdkPixbuf
import sys

image_path = "/tmp/pinterest_widget.jpg"

# 1. 🧠 Read the image to calculate its exact aspect ratio!
try:
    pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)
    img_w = pixbuf.get_width()
    img_h = pixbuf.get_height()
except Exception as e:
    print(f"Baka! Failed to load image: {e}")
    sys.exit(1)

# 2. 📐 Dynamically resize the widget! (Max 300x450)
max_w = 300
max_h = 450
ratio = img_w / img_h

target_w = max_w
target_h = int(target_w / ratio)

# If it's still too tall, constrain by height instead!
if target_h > max_h:
    target_h = max_h
    target_w = int(target_h * ratio)

# 3. 🎨 Build the Window
window = Gtk.Window()
GtkLayerShell.init_for_window(window)
GtkLayerShell.set_layer(window, GtkLayerShell.Layer.BACKGROUND)

# Pin it EXACTLY 30px from the top right
GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, True)
GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, True)
GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, 30)
GtkLayerShell.set_margin(window, GtkLayerShell.Edge.RIGHT, 30)

# 🌟 MAGIC TRICK: Force the base window to support transparency!
screen = window.get_screen()
visual = screen.get_rgba_visual()
if visual and screen.is_composited():
    window.set_visual(visual)
window.set_app_paintable(True)

box = Gtk.Box()
window.add(box)

css_provider = Gtk.CssProvider()
# We force 'window' to be transparent, and use our calculated sizes for the box!
css = f"""
window {{
    background-color: transparent;
}}
#pin-box {{
    background-image: url("file://{image_path}");
    background-size: cover; 
    background-position: center;
    background-repeat: no-repeat;
    background-color: transparent;
    min-width: {target_w}px;
    min-height: {target_h}px;
    border-radius: 20px;
    /* I DELETED THE SHADOW LINE! IT'S GONE! */
}}
"""
css_provider.load_from_data(css.encode('utf-8'))
box.set_name("pin-box")

# Apply CSS to both the box and the main window
Gtk.StyleContext.add_provider_for_screen(
    Gdk.Screen.get_default(),
    css_provider,
    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
)

window.show_all()
Gtk.main()
