
# How to generate QR Code in Swift with custom color and logo?

### What is a QR Code?
"QR" stands for "Quick Response", which refers to the instant access to the information hidden in the Code. The QR Code is a two-dimensional version of the barcode, known from product packaging in the supermarket. Originally developed for process optimization in the logistics of the automotive industry, the QR Code has found its way into mobile marketing with the widespread adoption of smartphones

### Let’s start…
As we all know, QR Code is used to share information or content. There are many apps that uses QR Code to share information like Twitter and Snapchat uses it to add User. And the other app like Paytm , PhonePe uses QR Code to or make easy to transfer money. 

We can use them as we want and QR Code is the fastest way to share information. 

Today we will learn ‘How to create QR Code in Swift’. Initially we will start with basic QR Code which provide you a blank and white QR Code and later we will add Custom Logo and Color. 

## Generating simple QR Code.
To generate QR Code in swift, we use Core Image Filter and CIQRCodeGenerator. It generates a plain black and white QR for the given input string.

```
guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
let qrData = absoluteString.data(using: String.Encoding.ascii)        qrFilter.setValue(qrData, forKey: "inputMessage")
let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
let qrCode = qrFilter.outputImage?.transformed(by: qrTransform)
```
A QR code is often linking to a URL. Therefore, it’s nice to create an extension on `URL` as well.

```
extension URL {
var qrCode: CIImage? {
guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
let qrData = absoluteString.data(using: String.Encoding.ascii)
qrFilter.setValue(qrData, forKey: "inputMessage")
let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
return qrFilter.outputImage?.transformed(by: qrTransform)
}
}
```

> and that can be used as:
```
let qrCode = URL(string: "https://codalien.com")?.qrCode
```

Till now, we have successfully generated QR Code, a simple black and white QR code. Lets move forward and customize QR code.

## Customizing QR Code.
#### Change Color
There are basically three steps to change the color of QR Code
- We need to invert the black and white color. 
- After inverting colors we will mask the black color to transparent
- Apply the given color as a tint color.

As you see in above code, we are using CIImage and returning qrCode in CIImage format. So, to make it easy we create all these functions in CIIMage extension.

```
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
}
```

> and that can be used as:

```
let codalienColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.00)
let qrCode = URL(string: "https://codalien.com")?.qrCode?.tinted(using: codalienColor)
```
#### Adding Logo in QR Code.
QR code has a feature called [error correction](https://www.qrcode.com/en/about/error_correction.html). Error correction allows us to change or replace a part of QR Code. With the help of this feature we will replace a certain part with our logo. 

We will create a new function inside CIImage extention. This function will takes our logo and return CIImage. This would be the final image of QR Code. Basically it is the combination of our logo and QR Code. 

```
func addLogo(with image: CIImage) -> CIImage? {
guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
combinedFilter.setValue(self, forKey: "inputBackgroundImage")
return combinedFilter.outputImage!
}
```

and that's it, we have successfully customized our QR Code with our logo and color.

#### A Playground
A complete version of this code can be found on [Github](https://github.com/iamsonumalik/CustomQRCodeGenrator) here. It’s a Playground to allow you to play around and create your own custom QR code.


