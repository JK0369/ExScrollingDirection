//
//  ViewController.swift
//  ExScrolling
//
//  Created by 김종권 on 2023/02/15.
//

import UIKit
import RxSwift
import RxGesture

class ViewController: UIViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let tableView: UITableView = {
        let view = UITableView()
        view.allowsSelection = false
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.contentInset = .zero
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.estimatedRowHeight = 34
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var items = (0...100).map(String.init)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tableView.rx.isDownScrollable
            .bind(with: self) { ss, isDown in
                ss.label.text = isDown ? "down" : "up"
                ss.label.textColor = isDown ? .red : .blue
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension Reactive where Base: UIScrollView {
    /// 오른쪽 indicator 방향 기준 (indicator가 내려가면 true)
    var isDownScrollable: Observable<Bool> {
        base.rx.panGesture()
            .withUnretained(base)
            .map { ss, gesture in
                gesture.translation(in: ss).y < 0
            }
    }
}
