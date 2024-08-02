import UIKit
import SwiftUI
import CoreML

class ViewController: UIViewController {

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textColor = .white
        label.text = ""
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Back", for: .normal)
            if let copperplateBoldFont = UIFont(name: "Copperplate-Bold", size: 18) {
                button.titleLabel?.font = copperplateBoldFont
            } else {
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            }
            button.setTitleColor(.white, for: .normal)
            
       
            button.backgroundColor = UIColor.systemBlue
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            button.isHidden = true
            return button
        }()

    private var splashScreenHostingController: UIHostingController<SplashScreenView>?
    private var photoCaptureHostingController: UIHostingController<PhotoCaptureView>?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSplashScreen()
        view.addSubview(resultLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let labelHeight: CGFloat = 300
        resultLabel.frame = CGRect(
            x: 20,
            y: (view.frame.size.height - labelHeight) / 2 - 20,
            width: view.frame.size.width - 40,
            height: labelHeight
        )

        if !backButton.isHidden {
            let buttonHeight: CGFloat = 44
            backButton.frame = CGRect(
                x: (view.frame.size.width - 100) / 2,
                y: resultLabel.frame.maxY + 20,
                width: 100,
                height: buttonHeight
            )
        }
    }
    
    private func showSplashScreen() {
        let splashScreenView = SplashScreenView(onLogin: { [weak self] in
            self?.navigateToPhotoCapture()
        })
        
        splashScreenHostingController = UIHostingController(rootView: splashScreenView)
        
        if let hostingController = splashScreenHostingController {
            addChild(hostingController)
            hostingController.view.frame = view.bounds
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
    }
    
    private func navigateToPhotoCapture() {
        let photoCaptureView = PhotoCaptureView(onImageCaptured: { [weak self] image in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.analyzeImage(image: image)
            }
        })
        photoCaptureHostingController = UIHostingController(rootView: photoCaptureView)
        
        if let hostingController = photoCaptureHostingController {
            present(hostingController, animated: true, completion: nil)
        }
    }

    private func analyzeImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else {
            DispatchQueue.main.async {
                self.showResult(resultText: "Failed to process image.")
            }
            return
        }

        do {
            let config = MLModelConfiguration()
            let model = try trash_tracker_1(configuration: config)
            let input = trash_tracker_1Input(image: buffer)

            let output = try model.prediction(input: input)
            let text = output.target
            let message = self.getMessage(for: text)
            DispatchQueue.main.async {
                self.showResult(resultText: message)
            }
        } catch {
            DispatchQueue.main.async {
                self.showResult(resultText: "Error: \(error.localizedDescription)")
            }
        }
    }

    private func getMessage(for prediction: String) -> String {
        switch prediction.lowercased() {
        case "trash":
            return "Your object is trash. Dispose of this object by putting it in the trash can and leaving the trash can at your curb for the local trash services to pick it up."
        case "recycle":
            return "Your object is recycling. Dispose of this object by putting it in the recycling bin and leaving the bin at your curb for the local recycling services to pick it up. Make sure to keep the object clean and dry, separate all materials, and flatten and compress."
        case "compost":
            return "Your object is compost. You can dispose of this object by adding it to your flower and vegetable beds, window boxes, and container gardens, incorporating it into tree beds, mixing it with potting soil for indoor plants, or spreading it on top of the soil in your yard. Compost can also be used as a soil amendment or as a mulch."
        default:
            return "Prediction: \(prediction)"
        }
    }

    private func showResult(resultText: String) {
        splashScreenHostingController?.view.removeFromSuperview()
        splashScreenHostingController?.removeFromParent()
        photoCaptureHostingController?.dismiss(animated: true, completion: nil)

        resultLabel.attributedText = formatResultText(resultText: resultText)
        view.addSubview(backButton) // Add the back button only on the result page
        backButton.isHidden = false
        viewDidLayoutSubviews() // Recalculate layout for the button
    }

    private func formatResultText(resultText: String) -> NSAttributedString {
        let boldFont = UIFont(name: "Copperplate", size: 30) ?? UIFont.boldSystemFont(ofSize: 30) // Replace "Helvetica-Bold" with your custom font name
        let regularFont = UIFont(name: "Copperplate", size: 20) ?? UIFont.systemFont(ofSize: 20) // Replace "Helvetica" with your custom font name
        let attributedString = NSMutableAttributedString(string: resultText, attributes: [.font: regularFont])
        
        let wordsToBold = ["trash", "recycling", "compost"]
        
        for word in wordsToBold {
            let range = (resultText as NSString).range(of: word, options: .caseInsensitive)
            if range.location != NSNotFound {
                attributedString.addAttributes([.font: boldFont, .foregroundColor: UIColor.green], range: range)
            }
        }
        
        return attributedString
    }



    @objc private func backButtonTapped() {
        resultLabel.text = ""
        backButton.isHidden = true
        backButton.removeFromSuperview()
        navigateToPhotoCapture()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        analyzeImage(image: image)
    }
}
