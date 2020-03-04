//
//  HistoryChatVC.swift
//  ShareStory
//
//  Created by Tifo Audi Alif Putra on 30/11/19.
//  Copyright © 2019 BCC FILKOM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryChatVC: UIViewController {

    @IBOutlet weak var historyChatTableView: UITableView!
    
    private var chatRoom: ChatRoom?
    private var messages = [Message]()
    private let chatVM = ChatVM()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureTableView()
        self.fetchAllMessages()
        self.bindViewModel()
    }
    
    fileprivate func fetchAllMessages() {
        guard let chatRoom = chatRoom else {
            return
        }
        
        self.chatVM.fetchMessages(chatRoom: chatRoom)
        self.chatVM.observeMessage(chatRoom: chatRoom)
    }
    
    fileprivate func bindViewModel() {
        self.chatVM.messages
            .drive(onNext: { [unowned self] messages in
                self.messages = messages
                self.historyChatTableView.reloadData()
            }).disposed(by: disposeBag)
        
        self.chatVM.hasError
            .drive(onNext: { [unowned self] hasError in
                if hasError {
                    self.showErrorMessage()
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func configureTableView() {
        self.historyChatTableView.delegate = self
        self.historyChatTableView.dataSource = self
        self.historyChatTableView.tableFooterView = UIView()
        self.historyChatTableView.estimatedRowHeight = 90
        self.historyChatTableView.rowHeight = UITableView.automaticDimension
    }

}

extension HistoryChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        if message.senderType == .konselor {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatKonselorCell", for: indexPath) as? ChatKonselorCell else {
                return UITableViewCell()
            }
            
            if let viewModel = chatVM.viewModelForMessages(at: indexPath.row) {
                cell.setupCell(messageVM: viewModel)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatPatientCell", for: indexPath) as? ChatPatientCell else {
                return UITableViewCell()
            }
            cell.setupCell(message: message.content)
            return cell
        }
    }
    
    open func loadChatRoom(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }
}
