//
//  MovieDetailViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import UIKit
import Nuke
import UICircularProgressRing
import ACAnimator

class MovieDetailViewController: UIViewController, MultiCollectionViewDelegate, MediaActionsViewDelegate {
    var movieData: MovieWithGenres!
    @IBOutlet private weak var topGradientView: GradientView!
    @IBOutlet private weak var heroImageView: ShadowImageView!
    private var ignoreSubviewsLayoutUpdates: Bool = false
    private var initialCollectionViewOffset: CGPoint!
    private var offsetAnimator: ACAnimator?
    var labelFontColor: UIColor = UIColor.white
    var textFontColor: UIColor = UIColor.white
    var bgColor: UIColor = UIColor.white
    
    @IBOutlet weak var collectionView: MultiCollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.register(UINib(nibName: MovieMetadataCellView.typeName, bundle: nil), forCellWithReuseIdentifier: MovieMetadataCellView.typeName)
            collectionView.register(UINib(nibName: MediaDescriptionCellView.typeName, bundle: nil), forCellWithReuseIdentifier: MediaDescriptionCellView.typeName)
            collectionView.register(UINib(nibName: DirectorCellView.typeName, bundle: nil), forCellWithReuseIdentifier: DirectorCellView.typeName)
            collectionView.register(UINib(nibName: ActorCellView.typeName, bundle: nil), forCellWithReuseIdentifier: ActorCellView.typeName)
            collectionView.register(UINib(nibName: CrewCellView.typeName, bundle: nil), forCellWithReuseIdentifier: CrewCellView.typeName)
            collectionView.register(UINib(nibName: MediaHeaderView.typeName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaHeaderView.typeName)
        }
    }
//
    private var mediaActionsView: MediaActionsView!
    
    private(set) var isContentReady: Bool = false {
        didSet {
            if isContentReady {
                collectionView.reloadData()
            }
        }
    }
    
    private var directorsSection: Int {
        guard self.movieData.directors.count > 0 else {
            return -1
        }
        
        return 2
    }
    
    private var actorsSection: Int {
        guard self.movieData.actors.count > 0 else {
            return -1
        }
        
        if self.movieData.directors.count > 0 {
            return 3
        }
        
        return 2
    }
    
    private var crewsSection: Int {
        guard self.movieData.crews.count > 0 else {
            return -1
        }
        
        if self.movieData.directors.count > 0  && self.movieData.actors.count > 0 {
            return 4
        }
        else if self.movieData.directors.count > 0 || self.movieData.actors.count > 0{
            return 3
        }
        return 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.view
        // Hide "Back" label
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Add user score view to the hero image
        addUserScoreView()
        
        
        // Set hero image
        if let imageUrl = self.movieData.bgURL {
            ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                switch result {
                case let .success(response):
                    guard let strongSelf = self else { return }
                    let image = response.image
                    let averageColor = response.image.averageColor?.darker()
                    self?.bgColor = averageColor!
                    self?.view.backgroundColor = averageColor
                    self?.labelFontColor  = self?.getTextColor(bgColor: averageColor!) ?? UIColor.white
                    self?.textFontColor = self?.getContrastColor(color: averageColor!) ?? UIColor.white
                    if let movieMetaDataCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MovieMetadataCellView {
                        self?.setMovieMetadataCellFontColor(cell: movieMetaDataCell, labelFontColor: self?.labelFontColor, textFontColor: self?.textFontColor)
                    }
                    if let mediaDescriptionCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? MediaDescriptionCellView {
                        self?.setMediaDescriptionCellViewFontColor(cell: mediaDescriptionCell, labelFontColor: self?.labelFontColor, textFontColor: self?.textFontColor)
                    }
                    
                    self?.setMediaActionsViewLabelFontColor()
                    let maskSize = CGSize(width: image.size.width, height: image.size.height)
                    let path = strongSelf.bottomCurvedMask(for: maskSize, curvature: 0.15)
                    let newImage = image.masked(with: path)
                    strongSelf.heroImageView.image = newImage
                case .failure(_): break
                }
            }
        }
        
        self.addMediaActionsView()
        
        if self.movieData.fullyDetailed {
            print("fully detailed")
            self.isContentReady = true
        }
        else {
            print("TODO: need to fetch full details of movie")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.tintColor = .white
        
        setNeedsStatusBarAppearanceUpdate()
        
        // White status bar enforcing (needed for iOS 13+)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !ignoreSubviewsLayoutUpdates else {
            return
        }
        updateMediaActionsViewFrame()
        updateCollectionViewInset()
    }
    
    func setMovieMetadataCellFontColor(cell: MovieMetadataCellView, labelFontColor: UIColor?, textFontColor: UIColor?) {
        cell.yearLabel.textColor = labelFontColor
        cell.popularityLabel.textColor = labelFontColor
        cell.revenueLabel.textColor = labelFontColor
        
        cell.genresLabel.textColor = textFontColor
        cell.yearHolderLabel.textColor = textFontColor
        cell.popularityHolderLabel.textColor = textFontColor
        cell.revenueHolderLabel.textColor = textFontColor
    }
    
    func setMediaDescriptionCellViewFontColor(cell: MediaDescriptionCellView, labelFontColor: UIColor?, textFontColor: UIColor?) {
        print("media description set color")
        cell.topSeperator.backgroundColor = textFontColor
        cell.overviewLabel.textColor = textFontColor
    }
    
    private func addUserScoreView() {
        let userScoreView = UICircularProgressRing()
        userScoreView.innerRingWidth = 3
        userScoreView.outerRingWidth = 0
        userScoreView.fontColor = .white
        userScoreView.font = userScoreView.font.withSize(13)
        userScoreView.shouldShowValueText = true
        userScoreView.startAngle = 270
        userScoreView.valueKnobStyle = UICircularRingValueKnobStyle(size: 0, color: .clear)

        // Set background color to help with visibility
        let size: CGFloat = 44.0
        userScoreView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        userScoreView.layer.masksToBounds = true
        userScoreView.layer.cornerRadius = size / 2.0
        
        // Setup constraints
        let userScoreViewItem = UIBarButtonItem(customView: userScoreView)
        userScoreViewItem.customView?.widthAnchor.constraint(equalToConstant: size).isActive = true
        userScoreViewItem.customView?.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        // Description label
        let label = UILabel()
        label.text = "Score"
        label.textColor = .white
        
        // Set user score elements on the navigation bar
        self.navigationItem.rightBarButtonItems = [userScoreViewItem, UIBarButtonItem(customView: label)]

        // Animate to score value
        userScoreView.animateToValue(CGFloat(self.movieData.voteAverage ?? 0.0 * 10.0))
    }
    
    func setMediaActionsViewLabelFontColor() {
        if let actionsVIew = self.mediaActionsView {
            actionsVIew.titleLabel.textColor = self.labelFontColor
            actionsVIew.ratingView.settings.filledColor = self.labelFontColor
            actionsVIew.ratingView.settings.emptyBorderColor = self.labelFontColor
            actionsVIew.ratingView.settings.filledBorderColor = self.labelFontColor
//            self.mediaActionsView.playImageView.tintColor = color
        }
    }
    
    
    func getTextColor(bgColor: UIColor) -> UIColor {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        bgColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        if (brightness < 0.5) {
            return UIColor.white
        }
        else {
            return UIColor.black
        }
    }
    
    func getContrastColor(color: UIColor) -> UIColor {
        var d = CGFloat(0)

        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Counting the perceptive luminance - human eye favors green color...
        let luminance = 1 - ((0.299 * r) + (0.587 * g) + (0.114 * b))

        if luminance < 0.5 {
            d = CGFloat(0) // bright colors - black font
        } else {
            d = CGFloat(1) // dark colors - white font
        }

        return UIColor( red: d, green: d, blue: d, alpha: a)
    }
    
    private func addMediaActionsView() {
        mediaActionsView = MediaActionsView.fromNib()
        view.addSubview(mediaActionsView)
        self.mediaActionsView.playImageView.tintColor = UIColor.black
        self.mediaActionsView.ratingView.rating = self.movieData.voteAverage! / 2.0
        self.mediaActionsView.ratingView.settings.starSize = 22
//        self.mediaActionsView.ratingView.settings.filledImage = UIImage(named: "GoldStarFilled")
//        self.mediaActionsView.ratingView.settings.emptyImage = UIImage(named: "GoldStarEmpty")
        mediaActionsView.delegate = self
        mediaActionsView.titleLabel.text = self.movieData.title.uppercased()
    }
    
    func actionsViewDidSelectLikeButton(_ actionsView: MediaActionsView) {
        print("Like Clicked")
    }
    
    func actionsViewDidSelectDislikeButton(_ actionsView: MediaActionsView) {
        print("Dislike Clicked")
    }
    
    func actionsViewDidSelectPlayButton(_ actionsView: MediaActionsView) {
        print("Play Clicked")
    }
    
    func numberOfSections(in collectionView: MultiCollectionView) -> Int {
        guard isContentReady else {
            return 2
        }
        var count = 2
        if self.movieData.directors.count > 0 { count += 1 }
        if self.movieData.actors.count > 0 { count += 1 }
        if self.movieData.crews.count > 0 { count += 1 }
        return count
    }
    
    func collectionView(_ collectionView: MultiCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case actorsSection:
            return self.movieData.actors.count
        case directorsSection:
            return self.movieData.directors.count
        case crewsSection:
            return self.movieData.crews.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, reuseIdentifierForCellAt indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            return MovieMetadataCellView.typeName
        case 1:
            return MediaDescriptionCellView.typeName
//        case clipsSection:
//            return ClipCellView.typeName
        case actorsSection:
            return ActorCellView.typeName
        case directorsSection:
            return DirectorCellView.typeName
        case crewsSection:
            return CrewCellView.typeName
//        case recommendationsSection:
//            return PosterCellView.typeName
        default:
            assertionFailure("Wrong number of sections")
            return ""
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let movieMetadataCell = cell as? MovieMetadataCellView {
            movieMetadataCell.yearLabel.text = "\(self.movieData.releaseDateObj!.year)"
            movieMetadataCell.genresLabel.text = self.movieData.genresStr
            movieMetadataCell.popularityLabel.text = String(self.movieData.popularity!)
            movieMetadataCell.revenueLabel.text = self.movieData.revenue! > 0 ? "$\(Double(self.movieData.revenue!).formatPoints())" : "-"
            self.setMovieMetadataCellFontColor(cell: movieMetadataCell, labelFontColor: self.labelFontColor, textFontColor: self.textFontColor)
        }
        else if let mediaDescriptionCell = cell as? MediaDescriptionCellView {
            mediaDescriptionCell.overviewLabel.text = self.movieData.overview
            self.setMediaDescriptionCellViewFontColor(cell: mediaDescriptionCell, labelFontColor: self.labelFontColor, textFontColor: self.textFontColor)
        }
//        else if let clipCellView = cell as? ClipCellView {
//            let ytItem = mediaItem.clips[indexPath.item]
//            clipCellView.titleLabel.text = ytItem.title
//            loadClipImage(into: clipCellView.imageView, from: ytItem)
//        }
        else if let actorCellView = cell as? ActorCellView {
            let actorItem = self.movieData.actors[indexPath.item]
            actorCellView.titleLabel.text = actorItem.name
            actorCellView.titleLabel.textColor = self.labelFontColor
            if let imageUrl = actorItem.profileURL {
                // TODO: Set placeholder image temporarly while the other image is being requested
                ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result {
                    case let .success(response):
                        let image = response.image
                        let cellSize = strongSelf.collectionView(collectionView, sizeForItemAt: indexPath)
                        let imageWidth = cellSize.width - CircularCellView.imageHorizontalPadding * 2
                        let imageSize = CGSize(width: imageWidth, height: imageWidth)
                        let scaledImage = image.scaled(to: imageSize, scalingMode: .aspectFill, horizontalAligment: .center, verticalAligment: .top)
                        let roundedImage = scaledImage.rounded()
                        actorCellView.imageView.image = roundedImage
                        actorCellView.titleLabel.textColor = self?.labelFontColor
                    case .failure(_):
                        actorCellView.titleLabel.textColor = self?.labelFontColor
                        break
                    }
                }
            }
        }
        else if let directorCellView = cell as? DirectorCellView {
            let directorItem = self.movieData.directors[indexPath.item]
            directorCellView.titleLabel.text = directorItem.name
            directorCellView.titleLabel.textColor = self.labelFontColor
            if let imageUrl = directorItem.profileURL {
                // TODO: Set placeholder image temporarly while the other image is being requested
                ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result {
                    case let .success(response):
                        let image = response.image
                        let cellSize = strongSelf.collectionView(collectionView, sizeForItemAt: indexPath)
                        let imageWidth = cellSize.width - CircularCellView.imageHorizontalPadding * 2
                        let imageSize = CGSize(width: imageWidth, height: imageWidth)
                        let scaledImage = image.scaled(to: imageSize, scalingMode: .aspectFill, horizontalAligment: .center, verticalAligment: .top)
                        let roundedImage = scaledImage.rounded()
                        directorCellView.imageView.image = roundedImage
                        directorCellView.titleLabel.textColor = self?.labelFontColor
                    case .failure(_):
                        directorCellView.titleLabel.textColor = self?.labelFontColor
                        break
                    }
                }
            }
        }
        else if let crewCellView = cell as? CrewCellView {
            let crewItem = self.movieData.crews[indexPath.item]
            crewCellView.titleLabel.text = crewItem.name
            crewCellView.titleLabel.textColor = self.labelFontColor
            if let imageUrl = crewItem.profileURL {
                // TODO: Set placeholder image temporarly while the other image is being requested
                ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result {
                    case let .success(response):
                        let image = response.image
                        let cellSize = strongSelf.collectionView(collectionView, sizeForItemAt: indexPath)
                        let imageWidth = cellSize.width - CircularCellView.imageHorizontalPadding * 2
                        let imageSize = CGSize(width: imageWidth, height: imageWidth)
                        let scaledImage = image.scaled(to: imageSize, scalingMode: .aspectFill, horizontalAligment: .center, verticalAligment: .top)
                        let roundedImage = scaledImage.rounded()
                        crewCellView.imageView.image = roundedImage
                        crewCellView.titleLabel.textColor = self?.labelFontColor
                    case .failure(_):
                        crewCellView.titleLabel.textColor = self?.labelFontColor
                        break
                    }
                }
            }
        }
//        else if let posterCellView = cell as? PosterCellView {
//            let item = mediaItem.relatedMovies[indexPath.item]
//            if let imageUrl = URL(string: item.portraitPath) {
//                Nuke.loadImage(
//                    with: imageUrl,
//                    options: ImageLoadingOptions(
//                        transition: .fadeIn(duration: 0.3)
//                    ),
//                    into: posterCellView.imageView
//                )
//            }
//        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.frame.width, height: 108)
        case 1:
            let height = MediaDescriptionCellView.cellHeightForOverview(self.movieData.overview!, width: collectionView.frame.width)
            return CGSize(width: collectionView.frame.width, height: height)
//        case clipsSection:
//            return CGSize(width: 232, height: 228)
        case actorsSection:
            return CGSize(width: 156, height: 184)
        case directorsSection:
            return CGSize(width: 156, height: 184)
        case crewsSection:
            return CGSize(width: 156, height: 184)
//        case recommendationsSection:
//            return CGSize(width: 160, height: 240)
        default:
            assertionFailure("Wrong number of sections")
            return .zero
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case directorsSection, actorsSection, crewsSection:
            return CGSize(width: collectionView.frame.width, height: 65)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case directorsSection, actorsSection, crewsSection:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaHeaderView.typeName, for: indexPath) as! MediaHeaderView
            headerView.label.text = headerTitle(for: indexPath.section)
            headerView.label.textColor = self.labelFontColor
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case directorsSection, actorsSection, crewsSection:
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        case recommendationsSection:
//            return UIEdgeInsets(top: 0, left: 20, bottom: 30, right: 20)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: MultiCollectionView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
//        case clipsSection:
//            return 25
        case directorsSection, actorsSection, crewsSection:
            return 5
//        case recommendationsSection:
//            return 20
        default:
            return 0
        }
    }
    
    func collectionViewDidScrollVertically(_ collectionView: MultiCollectionView, toOffset offset: CGPoint) {
        guard initialCollectionViewOffset != nil else {
            initialCollectionViewOffset = offset
            return
        }
        
        // After the user interacts with the app, any call to `viewDidLayoutSubviews` must be ignored since those
        // will be triggered by the user interaction not by the initial views layout.
        ignoreSubviewsLayoutUpdates = true
                
        // Stop the offset animation if the user starts dragging the collection view
        if collectionView.isTracking {
            offsetAnimator?.stop()
        }

        let delta = offset.y - initialCollectionViewOffset.y
        let displacement = abs(delta)
        if delta < 0 {
            // Zoom in the hero image view as the user pulls down the scroll view
            let initialHeroImageHeight = heroImageReach(for: heroImageView.bounds)
            let initialHeroImageWidth = initialHeroImageHeight * 16 / 9
            
            let heroImageContainerHeightDelta = initialHeroImageHeight - heroImageView.bounds.height
            let heroImageContainerWidthDelta = initialHeroImageWidth - heroImageView.bounds.width
            
            let newHeroImageHeight = initialHeroImageHeight + displacement * 2
            let newHeroImageWidth = newHeroImageHeight * 16 / 9
            
            let heroImageContainerHeight = newHeroImageHeight - heroImageContainerHeightDelta
            let heroImageContainerWidth = newHeroImageWidth - heroImageContainerWidthDelta
            
            let scale = min(heroImageContainerWidth / heroImageView.bounds.width, heroImageContainerHeight / heroImageView.bounds.height)

            heroImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            heroImageView.imageView.alpha = 1.0
        }
        else if delta > 0 {
            // Move up the hero image view as the user pulls up the scroll view
            let minHeroImageReach: CGFloat = 100.0
            let initialHeroImageReach = heroImageReach(for: heroImageView.bounds)
            
            let maxDisplacement: CGFloat = initialHeroImageReach - minHeroImageReach
            let translationY = displacement < maxDisplacement ? -displacement : -maxDisplacement
            heroImageView.transform = CGAffineTransform(translationX: 0, y: translationY)
            
            // Make the hero image appear blurred as the user scrolls up
            let alpha = 1.0 - displacement / maxDisplacement
            heroImageView.imageView.alpha = alpha
        }
        else {
            heroImageView.transform = .identity
            heroImageView.imageView.alpha = 1.0
        }
        
        // Re-adjust the media actions view layout and the collection view insets now that the hero image view frame potentially changed
        updateMediaActionsViewFrame()
        if delta > 0 || delta == 0 {
            updateCollectionViewInset()
        }
    }
    
    func collectionViewWillEndDraggingVertically(_ collectionView: MultiCollectionView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Since the collection view content inset is modified during scrolling that breaks the deceleration animation.
        // That's why a simulated animation needs to be executed using `ACAnimator`.
        if velocity.y < 0.0 && collectionView.contentOffset.y == targetContentOffset.pointee.y {
            // Calculate the offset based on the velocity of the swipe
            var newYOffset = collectionView.contentOffset.y - (100 * abs(velocity.y))
            if newYOffset < initialCollectionViewOffset.y {
              newYOffset = initialCollectionViewOffset.y
            }

            // Determine the displacement needed to get to the targeted offset
            let initialYOffset = collectionView.contentOffset.y
            let displacement = newYOffset - initialYOffset
            
            // Calculate the animation duration using the kinematic equation
            // https://www.physicsclassroom.com/class/1DKin/Lesson-6/Kinematic-Equations
            let pointsPerSecond: CGFloat = 400.0
            var duration: CGFloat = (abs(displacement) * 2.0) / pointsPerSecond
            if duration > 0.5 { duration = 0.5 } // Cap the duration at 0.5s
            
            // Start animation
            offsetAnimator = ACAnimator(duration: CFTimeInterval(duration), easeFunction: .cubicOut, animation: { (fraction, _, _) in
                let yOffset = initialYOffset + displacement * CGFloat(fraction)
                collectionView.contentOffset = CGPoint(x: 0, y: yOffset)
            })
            offsetAnimator?.start()
        }
    }
    
    private func heroImageReach(for containerFrame: CGRect? = nil) -> CGFloat {
        let imageAreaSize = containerFrame?.size ?? heroImageView.frame.size
        let imageAspectRatio = CGSize(width: 16.0, height: 9.0)
        let scale = max(imageAreaSize.width / imageAspectRatio.width, imageAreaSize.height / imageAspectRatio.height)
        let imageExpandedSize = imageAspectRatio.scaled(by: scale)
        let imageHeightGrowth = imageExpandedSize.height - imageAreaSize.height
        let imageOrigin = containerFrame?.origin ?? heroImageView.frame.origin
        let imageReach = imageAreaSize.height + imageHeightGrowth / 2.0 + imageOrigin.y
        return imageReach
    }
    
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateMediaActionsViewFrame() {
        let actionsViewY = heroImageReach() - MediaActionsView.playButtonSize / 2.0
        let actionsViewPosition = CGPoint(x: 0, y: actionsViewY)
        let actionsViewHeight = MediaActionsView.cellHeightForTitle(self.movieData.title.uppercased(), width: collectionView.frame.width)
        let actionsViewSize = CGSize(width: collectionView.frame.width, height: actionsViewHeight)
        mediaActionsView.frame = CGRect(origin: actionsViewPosition, size: actionsViewSize)
    }
    
    
    private func bottomCurvedMask(for size: CGSize, curvature: CGFloat) -> UIBezierPath {
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let w = bounds.size.width
        let h = bounds.size.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h - (h * curvature)))
        
        // Draw quadratic curve.
        // Calculate the control point based on the 3 points that the curve must pass through.
        // Based on: https://stackoverflow.com/a/38753266/1792699
        func controlPoint(_ leftPoint: CGPoint, _ rightPoint: CGPoint, _ middlePoint: CGPoint) -> CGPoint {
            let x = 2 * middlePoint.x - leftPoint.x / 2 - rightPoint.x / 2
            let y = 2 * middlePoint.y - leftPoint.y / 2 - rightPoint.y / 2
            return CGPoint(x: x, y: y)
        }
        
        let leftPoint = CGPoint(x: 0, y: h - (h * curvature))
        let middlePoint = CGPoint(x: w / 2, y: h)
        let rightPoint = CGPoint(x: w, y: h - (h * curvature))
        
        path.addQuadCurve(to: leftPoint, controlPoint: controlPoint(leftPoint, rightPoint, middlePoint))
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        return path
    }
    
    private func updateCollectionViewInset() {
        // Set the collection content inset based on the media actions view position
        collectionView.contentInset = UIEdgeInsets(top: mediaActionsView.frame.origin.y + mediaActionsView.frame.height, left: 0, bottom: 20, right: 0)
        
        // Set the collection view mask so that the content goes behind every other screen element
        setupCollectionViewMaskingGradient()
    }
    
    private func setupCollectionViewMaskingGradient() {
        let gradientHeight: CGFloat = 20.0
        let gradientEndLocation = NSNumber(value: Float(gradientHeight / UIScreen.main.bounds.height))

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, gradientEndLocation]
        gradient.frame = CGRect(x: 0, y: collectionView.contentInset.top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        collectionView.layer.mask = gradient
    }
    
    private func headerTitle(for section: Int) -> String {
        switch section {
//        case clipsSection:
//            return "Clips & Trailers"
        case actorsSection:
            return "Casts"
        case directorsSection:
            return "Directors"
        case crewsSection:
            return "Crews"
//        case recommendationsSection:
//            return "You Might Also Like"
        default:
            return ""
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
