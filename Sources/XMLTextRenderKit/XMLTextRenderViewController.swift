//
//  XMLTextRenderViewController.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit

final public class XMLTextRenderViewController: UIViewController {
    var mappedTableViewCell: [String: XMLViewCellBase.Type] {
        [
            NSStringFromClass(XMLElementTitle.self): XMLTitleViewCell.self,
            NSStringFromClass(XMLElementParagraph.self): XMLParagraphViewCell.self,
            NSStringFromClass(XMLElementList.self): XMLListViewCell.self,
            NSStringFromClass(XMLElementFooter.self): XMLFooterViewCell.self,
            NSStringFromClass(XMLElementImages.self): XMLImageViewsCell.self
        ]
    }

    let tableView = UITableView(frame: .zero, style: .grouped)
    private(set) var xmlParser: XMLFileParser?
    private(set) var contentElements: [XMLElementBase] = []

    private var isPortrait = true

    let showCloseButton: Bool
    let mainTitle: String
    let xmlUrl: URL

    let largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode

    let startAction: (() -> Void)?
    let endAction: (()->Void)?

    public init(xmlUrl: URL, mainTitle: String, showCloseButton: Bool = false, config: XMLRenderConfig?, largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .never, startAction: (() -> Void)? = nil, endAction: (() -> Void)? = nil) {
        self.mainTitle = mainTitle
        self.showCloseButton = showCloseButton
        self.xmlUrl = xmlUrl
        self.startAction = startAction
        self.endAction = endAction
        self.largeTitleDisplayMode = largeTitleDisplayMode
        super.init(nibName: nil, bundle: nil)

        if let config = config {
            XMLRenderConfig.shared = config
        }

        startAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        endAction?()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = mainTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = largeTitleDisplayMode

        if showCloseButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"), landscapeImagePhone: UIImage(systemName: "xmark.circle"), style: .plain, target: self, action: #selector(closeAction(_:)))
        }
        navigationItem.leftBarButtonItem?.tintColor = XMLRenderConfig.shared.mainColor

        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        isPortrait = XMLRenderConfig.shared.isPortrait

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 44.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        loadXML()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        contentElements.forEach { $0.clearAttributedString() }
        tableView.reloadData()
    }
}

extension XMLTextRenderViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentElements.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = contentElements[indexPath.row]
        let cellId = element.className
        let cell = { () -> XMLViewCellBase in
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) {
                return cell as! XMLViewCellBase
            } else {
                guard let cellClass = mappedTableViewCell[cellId] else {
                    let errMsg = "Cannot map brief name: \(cellId) to an instance of BriefViewCellBase."
                    print(errMsg)
                    fatalError(errMsg)
                }

                return cellClass.init(reuseIdentifier: cellId)
            }
        } ()

        element.viewWidth = tableView.width
        cell.element = element
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let element = contentElements[indexPath.row]
        element.viewWidth = tableView.width
        return element.cellHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
}

extension XMLTextRenderViewController {
    @objc
    private func closeAction(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }

    @objc
    private func deviceOrientationChanged(_ notif: Notification) {
        let mode = XMLRenderConfig.shared.isPortrait
        if isPortrait != mode {
            isPortrait = mode
            contentElements.forEach { $0.clearAttributedString() }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func loadXML() {
        let url = self.xmlUrl
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let content = String(data: data, encoding: .utf8) {
                self.xmlParser = XMLFileParser(content: content)
                let sections = self.xmlParser!.contentSections
                self.contentElements.removeAll()
                for s in sections {
                    self.contentElements.append(contentsOf: s.flattenContents)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
