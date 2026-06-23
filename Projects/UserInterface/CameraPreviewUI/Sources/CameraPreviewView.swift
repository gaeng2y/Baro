@preconcurrency import AVFoundation
import SwiftUI
import TennisCore

public struct CameraPreviewView: View {
    private let camera: CameraClient

    public init(camera: CameraClient) {
        self.camera = camera
    }

    public var body: some View {
        ZStack {
            if let session = camera.captureSession() {
                CameraPreviewRepresentable(session: session)
            } else {
                Color.black
                    .overlay {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(.white.opacity(0.72))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
        }
    }
}

private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
