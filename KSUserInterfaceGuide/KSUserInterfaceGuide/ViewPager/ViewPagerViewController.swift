//
//  ViewPagerViewController.swift
//  KSUserInterfaceGuide
//
//  Created by kinsun on 2023/3/21.
//

import UIKit
import KSUserInterface

/// 这是一个可以多个scrollView共用一个header的控件，还可以控制header停留，变换等等，使用起来很简单，满足类似需求
open class ViewPagerViewController: KSSecondaryViewControllerDefault, KSViewPagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private lazy var _scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 0.0, height: 800.0)
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var _videoListView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12.0, left: 2.0, bottom: 12.0, right: 2.0)
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hex: 0x161823)
        collectionView.register(_Cell.self, forCellWithReuseIdentifier: _Cell.Iden)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var _viewPager: KSViewPager = {
        let header = _Header()
        header.segmentedControl.didClickItem = { [weak self] in
            self?._viewPager.setCurrentPage($1, animated: true)
        }
        let viewPager = KSViewPager(scrollViews: [_videoListView, _scrollView], mode: .viewHeight)
        viewPager.headerTabHeight = 36.0
        viewPager.headerView = header
        viewPager.delegate = self
        return viewPager
    }()

    open override func loadView() {
        super.loadView()
        if let nav = view.navigationView {
            nav.setBackButtonColor(.ks_black, for: .clear)
            nav.setBackgroundColor(UIColor(hex: 0x161823), for: .dark)
            nav.setTitleColor(.clear, for: .clear)
            nav.style = .clear
        }
        view.addSubview(_viewPager)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "抖音小助手"
    }
    
    private lazy var _navAnimation: CAAnimation = {
        let animation = CATransition()
        animation.type = .fade
        return animation
    }()
    
    private var _isHiddenNavBar = true {
        didSet {
            guard _isHiddenNavBar != oldValue, let nav = view.navigationView else { return }
            nav.style = _isHiddenNavBar ? .clear : .dark
            nav.layer.add(_navAnimation, forKey: nil)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds
        if let layout = _videoListView.collectionViewLayout as? UICollectionViewFlowLayout {
            let inset = layout.sectionInset
            let w = floor((bounds.size.width-inset.left-inset.right-layout.minimumInteritemSpacing*2.0)/3.0)
            let h = floor(w*1.333)
            layout.itemSize = CGSize(width: w, height: h)
        }
        var inset = view.safeAreaInsets
        let navHeight = view.navigationView?.frame.maxY ?? inset.top
        _viewPager.headerHeight = _viewPager.headerView.sizeThatFits(bounds.size).height-navHeight
        _viewPager.navHeight = navHeight
        inset.top = 0.0
        _viewPager.contentInset = inset
        _viewPager.frame = bounds
    }
    
    public func viewPager(_ viewPager: KSViewPager, scrollViewDidScroll scrollView: UIScrollView) {
        guard let segmentedControl = (viewPager.headerView as? _Header)?.segmentedControl else { return }
        let windowWidth = scrollView.bounds.width
        let offsetX = scrollView.contentOffset.x
        segmentedControl.updateIndicatorProportion(offsetX/windowWidth)
    }
    
    public func viewPager(_ viewPager: KSViewPager, currentPageDidChange page: UInt) {
        (viewPager.headerView as? _Header)?.segmentedControl.selectedSegmentIndex = page
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize != .zero, (scrollView == _videoListView && _viewPager.currentPage == 0) || (scrollView == _scrollView && _viewPager.currentPage == 1)else { return }
        _isHiddenNavBar = scrollView.contentOffset.y+scrollView.contentInset.top < _viewPager.navHeight
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// ⚠️⚠️⚠️⚠️⚠️⚠️一定要写这句，不然会出现问题
        _viewPager.updateScrollView(scrollView, targetContentOffset: targetContentOffset.pointee)
    }
    
    private lazy var _data = ItemModel.List
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _Cell.Iden, for: indexPath) as! _Cell
        cell.model = _data[indexPath.item]
        return cell
    }

}

extension ViewPagerViewController {
    
    fileprivate class _Header: UIView {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "img_viewpager_top_bg.png"))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        private let _iconView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "img_viewpager_user_icon.jpg"))
            imageView.contentMode = .scaleAspectFill
            let layer = imageView.layer
            layer.cornerRadius = 38.0
            layer.masksToBounds = true
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.ks_white.cgColor
            return imageView
        }()
        
        private let _userLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 4.0
            let string = NSMutableAttributedString(string: "抖音小助手\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 22.0), .foregroundColor: UIColor.ks_white, .paragraphStyle: paragraphStyle])
            if let image = UIImage(named: "icon_viewpager_certification") {
                let attachment = NSTextAttachment()
                attachment.image = image
                attachment.bounds = CGRect(x: 0.0, y: -2.5, width: 13.0, height: 13.0)
                string.append(NSAttributedString(attachment: attachment))
            }
            string.append(NSAttributedString(string: " 抖音短视频官方账号", attributes: [.font: UIFont.systemFont(ofSize: 11.0), .foregroundColor: UIColor.ks_white, .paragraphStyle: paragraphStyle]))
            label.attributedText = string
            return label
        }()
        
        private let _bottom = Bottom()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            addSubview(_imageView)
            addSubview(_iconView)
            addSubview(_userLabel)
            addSubview(_bottom)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let bottomSize = _bottom.sizeThatFits(windowSize)
            _bottom.frame = CGRect(origin: CGPoint(x: 0.0, y: windowHeight-bottomSize.height), size: bottomSize)
            let w = CGFloat(76.0)
            let y = _bottom.frame.minY-w-15.0
            _iconView.frame = CGRect(x: 15.0, y: y, width: w, height: w)
            let x = _iconView.frame.maxX+15.0
            _userLabel.frame = CGRect(x: x, y: y, width: windowWidth-x-15.0, height: w)
            _imageView.frame = CGRect(origin: .zero, size: CGSize(width: windowWidth, height: max(_bottom.frame.minY+15.0, floor(windowWidth*0.6))))
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let width = size.width
            return CGSize(width: width, height: floor(width*0.6)+_bottom.sizeThatFits(size).height-15.0)
        }
        
        open var segmentedControl: KSSegmentedControl {
            _bottom.segmentedControl
        }
        
    }
    
    private class _Cell: UICollectionViewCell {
        
        public static let Iden = "ViewPagerViewController._Cell"
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView: KSImageView = {
            let imageView = KSImageView()
            imageView.backgroundColor = .ks_white
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.isTailOfQueue = true
            return imageView
        }()
        
        private let _tagLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 11.0)
            label.textAlignment = .center
            let layer = label.layer
            layer.cornerRadius = 2.0
            layer.masksToBounds = true
            return label
        }()
        
        private let _pictureIcon: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "icon_viewpager_many"))
            imageView.contentMode = .center
            return imageView
        }()
        
        private let _likeIcon: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "icon_viewpager_like"))
            imageView.contentMode = .center
            return imageView
        }()
        
        private let _likeCountLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 11.0)
            label.textColor = .ks_white
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            let contentView = self.contentView
            contentView.addSubview(_imageView)
            contentView.addSubview(_tagLabel)
            contentView.addSubview(_pictureIcon)
            contentView.addSubview(_likeIcon)
            contentView.addSubview(_likeCountLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let bounds = contentView.bounds
            _imageView.frame = bounds
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            if !_tagLabel.isHidden {
                let size = _tagLabel.sizeThatFits(windowSize)
                _tagLabel.frame = CGRect(x: 10.0, y: 10.0, width: size.width+10.0, height: size.height+10.0)
            }
            if !_pictureIcon.isHidden {
                _pictureIcon.frame = CGRect(x: windowWidth-52.0, y: 0.0, width: 52.0, height: 54.0)
            }
            let h = CGFloat(25.0)
            let y = windowSize.height-h
            _likeIcon.frame = CGRect(x: 6.0, y: y, width: 24.0, height: h)
            let x = _likeIcon.frame.maxX
            _likeCountLabel.frame = CGRect(x: x, y: y, width: windowWidth-x-10.0, height: h)
        }
        
        open var model: ItemModel? {
            didSet {
                guard let model = model else {
                    _tagLabel.isHidden = true
                    _imageView.image = nil
                    _pictureIcon.isHidden = true
                    _likeCountLabel.text = "0"
                    return
                }
                if let tag = model.tag {
                    _tagLabel.text = tag.title
                    _tagLabel.textColor = UIColor(hex: tag.textColor)
                    _tagLabel.backgroundColor = UIColor(alphaHex: tag.bgColor)
                    _tagLabel.isHidden = false
                } else {
                    _tagLabel.isHidden = true
                }
                _pictureIcon.isHidden = !model.isPicture
                _likeCountLabel.text = model.likeCountString
                if let url = model.imageURL {
                    _imageView.setImageURL(url)
                } else {
                    _imageView.image = nil
                }
            }
        }
        
    }
    
    open class ItemModel {
        
        public let tag: (title: String, textColor: UInt, bgColor: UInt)?
        public let isPicture: Bool
        public let imageURL: URL?
        public let likeCount: Int
        open private(set) lazy var likeCountString: String = {
            if likeCount >= 10000 {
                return "\(Double(likeCount)/10000.0)万"
            }
            return String(likeCount)
        }()
        
        public required init(tag: (title: String, textColor: UInt, bgColor: UInt)? = nil, isPicture: Bool = false, image: String, likeCount: Int) {
            self.tag = tag
            self.isPicture = isPicture
            self.imageURL = URL(string: "https://ad-static-xg.tagtic.cn/ad-material/file/\(image).png")
            self.likeCount = likeCount
        }
        
        public static var List: [ItemModel] {
            let top = ItemModel(tag: ("置顶", 0x000000, 0xFFFACE15), isPicture: true, image: "08aa907fb4719e42cc06b9b5c1fa7645", likeCount: 46000)
            let togeter = ItemModel(tag: ("共创", 0xFFFFFF, 0x80000000), image: "775b010736a86d609ce564774b550ef0", likeCount: 6000)
            var r = ["127a2702b644acbd9ac9c335505ca2a3", "901e25100724a5a70b8f817169f587ea", "cb78e368d7f476047ada313ad112fc89", "cbfb2e0731949fb853f1da2376237f66", "373927c03c93aaf8e6a4c080c23fe62a", "626c5677761c341737eb1a62b2ecaa21", "cc66fd00f2362bf5c6142afefefb4316", "4665217ef0246b56e08b4038ad88bb06", "2d5cad2a2a3814dc083a8e63221a357b", "e3ffc146eaebe1a16df395cea39e9ed7", "32de9e8048486f2bf2334ff3fa7aae27", "2b20eb6fd3088026f18e15392c8f6d55", "7db1fd436945d0b56f0aa6157ed20bce", "f04905c69510a390bd795b1f8a0272c4", "6a67d95038a2a5c95d38586a4118e3a2", "ffe49c4ae000c56017eb5537d1d8f845", "4ee6edf039eb2598dc1573e7ae5a3c78", "e92fece436d7ca3c4c456f2da52805e3", "e2bc08b3e411490f6c6c41b5d2d75ae7", "702903c9a44b3b80cf5a4ac02861cffc", "60b284aa780bd6e0e8cda0001a1cc296"].map {
                ItemModel(image: $0, likeCount: Int.random(in: 299...100000))
            }
            r.insert(top, at: 0)
            r.insert(togeter, at: 3)
            return r
        }
        
    }
    
}

extension ViewPagerViewController._Header {
    
    public class Bottom: UIView {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _numbersLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 20.0
            let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor(hex: 0x8B8C91), .paragraphStyle: paragraphStyle]
            let highlightedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18.0), .foregroundColor: UIColor.ks_white, .paragraphStyle: paragraphStyle]
            let string = NSMutableAttributedString(string: "1.9亿", attributes: highlightedAttributes)
            string.append(NSAttributedString(string: " 获赞    ", attributes: normalAttributes))
            string.append(NSAttributedString(string: "9", attributes: highlightedAttributes))
            string.append(NSAttributedString(string: " 关注    ", attributes: normalAttributes))
            string.append(NSAttributedString(string: "5158.2万", attributes: highlightedAttributes))
            string.append(NSAttributedString(string: " 粉丝", attributes: normalAttributes))
            string.append(NSAttributedString(string: "\n本宝宝暂时还没想到个性签名", attributes: [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor.ks_white, .paragraphStyle: paragraphStyle]))
            label.attributedText = string
            return label
        }()
        
        private let _ipLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12.0)
            label.textAlignment = .center
            label.textColor = .ks_white
            label.backgroundColor = UIColor(hex: 0x393A44)
            label.text = "IP: 北京"
            let layer = label.layer
            layer.cornerRadius = 2.0
            layer.masksToBounds = true
            return label
        }()
        
        private let _liveIconView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "icon_viewpager_tv"))
            imageView.contentMode = .center
            imageView.backgroundColor = UIColor(hex: 0x242630)
            let layer = imageView.layer
            layer.cornerRadius = 6.0
            layer.masksToBounds = true
            return imageView
        }()
        
        private let _liveLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 7.0
            let string = NSMutableAttributedString(string: "直播动态\n", attributes: [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor.ks_white, .paragraphStyle: paragraphStyle])
            string.append(NSAttributedString(string: "查看历史记录", attributes: [.font: UIFont.systemFont(ofSize: 11.0), .foregroundColor: UIColor(hex: 0x8B8C91), .paragraphStyle: paragraphStyle]))
            label.attributedText = string
            return label
        }()
        
        private let _hotListBgLayer: CALayer = { // 实际应为可点击的UIControl,示例无点击也就无所谓了
            let layer = CALayer()
            layer.backgroundColor = UIColor(hex: 0x242630).cgColor
            layer.cornerRadius = 2.0
            layer.masksToBounds = true
            return layer
        }()
        
        private let _hotIconView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "icon_viewpager_hot"))
            imageView.contentMode = .center
            return imageView
        }()
        
        private let _hotLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12.0)
            label.textColor = .ks_white
            label.text = "抖音热点榜"
            return label
        }()
        
        private let _hotIndicatorView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "icon_viewpager_ind"))
            imageView.contentMode = .center
            return imageView
        }()
        
        public let fllowButton: KSTextButton = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .systemFont(ofSize: 15.0)
                label.textColor = .ks_white
            }
            button.backgroundColor = UIColor(hex: 0xFE2C55)
            button.normalTitle = "关注"
            button.selectedTitle = "已关注"
            let layer = button.layer
            layer.cornerRadius = 6.0
            layer.masksToBounds = true
            return button
        }()
        
        public let chatButton: KSTextButton = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .systemFont(ofSize: 15.0)
                label.textColor = .ks_white
            }
            button.backgroundColor = UIColor(hex: 0x393A44)
            button.normalTitle = "私信"
            let layer = button.layer
            layer.cornerRadius = 6.0
            layer.masksToBounds = true
            return button
        }()
        
        public let segmentedControl: KSSegmentedControl = {
            let seg = KSSegmentedControl(frame: .zero, items: ["作品 637", "活动"])
            seg.font = .systemFont(ofSize: 15.0)
            seg.indicatorHeight = 2.0
            seg.indndicatorColor = UIColor(hex: 0xFACE15)
            seg.normalTextColor = UIColor(hex: 0x8B8C91)
            seg.selectedTextColor = .ks_white
            return seg
        }()
        
        private let _lineLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = UIColor(hex: 0x393A44).cgColor
            layer.cornerRadius = 0.5
            layer.masksToBounds = true
            return layer
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor(hex: 0x161823)
            let layer = self.layer
            layer.cornerRadius = 15.0
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            layer.masksToBounds = true
            addSubview(_numbersLabel)
            addSubview(_ipLabel)
            addSubview(_liveIconView)
            addSubview(_liveLabel)
            layer.addSublayer(_hotListBgLayer)
            addSubview(_hotIconView)
            addSubview(_hotLabel)
            addSubview(_hotIndicatorView)
            addSubview(fllowButton)
            addSubview(chatButton)
            addSubview(segmentedControl)
            layer.addSublayer(_lineLayer)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let viewX = CGFloat(15.0)
            var viewW = windowWidth-viewX*2.0
            var viewH = _numbersLabel.sizeThatFits(CGSize(width: viewW, height: windowHeight)).height
            _numbersLabel.frame = CGRect(x: viewX, y: 23.0, width: viewW, height: viewH)
            viewH = 19.0
            viewW = _ipLabel.sizeThatFits(CGSize(width: viewW-10.0, height: viewH)).width+10.0
            _ipLabel.frame = CGRect(x: viewX, y: _numbersLabel.frame.maxY+7.0, width: viewW, height: viewH)
            viewW = 38.0
            var viewY = _ipLabel.frame.maxY+18.0
            _liveIconView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewW)
            let liveLabelX = _liveIconView.frame.maxX+10.0
            _liveLabel.frame = CGRect(x: liveLabelX, y: viewY, width: windowWidth-liveLabelX-15.0, height: viewW)
            viewH = 38.0
            viewY = _liveIconView.frame.maxY+18.0
            viewW = windowWidth-viewX*2.0
            _hotListBgLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            _hotIconView.frame = CGRect(x: viewX+8.0, y: viewY, width: 32.0, height: viewH)
            _hotIndicatorView.frame = CGRect(x: _hotListBgLayer.frame.maxX-44.0, y: viewY, width: 44.0, height: viewH)
            let hotLabelX = _hotIconView.frame.maxX
            _hotLabel.frame = CGRect(x: hotLabelX, y: viewY, width: _hotIndicatorView.frame.minX-hotLabelX, height: viewH)
            viewW = floor((windowWidth-viewX*2.0-8.0)*0.5)
            var buttonFrame = CGRect(x: viewX, y: _hotListBgLayer.frame.maxY+18.0, width: viewW, height: 34.0)
            fllowButton.frame = buttonFrame
            buttonFrame.origin.x += viewW+8.0
            chatButton.frame = buttonFrame
            segmentedControl.frame = CGRect(x: 0.0, y: chatButton.frame.maxY+15.0, width: windowWidth, height: 36.0)
            _lineLayer.frame = CGRect(x: 0.0, y: windowHeight-0.5, width: windowWidth, height: 0.5)
        }
        
        public override func sizeThatFits(_ size: CGSize) -> CGSize {
            /// 321.5这个数是怎么来的呢，很简单，你跑一遍代码等完全布局了之后po一下segmentedControl.frame.maxY+_lineLayer的高度
            /// 就行了，因为布局用的都是死数字，所以不用实时计算，如你用的是活的就要计算。
            CGSize(width: size.width, height: 321.5)
        }
        
    }
    
}
