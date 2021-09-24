//
//  ColaCupController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

/// A controller for viewing logs
open class ColaCupController: BaseLogViewController {
    /// Use the log manager to initialize the controller.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.viewModel = ColaCupViewModel(logManager: logManager)
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Entrance to the filter page.
    public private(set) lazy var filterButton: UIButton = createBarButton(
        imageName: "line.horizontal.3.decrease.circle",
        selectImageName: "line.horizontal.3.decrease.circle.fill",
        action: #selector(filterButtonDidClick(_:))
    )
    
    /// Controller for searching logs.
    private lazy var searchController = SearchController()
    
    /// Used to process data.
    private let viewModel: ColaCupViewModel
    
    /// Used to provide vibration feedback.
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
}

// MARK: - Life cycle

extension ColaCupController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        startProcessingData()
        
        searchController.resultController.delegate = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterButton.isEnabled = true
    }
}

// MARK: - Config

private extension ColaCupController {
    func configNavigationBar() {
        let bar = navigationController?.navigationBar
        
        bar?.tintColor = .theme
        bar?.isTranslucent = true
        bar?.backIndicatorImage = nil
        bar?.backIndicatorTransitionMaskImage = nil
        
        navigationItem.title = "ColaCup"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: createBarButton(
            imageName: "xmark.circle",
            selectImageName: "xmark.circle.fill",
            action: #selector(closeButtonDidClick(_:))
        ))
        
        if #available(iOS 11.0, *) {
            bar?.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
            
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    func createBarButton(imageName: String, selectImageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isEnabled = true
        button.tintColor = .theme
        button.setImage(UIImage(name: imageName), for: .normal)
        button.setImage(UIImage(name: selectImageName), for: .selected)
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 40 * 0.55)
            button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
            button.setPreferredSymbolConfiguration(config, forImageIn: .selected)
        }
        
        button.addTarget(self, action: #selector(buttonDidTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    func startProcessingData() {
        loadingView.show()
        
        viewModel.processLogs { [weak self] in
            guard let this = self else { return }
            
            this.loadingView.hide()
            this.tableView.reloadData()
        }
    }
}

// MARK: - Action

extension ColaCupController {
    /// Execute when the button is pressed.
    ///
    /// - Parameter button: Button pressed.
    @objc open func buttonDidTouchDown(_ button: UIButton) {
        feedbackGenerator.prepare()
    }
    
    /// Close button click event.
    ///
    /// - Parameter button: `toolBar.closeButton`.
    @objc open func closeButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        dismiss(animated: true)
    }
    
    /// Filter button click event.
    ///
    /// - Parameter button: `filterButton`.
    @objc open func filterButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        
        
        
    }
}

// MARK: - UITableViewDelegate

extension ColaCupController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        navigationController?.pushViewController(DetailsViewController(log: viewModel.showLogs[indexPath.row]), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ColaCupController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showLogs.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = viewModel.showLogs[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        
        cell.flagLabel.text = log.flag
        cell.timeLabel.text = log.formatTime
        cell.logLabel.text = log.safeLog
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension ColaCupController: UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let cell = previewingContext.sourceView as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        return DetailsViewController(log: viewModel.showLogs[indexPath.row])
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - UISearchControllerDelegate

extension ColaCupController: SearchResultViewControllerDelegate {
    func searchResult(_ resultController: SearchResultViewController, search keyword: String, result: @escaping ([LogModelProtocol]) -> Void) {
        viewModel.search(by: keyword, executeImmediately: true, completion: result)
    }
    
    func searchResult(_ resultController: SearchResultViewController, didClickResult log: LogModelProtocol) {
        navigationController?.pushViewController(DetailsViewController(log: log), animated: true)
    }
}





















// MARK: - TimePopoverDataDelegate

extension ColaCupController: TimePopoverDataDelegate {
    public func timePopover(_ popover: TimePopover, didChangedViewedLogDate model: TimePopoverModel) {
        viewModel.updateTimeModel(model)
        refreshLogData(executeImmediately: true)
    }
}

// MARK: - FilterPopoverDataDelegate

extension ColaCupController: FilterPopoverDataDelegate {
    
    public func filterPopover(_ popover: FilterPopover, search keyword: String) {
        
        viewModel.updateSearchKeyword(keyword)
        
        refreshLogData(executeImmediately: false)
    }
    
    public func filterPopover(_ popover: FilterPopover, clickedFlagAt index: Int, flags: [SelectedModel<Log.Flag>]) {
        
        viewModel.updateFlags(flags)
        
        refreshLogData(executeImmediately: true)
    }
    
    public func filterPopover(_ popover: FilterPopover, clickedModuleAt index: Int, modules: [SelectedModel<String>]) {
        
        viewModel.updateModules(modules)
        
        refreshLogData(executeImmediately: false)
    }
}

// MARK: - Tools

private extension ColaCupController {
    /// Refresh log data.
    /// 
    /// - Parameter executeImmediately: Whether to perform the search immediately.
    func refreshLogData(executeImmediately: Bool) {
        loadingView.show()
        
        viewModel.refreshLogData(executeImmediately: executeImmediately) { [weak self] in
            guard let this = self else { return }
            
            this.loadingView.hide()
            this.tableView.reloadData()
        }
    }
}
