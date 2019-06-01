//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import CoreImage

extension URL {
    func qrCustomCode(using color: UIColor, logo: UIImage? = nil) -> CIImage? {
        let tintedQRImage = qrCode?.tinted(using: color)
        
        guard let logo = logo?.cgImage else {
            return tintedQRImage
        }
        
        return tintedQRImage?.addLogo(with: CIImage(cgImage: logo))
    }
    
    /// Returns a black and white QR code for this URL.
    var qrCode: CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        return qrFilter.outputImage?.transformed(by: qrTransform)
    }
}

extension CIImage {
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }
    
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }
    
    var blackTransparent: CIImage? {
        guard let blackTransparentCIFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentCIFilter.setValue(self, forKey: "inputImage")
        return blackTransparentCIFilter.outputImage
    }
    
    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage!
    }
    
    func addLogo(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
}

final class MyViewController : UIViewController {
    let codalienColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.00)
    let codalienLogo = UIImage(named: "codalien.png")!
    
    override func loadView() {
        guard let qrCode = URL(string: "https://codalien.com")?.qrCustomCode(using: codalienColor, logo: codalienLogo) else { return }
        let imageView = UIImageView(image: UIImage(ciImage: qrCode))
        imageView.contentMode = .center
        imageView.layer.backgroundColor = UIColor.white.cgColor
        self.view = imageView
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
