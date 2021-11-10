//
//

import UIKit
import Cosmos

protocol MediaActionsViewDelegate: class {
    func actionsViewDidSelectLikeButton(_ actionsView: MediaActionsView)
    func actionsViewDidSelectDislikeButton(_ actionsView: MediaActionsView)
    func actionsViewDidSelectPlayButton(_ actionsView: MediaActionsView)
}

class MediaActionsView: UIView {

    weak var delegate: MediaActionsViewDelegate?
    
    private static let titleLabelFont = UIFont(name: "Nunito-Black", size: 22)!
    private static let titleLabelTop: CGFloat = 140.0
    private static let titleLabelLeading: CGFloat = 67.0
    private static let titleLabelTrailing: CGFloat = 67.0
    @IBOutlet weak var ratingView: CosmosView!
    
    static let playButtonSize: CGFloat = 74.0
    
    // MARK: - Outlets -

    @IBOutlet weak var playImageView: UIImageView!
    
    @IBOutlet private weak var playButton: UIButton! {
        didSet {
            playButton.layer.cornerRadius = playButton.frame.width / 2
            playButton.dropShadow(color: .black, radius: 6.0, opacity: 0.3, offset: .zero, grazingCornerRadius: true)
        }
    }
    
    @IBOutlet private weak var addButton: UIButton! {
        didSet {
            addButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        }
    }
    
    @IBOutlet private weak var downloadButton: UIButton! {
        didSet {
            downloadButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = MediaActionsView.titleLabelFont
        }
    }
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint! {
        didSet {
            titleLabelTopConstraint.constant = MediaActionsView.titleLabelTop
        }
    }
    
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint! {
        didSet {
            titleLabelLeadingConstraint.constant = MediaActionsView.titleLabelLeading
        }
    }
    
    @IBOutlet weak var titleLabelTrailingConstraint: NSLayoutConstraint! {
        didSet {
            titleLabelTrailingConstraint.constant = MediaActionsView.titleLabelTrailing
        }
    }
    
    @IBOutlet weak var playButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playButtonWidthConstraint: NSLayoutConstraint! {
        didSet {
            playButtonWidthConstraint.constant = MediaActionsView.playButtonSize
        }
    }
    
    @IBOutlet weak var playButtonHeightConstraint: NSLayoutConstraint! {
        didSet {
            playButtonHeightConstraint.constant = MediaActionsView.playButtonSize
        }
    }
    
    class func cellHeightForTitle(_ title: String, width: CGFloat) -> CGFloat {
        let titleWidth = width - titleLabelLeading - titleLabelTrailing
        return title.height(withConstrainedWidth: titleWidth, font: MediaActionsView.titleLabelFont) + titleLabelTop
    }
    
    // MARK: - Actions -
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.actionsViewDidSelectDislikeButton(self)
    }
    
    @IBAction func dislikeButtonClicked(_ sender: UIButton) {
        delegate?.actionsViewDidSelectDislikeButton(self)
    }
    @IBAction func PlayButttonClicked(_ sender: Any) {
        delegate?.actionsViewDidSelectPlayButton(self)
    }
}
