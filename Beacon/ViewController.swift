//
//  ViewController.swift
//  Beacon
//
//  Created by Ángel González on 18/11/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let adminUbicacion = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        adminUbicacion.delegate = self
        // el rango de detección de un beacon es como de 40m
        adminUbicacion.desiredAccuracy = kCLLocationAccuracyBest
        // para que esto funcione, se necesita habilitar los background modes, pero para que eso funcione se necseita un
        // bundle identifier que tenga su provisioning profile en el portal de developer
        // adminUbicacion.allowsBackgroundLocationUpdates = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adminUbicacion.requestAlwaysAuthorization()
    }
    
    func buscar() {
        // cada beacon tiene un identificador único
        let identificador = "5a4bcfce-174e-4bac-a814-092e77f6b7e5"
        if let uuid = UUID(uuidString: identificador) {
            let conjuntoDeIds = CLBeaconIdentityConstraint(uuid: uuid)
            adminUbicacion.startRangingBeacons(satisfying: conjuntoDeIds)
        }
    }
    
    // MARK: - LocationManager delegate
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        // a la vieja escuela:
        // if beacons.count > 0 { ......
        // a la manera swift :)
        guard let beacon = beacons.first else { return }
        // BLE 4.0
        // 
        let textView = UITextView()
        textView.frame = self.view.frame.insetBy(dx: 30, dy: 100)
        var proximidad = ""
        switch beacon.proximity {
            case .immediate: proximidad = "inmediata"
            case .near: proximidad = "cercana"
            case .far: proximidad = "lejana"
            default:proximidad = "desconocida"
        }
        textView.text = "Encontré un beacon, a una distancia \(proximidad) de \(beacon.accuracy)"
        self.view.addSubview(textView)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let aut = adminUbicacion.authorizationStatus
        if aut == .authorizedAlways || aut == .authorizedWhenInUse {
            // si tengo permiso de usar el gps, entonces iniciamos la detección de beacons
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    buscar()
                }
            }
        }
        else if aut == .notDetermined {
            adminUbicacion.requestAlwaysAuthorization()
        }
        else {
            // otra vez nos fue negado el permiso
            // Si necesitamos terminar una app. El código indica el tipo de error
            exit(666)
        }
    }

}

