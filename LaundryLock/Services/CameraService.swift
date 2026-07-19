import AVFoundation
import UIKit

/// Schlanke AVFoundation-Kamera für beide Foto-Momente der App:
/// 1. Setup: Referenzfoto der Waschmaschine aufnehmen.
/// 2. Alarm: Beweisfoto aufnehmen, das gegen das Referenzfoto verifiziert wird.
@MainActor
final class CameraService: NSObject, ObservableObject {

    @Published var isAuthorized = false
    @Published var lastCapturedImage: UIImage?
    @Published var captureError: String?

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var isConfigured = false
    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    enum CameraError: Error { case notAuthorized, configurationFailed, captureFailed }

    // MARK: - Berechtigung & Setup

    func requestAccess() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            isAuthorized = false
            // TODO [WEITERBAUEN]: Freundlicher Hinweis + Link in die System-Einstellungen,
            // wenn die Kamera verweigert wurde — ohne Kamera ist die App nutzlos.
        }
    }

    func configureAndStart() async throws {
        guard isAuthorized else { throw CameraError.notAuthorized }
        guard !isConfigured else {
            startRunning()
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(photoOutput)
        else {
            session.commitConfiguration()
            throw CameraError.configurationFailed
        }

        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        isConfigured = true
        startRunning()
    }

    func startRunning() {
        guard !session.isRunning else { return }
        Task.detached { [session] in session.startRunning() }
    }

    func stopRunning() {
        guard session.isRunning else { return }
        Task.detached { [session] in session.stopRunning() }
    }

    // MARK: - Foto aufnehmen

    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            let settings = AVCapturePhotoSettings()
            // TODO [WEITERBAUEN]: Blitz-Handling für dunkle Keller/Waschküchen —
            // .auto setzen und im Sucher einen Blitz-Toggle anbieten.
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            defer { captureContinuation = nil }
            if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
                lastCapturedImage = image
                captureContinuation?.resume(returning: image)
            } else {
                captureError = error?.localizedDescription ?? "Foto konnte nicht aufgenommen werden."
                captureContinuation?.resume(throwing: CameraError.captureFailed)
            }
        }
    }
}
