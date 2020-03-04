//
//  KonselorProfileVC.swift
//  ShareStory
//
//  Created by Tifo Audi Alif Putra on 08/12/19.
//  Copyright © 2019 BCC FILKOM. All rights reserved.
//

import UIKit
import Kingfisher

class KonselorProfileVC: UIViewController {

    @IBOutlet weak var konselorImageProfile: UIImageView!
    @IBOutlet weak var konselorName: UILabel!
    @IBOutlet weak var appointmentView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        appointmentView.addGestureRecognizer(tapGesture)

        DataService.shared.getKonselorProfile(uid: DataService.shared.konselorUid, completion: { [unowned self] (konselor) in
            self.konselorImageProfile.kf.setImage(with: URL(string: konselor.photoUrl))
            self.konselorImageProfile.layer.cornerRadius = self.konselorImageProfile.frame.width / 2
            self.konselorName.text = konselor.name
            
            if konselor.rating > 0 {
                let ratingValue = konselor.rating / Double(konselor.patientCount)
                self.ratingLabel.text = "\(round(10 * ratingValue) / 10)  (\(konselor.patientCount))"
            } else {
                self.ratingLabel.text = "\(konselor.rating)"
            }
            
        }) { [unowned self] in
            self.showErrorMessage()
        }
    }
    
    @objc func handleTap() {
        let appointmentVC = UIStoryboard.init(name: "Konselor", bundle: nil).instantiateViewController(identifier: "KonselorAppointmentVC")
        self.navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    @IBAction func logoutButtonDidClicked(_ sender: Any) {
        self.showAlertLogout()
    }
    
    
    func showAlertLogout() {
        let alertController = UIAlertController(title: "Mohon Perhatian", message: "Apakah anda yakin ingin keluar?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Ya", style: .default) { [unowned self] (_) in
            self.logout()
        }
        let cancelAction = UIAlertAction(title: "Batalkan", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logout() {
        DataService.shared.logout { [unowned self] (success) in
            
            if success {
                DataService.shared.isKonselorLoggedIn = false
                DataService.shared.konselorUid = ""
                self.navigateToWelcomeScreen()
            } else {
                self.showErrorMessage()
            }
        }
    }
    
    func navigateToWelcomeScreen() {
        let welcomeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "WelcomeVC") as WelcomeVC
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true, completion: nil)
    }
}
