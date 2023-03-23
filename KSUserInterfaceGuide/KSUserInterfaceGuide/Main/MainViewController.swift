//
//  MainViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/7/22.
//

import UIKit
import KSUserInterface

open class MainViewController: KSSystemStyleViewControllerDefault, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var _tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(_Cell.self, forCellReuseIdentifier: _Cell.Iden)
        tableView.rowHeight = 64.0
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    open override func loadView() {
        super.loadView()
        let view = self.view
        view.addSubview(_tableView)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSUserInterfaceGuide"
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let view = view
        _tableView.frame = view.bounds
        let inset = UIEdgeInsets(top: view.navigationView?.frame.maxY ?? 0.0, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        _tableView.contentInset = inset
        _tableView.scrollIndicatorInsets = inset
    }
    
    private lazy var _list = _Model.List
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _Cell.Iden, for: indexPath) as! _Cell
        cell.model = _list[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = (tableView.cellForRow(at: indexPath) as? _Cell)?.model {
            model.response?(model, self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension MainViewController {
    
    private struct _Model {
        
        public let title: String
        public let response: ((_Model, UIViewController) -> Void)?
        
        public init(title: String, response: ((_Model, UIViewController) -> Void)? = nil) {
            self.title = title
            self.response = response
        }
        
        public static var List: [Self] {
            [_Model(title: "KSBannerView", response: {
                $1.push(BannerViewController())
            }), _Model(title: "KSButton", response: {
                $1.push(ButtonViewController())
            }), _Model(title: "KSDialogView", response: {
                $1.push(DialogViewController())
            }), _Model(title: "KSAlertGuide", response: {
                $1.push(AlertGuideViewController())
            }), _Model(title: "KSImageSource", response: {
                $1.push(ImageSourceViewController())
            }), _Model(title: "KSImageView", response: {
                $1.push(ImageViewController())
            }), _Model(title: "KSViewPager", response: {
                $1.push(ViewPagerViewController())
            })]
        }
    }
    
    private class _Cell: UITableViewCell {
        
        public static let Iden = "MainViewController._Cell"
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = .boldSystemFont(ofSize: 18.0)
            titleLabel.textColor = .ks_black
            return titleLabel
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            accessoryType = .disclosureIndicator
            contentView.addSubview(_titleLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = contentView.bounds.size
            _titleLabel.frame = CGRect(x: 16.0, y: 0.0, width: windowSize.width-22.0, height: windowSize.height)
        }
        
        open var model: _Model? {
            didSet {
                _titleLabel.text = model?.title
            }
        }
        
    }
    
}
