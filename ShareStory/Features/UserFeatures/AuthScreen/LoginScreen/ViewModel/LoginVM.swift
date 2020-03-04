//
//  LoginVM.swift
//  ShareStory
//
//  Created by Tifo Audi Alif Putra on 10/10/19.
//  Copyright © 2019 BCC FILKOM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginVM {
    
    private var _isLoginSuccess = BehaviorRelay<Bool>(value: false)
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    private var _hasError = BehaviorRelay<Bool>(value: false)
    
    var hasError: Driver<Bool> {
        return _hasError.asDriver()
    }
    
    var isLoginSuccess: Driver<Bool> {
        return _isLoginSuccess.asDriver()
    }
    
    var isLoading: Driver<Bool> {
        return _isLoading.asDriver()
    }
    
    func loginUser(email: String, password: String) {
        self._isLoading.accept(true)
        DataService.shared.loginUser(email: email, password: password, success: { [weak self] in
            self?._isLoading.accept(false)
            self?._hasError.accept(false)
            self?._isLoginSuccess.accept(true)
        }) { [weak self] in
            self?._isLoading.accept(false)
            self?._isLoginSuccess.accept(false)
            self?._hasError.accept(true)
        }
    }
}
