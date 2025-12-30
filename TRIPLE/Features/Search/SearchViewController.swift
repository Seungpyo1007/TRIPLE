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
    
    // MARK: - 상수 & 스와이프 변수
    private let viewModel = SearchViewModel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    var swipeRecognizer: UISwipeGestureRecognizer!

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)

        // searchTextView 내부에 테이블 뷰를 설정합니다.
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
        
        // 테이블이 숨겨지거나 비활성화된 상태에서 시작하세요.
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false

        // 바인딩 뷰 모델
        viewModel.onResultsChanged = { [weak self] results in
            guard let self = self else { return }
            // 디버그 모드에서 각 결과의 이름과 PlaceID를 출력합니다.
            for (idx, item) in results.enumerated() {
                print("[Search] Result #\(idx + 1): \(item.name), PlaceID: \(item.id)")
            }
            // 검색 결과가 있고 검색어가 비어 있지 않은 경우에만 표를 표시합니다.
            let query = self.searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let shouldShow = !query.isEmpty && !results.isEmpty
            self.tableView.isHidden = !shouldShow
            self.tableView.isUserInteractionEnabled = shouldShow
            self.tableView.reloadData()
        }

        // 텍스트 필드 설정
        searchTextField.delegate = self
        searchTextField.returnKeyType = .search
        
        // 텍스트 변경 사항을 확인하여 테이블 보기를 활성화/비활성화하세요.
        searchTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
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
        content.secondaryText = nil
        content.image = UIImage(systemName: "photo")
        content.imageProperties.maximumSize = CGSize(width: 25, height: 25)
        content.imageProperties.cornerRadius = 6
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        let placeID = item.id
        viewModel.fetchFirstPhoto(placeID: placeID, maxSize: CGSize(width: 200, height: 200)) { [weak tableView] image in
            DispatchQueue.main.async {
                guard let tableView = tableView,
                      let visibleCell = tableView.cellForRow(at: indexPath) else { return }
                var updated = visibleCell.defaultContentConfiguration()
                updated.text = item.name
                updated.secondaryText = nil
                updated.image = image ?? UIImage(systemName: "photo")
                updated.imageProperties.maximumSize = CGSize(width: 25, height: 25)
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
        // 필요한 경우 선택 항목을 처리합니다(예: 세부 정보 표시).
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButton(self)
        return true
    }
}

