//
//  SearchViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/2/25.
//

import UIKit

class SearchViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextView: UIView!
    
    // MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let text = searchTextField.text ?? ""
        view.endEditing(true)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tableView.isHidden = true
            tableView.isUserInteractionEnabled = false
        }
        viewModel.search(text: text)
    }
    
    // MARK: - 스와이프 변수
    var swipeRecognizer: UISwipeGestureRecognizer!

    // MARK: - Private
    private let viewModel = SearchViewModel()
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)

        // Setup table view inside searchTextView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchTextView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchTextView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: searchTextView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: searchTextView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: searchTextView.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Start with table hidden/disabled
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false

        // Bind view model
        viewModel.onResultsChanged = { [weak self] results in
            guard let self = self else { return }
            // Debug print each result's name and PlaceID
            for (idx, item) in results.enumerated() {
                print("[Search] Result #\(idx + 1): \(item.name), PlaceID: \(item.id)")
            }
            // Show table only when we have results and the search text is non-empty
            let query = self.searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let shouldShow = !query.isEmpty && !results.isEmpty
            self.tableView.isHidden = !shouldShow
            self.tableView.isUserInteractionEnabled = shouldShow
            self.tableView.reloadData()
        }

        // Text field setup
        searchTextField.delegate = self
        searchTextField.returnKeyType = .search
        
        // Observe text changes to enable/disable table view
        searchTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    // MARK: - Action
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        let query = (sender.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShow = !query.isEmpty && !viewModel.results.isEmpty
        tableView.isHidden = !shouldShow
        tableView.isUserInteractionEnabled = shouldShow
        if shouldShow {
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = viewModel.results[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = nil // Remove rating to use image instead
        content.image = UIImage(systemName: "photo")
        content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        content.imageProperties.cornerRadius = 6
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        // Fetch first photo for this place and update the cell's image when loaded
        let placeID = item.id
        viewModel.fetchFirstPhoto(placeID: placeID, maxSize: CGSize(width: 200, height: 200)) { [weak tableView] image in
            DispatchQueue.main.async {
                guard let tableView = tableView,
                      let visibleCell = tableView.cellForRow(at: indexPath) else { return }
                var updated = visibleCell.defaultContentConfiguration()
                updated.text = item.name
                updated.secondaryText = nil
                updated.image = image ?? UIImage(systemName: "photo")
                updated.imageProperties.maximumSize = CGSize(width: 44, height: 44)
                updated.imageProperties.cornerRadius = 6
                visibleCell.contentConfiguration = updated
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.results[indexPath.row]
        print("[Search] Selected Place: \(item.name), PlaceID: \(item.id)")
        // Handle selection if needed (e.g., push detail)
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButton(self)
        return true
    }
}

