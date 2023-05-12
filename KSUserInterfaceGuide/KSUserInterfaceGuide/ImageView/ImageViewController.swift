//
//  ImageViewController.swift
//  KSUserInterfaceGuide
//
//  Created by kinsun on 2023/3/20.
//

import UIKit
import KSUserInterface

open class ImageViewController: KSSecondaryViewControllerDefault, UICollectionViewDelegate, UICollectionViewDataSource, KSScrollViewDelegate {

    private lazy var _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        layout.minimumLineSpacing = 15.0
        layout.minimumInteritemSpacing = 15.0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.loadStyle = .all
        collectionView.register(_Cell.self, forCellWithReuseIdentifier: _Cell.Iden)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    open override func loadView() {
        super.loadView()
        let view = self.view
        if let nav = view.navigationView {
            let rightButton = KSTextButton()
            if let label = rightButton.contentView {
                label.font = .systemFont(ofSize: 15.0)
                label.textColor = UIColor(hex: 0xACACC6)
            }
            rightButton.normalTitle = "清除图像缓存"
            rightButton.contentInset = UIEdgeInsets(top: 15.0, left: 14.0, bottom: 15.0, right: 15.0)
            rightButton.add(.touchUpInside) { [weak self] _ in
                KSImageView.calculateSize() {
                    guard let self = self else { return }
                    let alert = SystemAlertViewController(title: "确定要清除所有图像缓存吗？", strongMessage: "当前缓存为\(KSImageView.string(withSize: $1))")
                    let ok = SystemAlertViewController.Button.Ok
                    alert.didClickButtonCallback = { [weak ok] in
                        if $1 == ok {
                            $0.dismiss(animated: true) {
                                KSImageView.clearMemory()
                                KSImageView.clearDisk() {
                                    KSToastShowMessage("已清除全部图片缓存")
                                }
                            }
                        } else {
                            $0.dismiss(animated: true)
                        }
                    }
                    alert.add(button: .Cancel)
                    alert.add(button: ok)
                    self.present(alert, animated: true)
                }
            }
            nav.addRightView(rightButton)
        }
        view.addSubview(_collectionView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds
        _collectionView.frame = bounds
        if let layout = _collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset = layout.sectionInset
            let itemW = floor((bounds.size.width-sectionInset.left-sectionInset.right-layout.minimumInteritemSpacing*2.0)/3.0)
            let itemH = floor(itemW*1.356)
            layout.itemSize = CGSize(width: itemW, height: itemH)
        }
        var safeAera = view.safeAreaInsets
        if let top = view.navigationView?.frame.maxY {
            safeAera.top = top
        }
        _collectionView.contentInset = safeAera
        _collectionView.scrollIndicatorInsets = safeAera
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSImageView"
        _collectionView.launchRefresh()
    }
    
    private var _list: [String]?
    private var _flag = false
    
    private func _requestData(isLoadMore: Bool) {
        /// 模拟网路请求
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) { [weak self] in
            guard let self = self else { return }
            let flag = self._flag
            let list: [String]? = flag ? ["08aa907fb4719e42cc06b9b5c1fa7645", "127a2702b644acbd9ac9c335505ca2a3", "901e25100724a5a70b8f817169f587ea", "775b010736a86d609ce564774b550ef0", "cb78e368d7f476047ada313ad112fc89", "cbfb2e0731949fb853f1da2376237f66", "373927c03c93aaf8e6a4c080c23fe62a", "626c5677761c341737eb1a62b2ecaa21", "cc66fd00f2362bf5c6142afefefb4316", "4665217ef0246b56e08b4038ad88bb06", "2d5cad2a2a3814dc083a8e63221a357b", "e3ffc146eaebe1a16df395cea39e9ed7", "32de9e8048486f2bf2334ff3fa7aae27", "2b20eb6fd3088026f18e15392c8f6d55", "7db1fd436945d0b56f0aa6157ed20bce", "f04905c69510a390bd795b1f8a0272c4", "6a67d95038a2a5c95d38586a4118e3a2", "ffe49c4ae000c56017eb5537d1d8f845", "4ee6edf039eb2598dc1573e7ae5a3c78", "e92fece436d7ca3c4c456f2da52805e3", "e2bc08b3e411490f6c6c41b5d2d75ae7", "702903c9a44b3b80cf5a4ac02861cffc", "60b284aa780bd6e0e8cda0001a1cc296"].map { "https://ad-static-xg.tagtic.cn/ad-material/file/\($0).png" } : nil
            self._flag = !flag
            self._requestDataAfter(isLoadMore: isLoadMore, data: list)
        }
    }
    
    private func _requestDataAfter(isLoadMore: Bool, data: [String]?) {
        if isLoadMore {
            defer {
                _collectionView.finishLoadMore()
            }
            guard let data = data else { return }
            if let list = _list {
                let count = list.count
                let indexPaths = (0..<data.count).map { IndexPath(item: $0+count, section: 0) }
                _list = list+data
                _collectionView.insertItems(at: indexPaths)
            } else {
                _list = data
                _collectionView.reloadData()
            }
        } else {
            defer {
                _collectionView.reloadData()
                _collectionView.finishRefresh()
            }
            guard let data = data else {
//                view.loadingView?.status = .loadFailure
                _collectionView.loadingView.status = .loadFailure
                _list = nil
                return
            }
            _collectionView.loadingView.status = .none
            _list = data
        }
    }
    
    public func scrollViewDidBeginRefresh(_ scrollView: UIScrollView) {
        _requestData(isLoadMore: false)
    }
    
    public func scrollViewDidLoadMoreData(_ scrollView: UIScrollView) {
        _requestData(isLoadMore: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _list?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _Cell.Iden, for: indexPath) as! _Cell
        cell.imageURLString = _list?[indexPath.item]
        return cell
    }
    
//    open override func didClick(_ loadingView: KSLoadingView) {
//        loadingView.status = .none
//        _collectionView.launchRefresh()
//    }

}

extension ImageViewController {
    
    private class _Cell: UICollectionViewCell {
        
        public static let Iden = "ImageViewController._Cell"
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView: KSImageView = {
            let imageView = KSImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            /// 开启后只有手指离开了屏幕并且滑动停止了才会真正的发起网络请求加载图片资源
            /// 从而减少用户在快速滑动过程中的网络请求
            imageView.isDeferredTask = true
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(_imageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _imageView.frame = contentView.bounds
        }
        
        open var imageURLString: String? {
            didSet {
                guard imageURLString != oldValue else { return }
                if let imageURLString = imageURLString {
                    _imageView.setImageURLString(imageURLString)
                } else {
                    _imageView.image = nil
                }
            }
        }
        
    }
 
}
