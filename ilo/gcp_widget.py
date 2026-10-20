import sys
import os
import subprocess
from PyQt6.QtCore import Qt, QUrl, QTimer
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget
from PyQt6.QtWebEngineWidgets import QWebEngineView

os.environ["QT_LOGGING_RULES"] = "qt.qpa.wayland=false"

class GCPDotWidget(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("GCP_Widget_Large")

        # Arch/Hyprland specific flags
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint |
            Qt.WindowType.WindowStaysOnTopHint |
            Qt.WindowType.Tool
        )
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setFixedSize(200, 200)

        # The Browser (The part you want to see)
        self.browser = QWebEngineView(self)
        self.browser.setContextMenuPolicy(Qt.ContextMenuPolicy.NoContextMenu)
        self.browser.resize(200, 200)
        self.browser.page().setBackgroundColor(Qt.GlobalColor.transparent)

        # The Shield (The part that catches your clicks!)
        # It's a transparent layer on top of the browser.
        self.click_shield = QWidget(self)
        self.click_shield.setGeometry(0, 0, 200, 200)
        self.click_shield.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        # We make sure it's on top!
        self.click_shield.raise_()

        self.browser.loadFinished.connect(self._on_load_finished)
        self.browser.setUrl(QUrl("https://global-mind.org/gcpdot/gcp.html"))

        self.refresh_timer = QTimer(self)
        self.refresh_timer.timeout.connect(self.browser.reload)
        self.refresh_timer.start(600000)

    # Now we catch clicks on the SHIELD, not the browser!
    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            print("Intercepted! Reloading now... Hmph! 🙄")
            self.browser.reload()
        super().mousePressEvent(event)

    def showEvent(self, event):
        super().showEvent(event)
        QTimer.singleShot(100, lambda: subprocess.run(
            ["hyprctl", "dispatch", "movewindowpixel", "exact 1377 50,title:^GCP_Widget_Large$"]
        ))

    def _on_load_finished(self):
        padding_value = "5px"
        js_code = f"""
        (function() {{
            var links = document.getElementsByTagName('a');
            for(var i=0; i<links.length; i++) {{
                links[i].removeAttribute('href');
            }}
            var style = document.createElement('style');
            style.innerHTML = `
                * {{
                    overflow: hidden !important;
                    margin: 0 !important;
                    padding: 0 !important;
                    background: transparent !important;
                    pointer-events: none !important; /* Back to none so it doesn't fight the shield! */
                    user-select: none !important;
                }}
                body, html {{ background: transparent !important; display: block !important; padding-top: {padding_value} !important; text-align: center !important; }}
                center, table {{ display: inline-block !important; transform: scale(4.0) !important; transform-origin: top center !important; image-rendering: pixelated !important; }}
                br, font, p {{ display: none !important; }}
            `;
            document.head.appendChild(style);
        }})();
        """
        self.browser.page().runJavaScript(js_code)

app = QApplication(sys.argv)
app.setProperty("QT_QPA_PLATFORM", "wayland")

if __name__ == "__main__":
    main_win = GCPDotWidget()
    main_win.show()
    sys.exit(app.exec())
