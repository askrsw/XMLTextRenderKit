//
//  XMLImageViewsCell.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/28.
//

import UIKit

final class XMLImageViewsCell: XMLViewCellBase {
    private var imgViewArray: Array<UIImageView> = []
    private var labelArray: Array<UILabel> = []

    private var textData: XMLElementImages?

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var element: XMLElementBase? {
        didSet {
            guard let element = element as? XMLElementImages else {
                let errMsg = "Wrong brief type for BriefImageViewCell."
                print(errMsg)
                return
            }

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            textData = element

            imgViewArray.forEach({ $0.removeFromSuperview() })
            imgViewArray.removeAll()
            labelArray.forEach({ $0.removeFromSuperview() })
            labelArray.removeAll()

            for meta in element.imageMetas {
                let imgView = UIImageView(frame: meta.imgFrame)
                imgView.image = meta.image
                imgView.contentMode = .scaleAspectFit
                imgView.layer.cornerRadius = 12
                imgView.clipsToBounds = true
                contentView.addSubview(imgView)
                imgViewArray.append(imgView)

                if let title = meta.title, let frame = meta.titleFrame {
                    let label = UILabel(frame: frame)
                    label.text = title
                    label.textAlignment = .center
                    contentView.addSubview(label)
                    labelArray.append(label)
                }
            }

        }
    }
}
