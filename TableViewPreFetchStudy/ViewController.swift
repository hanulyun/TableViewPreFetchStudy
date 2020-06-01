//
//  ViewController.swift
//  TableViewPreFetchStudy
//
//  Created by hanulyun-tera on 2020/05/20.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum PagingType {
        case scrollOffset
        case willDisplay
        case prefetch
    }
    
    private let tableView: UITableView = UITableView()
    
    private var dataList: [Int] = []
    
    private var addDataCallCount: Int = 0
    private let finishCallCount: Int = 10
    
    private var type: PagingType = .willDisplay
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
            
        addData()
        
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        let guide: UILayoutGuide = view.safeAreaLayoutGuide
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        
        tableView.dataSource = self
        tableView.delegate = self
        if type == .prefetch {
            tableView.prefetchDataSource = self
        }
    }
    
    private func addData() {
        let count: Int = dataList.count
        for i in count..<(count + 25) {
            dataList.append(i)
        }
        
        addDataCallCount += 1
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("🎃CallCount = \(self.addDataCallCount)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count + 1 // 마지막행 데이터 보여주기위해 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataList.count {
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = "No More Data"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell()
            let data: String = String(dataList[indexPath.row])
            cell.textLabel?.text = "data = \(data)"
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if type == .willDisplay {
            if indexPath.row > dataList.count - 5 {
                if addDataCallCount == finishCallCount {
                    return
                }
                
                // willDisplay 만으로는 cell이 screen에 보여졌다고 보장되지 않음.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if tableView.visibleCells.contains(cell) {
                        self.addData()
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type == .scrollOffset {
            if addDataCallCount == finishCallCount {
                return
            }
            
            let height: CGFloat = scrollView.frame.size.height
            let contentYOffset: CGFloat = scrollView.contentOffset.y
            let scrollViewHeight: CGFloat = scrollView.contentSize.height
            let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
            if distanceFromBottom < height {
                self.addData()
            }
        }
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if addDataCallCount == finishCallCount {
                return
            }
            
            if dataList.count == indexPath.row {
                self.addData()
            }
        }
    }
}
