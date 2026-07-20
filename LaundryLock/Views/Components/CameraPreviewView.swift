import AVFoundation
import SwiftUI

/// UIKit-Wrapper, der den Live-Sucher einer AVCaptureSession in SwiftUI anzeigt.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    // TODO [WEITERBAUEN]: Tap-to-Focus und Pinch-to-Zoom ergänzen — hilfreich, wenn die
    // Maschine in einer dunklen Ecke steht und der Autofokus daneben liegt.
}
