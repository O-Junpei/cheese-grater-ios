import UIKit

final class CheeseGraterView: UIView {
    private var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView()
        addSubview(imageView)
        stopAnimation()
    }

    override func layoutSubviews() {
        imageView.frame = self.bounds
    }

    func startAnimation() {
        imageView.removeFromSuperview()
        do {
            imageView.removeFromSuperview()
            let gif = try UIImage(gifName: "cheese.gif")
            imageView = UIImageView(gifImage: gif, loopCount: -1)
            imageView.frame = bounds
            addSubview(imageView)
        } catch {
            print(error)
        }
    }

    func stopAnimation() {
        imageView.removeFromSuperview()
        imageView = UIImageView(image: UIImage(named: "cheese-off"))
        imageView.frame = bounds
        addSubview(imageView)
    }
}
