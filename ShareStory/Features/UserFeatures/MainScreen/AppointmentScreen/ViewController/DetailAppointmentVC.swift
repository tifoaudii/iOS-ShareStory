//
//  DetailAppointmentVC.swift
//  ShareStory
//
//  Created by Tifo Audi Alif Putra on 29/02/20.
//  Copyright © 2020 BCC FILKOM. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class DetailAppointmentVC: UIViewController {
    
    private var appointment: Appointment?
    private let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 5000
    private let mapViewIdentifier = "mapViewIdentifier"
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        return mv
    }()
    
    let konselorInfoView: UIView = {
        let view = UIView()
        return view
    }()
    
    let konselorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let konselorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    let konselorLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    let timeLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    let addressLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        getKonselorProfile()
    }
    
    func setupView(_ konselor: Konselor) {
        guard let appointment = appointment else {
            return
        }
        self.view.addSubview(mapView)
        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height / 2)
        mapView.showsUserLocation = true
        
        self.view.addSubview(konselorInfoView)
        konselorInfoView.anchor(top: mapView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
        konselorInfoView.backgroundColor = .white
        konselorInfoView.layer.borderWidth = 0.5
        konselorInfoView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let labelStackView = UIStackView(arrangedSubviews: [konselorNameLabel,konselorLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        
        konselorInfoView.addSubview(konselorImageView)
        konselorInfoView.addSubview(labelStackView)
        
        konselorImageView.kf.setImage(with: URL(string: appointment.konselorPhotoUrl))
        konselorImageView.anchor(top: nil, left: konselorInfoView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        konselorImageView.centerYAnchor.constraint(equalTo: konselorInfoView.centerYAnchor).isActive = true
        
        konselorNameLabel.text = appointment.konselorName
        konselorLabel.text = "Konselor Psikologi"
        
        labelStackView.anchor(top: nil, left: konselorImageView.rightAnchor, bottom: nil, right: konselorInfoView.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        labelStackView.centerYAnchor.constraint(equalTo: konselorInfoView.centerYAnchor).isActive = true
        
        konselorInfoView.layoutSubviews()
        konselorImageView.layer.cornerRadius = konselorImageView.frame.width / 2
        
        let infoStackView = UIStackView(arrangedSubviews: [timeLabelStackView, addressLabelStackView])
        infoStackView.axis = .vertical
        infoStackView.distribution = .fillEqually
        self.view.addSubview(infoStackView)
        infoStackView.anchor(top: konselorInfoView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 10, paddingRight: 12, width: 0, height: 0)
        
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        timeLabel.text = "Waktu"
        
        let timeValue = UILabel()
        timeValue.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeValue.text = appointment.date
        timeLabelStackView.addArrangedSubview(timeLabel)
        timeLabelStackView.addArrangedSubview(timeValue)
        
        
        let addressLabel = UILabel()
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        addressLabel.text = "Alamat"
        
        let addressValue = UILabel()
        addressValue.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addressValue.text = konselor.address
        addressLabelStackView.addArrangedSubview(addressLabel)
        addressLabelStackView.addArrangedSubview(addressValue)
    }
    
    func set(_ appointment: Appointment) {
        self.appointment = appointment
    }
    
    func getKonselorProfile() {
        guard let appointment = appointment else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.shared.getKonselorProfile(uid: appointment.konselorId, completion: { [unowned self] (konselor) in
                self.configureMapView(konselor)
                self.setupView(konselor)
            }) {
                
            }
        }
    }
    
    func configureMapView(_ konselor: Konselor) {
        guard let userLocation = locationManager.location?.coordinate else {
            return
        }
        
        let coordinateRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.addAnnotation(konselor)
        
        let konselorLocation = CLLocationCoordinate2D(latitude: konselor.latitude, longitude: konselor.longitude)
        
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let konselorPlacemark = MKPlacemark(coordinate: konselorLocation)
        
        let userMapItem = MKMapItem(placemark: userPlacemark)
        let konselorMapItem = MKMapItem(placemark: konselorPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = userMapItem
        directionRequest.destination = konselorMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }
            let route = response.routes[0]

            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
}

extension DetailAppointmentVC: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? Konselor else { return nil }
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: mapViewIdentifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.displayPriority = .required
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: mapViewIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: -5)
            view.displayPriority = .required
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)

        renderer.lineWidth = 5.0

        return renderer
    }
    
    
}
