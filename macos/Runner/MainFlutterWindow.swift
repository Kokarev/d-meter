import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {

  override func awakeFromNib() {

    let flutterViewController = FlutterViewController()

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // ── Desktop constraints ──────────────────────────────
    self.minSize = NSSize(width: 390, height: 600)
  }
}
