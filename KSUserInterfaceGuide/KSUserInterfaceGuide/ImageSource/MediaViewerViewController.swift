//
//  MediaViewerViewController.swift
//  KSUserInterfaceGuide
//
//  Created by kinsun on 2023/2/8.
//

import UIKit
import KSUserInterface
import Photos

open class MediaViewerViewController: KSMediaViewerController<AnyObject, MediaViewerViewController.View, KSMediaViewerCell> {
    
    open override func loadView() {
        super.loadView()
        guard let nav = view.navigationView else { return }
        nav.style = .dark
        nav.isHiddenLine = true
        nav.backgroundColor = UIColor(hex: 0x000000, alpha: 0.5)
    }

    open override func loadMediaViewerView() -> View {
        let view = View(frame: .zero, navigationView: KSSecondaryNavigationView())
        if let collectionView = view.collectionView {
            collectionView.register(PictureCell.self, forCellWithReuseIdentifier: PictureCell.Iden)
            collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.Iden)
        }
        return view
    }
    
    open override func mediaViewerCell(at indexPath: IndexPath, data: AnyObject, of collectionView: UICollectionView) -> KSMediaViewerCell {
        if (data as? KSImagePickerItemModel)?.asset.mediaType == .video {
            return collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.Iden, for: indexPath) as! KSMediaViewerCell
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: PictureCell.Iden, for: indexPath) as! KSMediaViewerCell
        }
    }
    
    open override func setDataArray(_ dataArray: [AnyObject], currentIndex: Int) {
        super.setDataArray(dataArray, currentIndex: currentIndex)
        view.pageControl.numberOfPages = dataArray.count
    }
    
//    open override var currentCell: KSMediaViewerCell {
//        didSet {
//            guard oldValue != currentCell else { return }
//            ((oldValue as? VideoCell)?.mainView as? KSVideoPlayerLiteView)?.pause()
//
//        }
//    }
    
    open override func didClickViewCurrentItem() {
        view.isFullScreen = !view.isFullScreen
    }
    
    open override func mediaViewerCellWillBeganPan() {
        super.mediaViewerCellWillBeganPan()
        view.isFullScreen = true
    }
    
    open override func currentIndexDidChanged(_ currentIndex: Int) {
        super.currentIndexDidChanged(currentIndex)
        title = "\(currentIndex+1)/\(dataArray.count)"
    }
    
    open var getThumbCallback: ((Int) -> UIImage?)?
    
    open override var currentThumb: UIImage? {
        getThumbCallback?(currentIndex)
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        view.pageControl.update(with: scrollView)
    }

}

extension MediaViewerViewController {
    
    open class View: KSMediaViewerView {
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let pageControl = KSPageControl()
        
        public override init(frame: CGRect, navigationView: KSSecondaryNavigationView) {
            super.init(frame: frame, navigationView: navigationView)
            pageControl.tintColor = .ks_white
            addSubview(pageControl)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            pageControl.frame = CGRect(x: 15.0, y: windowSize.height-6.0-safeAreaInsets.bottom, width: windowSize.width-30.0, height: 6.0)
        }
        
        private lazy var _animation: CATransition = {
            let trans = CATransition()
            trans.duration = 0.3
            trans.type = .push
            return trans
        }()
        
        open var isFullScreen = false {
            didSet {
                guard isFullScreen != oldValue, let navigationView = navigationView else { return }
                navigationView.isHidden = isFullScreen
                _animation.subtype = isFullScreen ? .fromTop : .fromBottom
                navigationView.layer.add(_animation, forKey: nil)
            }
        }
        
    }
    
    private static let _options: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.resizeMode = .none
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        return options
    }()
    
    open class PictureCell: KSMediaViewerCell {
        
        public static let Iden = "MediaViewerViewController.PictureCell"
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            let imageView = KSImageView()
            scrollView?.addSubview(imageView)
            mainView = imageView
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            guard let imageView = mainView as? KSImageView else { return }
            _settingImageViewFrame(image: imageView.image)
        }
        
        open override var data: Any? {
            didSet {
                guard let imageView = mainView as? KSImageView, let model = data as? KSImagePickerItemModel else { return }
                PHImageManager.default().requestImage(for: model.asset, targetSize: bounds.size, contentMode: .aspectFill, options: MediaViewerViewController._options) { [weak self, weak imageView] image, _ in
                    self?._settingImageViewFrame(image: image)
                    imageView?.image = image
                }
            }
        }
        
        private func _settingImageViewFrame(image: UIImage?) {
            guard let image = image,
                let scrollView = scrollView,
                let imageView = mainView else { return }
            
            let windowSize = scrollView.bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let size = image.size
            let viewW = windowWidth
            var viewH = floor(size.height/size.width*viewW)
            if viewH < windowHeight {
                viewH = windowHeight
                imageView.contentMode = .scaleAspectFit
            } else {
                imageView.contentMode = .scaleToFill
            }
            imageView.frame = CGRect(origin: .zero, size: CGSize(width: viewW, height: viewH))
            scrollView.contentSize = imageView.bounds.size
        }
        
        open var image: UIImage? {
            (mainView as? KSImageView)?.image
        }
        
        open override var mainViewFrameInSuperView: CGRect {
            guard let scrollView = scrollView,
                  let image = (mainView as? KSImageView)?.image else { return .zero }
            return KSMediaViewerController<NSURL, View, KSMediaViewerCell>.transitionThumbViewFrame(inSuperView: scrollView, at: image)
        }
        
    }
    
    open class VideoCell: KSMediaViewerCell {
        
        public static let Iden = "MediaViewerViewController.VideoCell"
        
        private static let _options: PHVideoRequestOptions = {
            let options = PHVideoRequestOptions()
            options.version = .current
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = true
            return options
        }()
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            scrollView?.maximumZoomScale = 1.0
            let player = KSVideoPlayerLiteView()
            player.coverView?.contentMode = .scaleAspectFit
            player.videoPlaybackFinished = { [weak self] in
                (self?.mainView as? KSVideoPlayerLiteView)?.play()
            }
            scrollView?.addSubview(player)
            mainView = player
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            guard let mainView = mainView, let scrollView = scrollView else { return }
            mainView.frame = scrollView.bounds
        }
        
        open override var data: Any? {
            didSet {
                guard let player = mainView as? KSVideoPlayerLiteView else { return }
                guard let model = data as? KSImagePickerItemModel else {
                    player.pause()
                    return
                }
                let asset = model.asset
                let mgr = PHImageManager.default()
                mgr.requestImage(for: asset, targetSize: bounds.size, contentMode: .aspectFill, options: MediaViewerViewController._options) { [weak player] image, _ in
                    player?.coverView?.image = image
                }
                mgr.requestAVAsset(forVideo: asset, options: Self._options) { [weak player] asset, _, _ in
                    guard let asset = asset else { return }
                    DispatchQueue.main.async {
                        player?.playerItem = AVPlayerItem(asset: asset)
                        player?.play()
                    }
                }
            }
        }
        
        open var image: UIImage? {
            (mainView as? KSVideoPlayerLiteView)?.coverView?.image
        }
        
        open override var mainViewFrameInSuperView: CGRect {
            guard let scrollView = scrollView,
                  let image = (mainView as? KSImageView)?.image else { return .zero }
            return KSMediaViewerController<NSURL, View, KSMediaViewerCell>.transitionThumbViewFrame(inSuperView: scrollView, at: image)
        }
        
    }
    
}
