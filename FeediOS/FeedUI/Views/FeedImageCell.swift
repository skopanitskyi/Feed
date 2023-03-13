//
//  FeedImageCell.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 10.03.2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    
    public var onRetryAction: (() -> Void)?
    
    public let locationContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    public let feedImageContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    public let feedImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    public let locationLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public let retryButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        retryButton.addTarget(self, action: #selector(didTapOnRetryButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        retryButton.addTarget(self, action: #selector(didTapOnRetryButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapOnRetryButton() {
        onRetryAction?()
    }
}
