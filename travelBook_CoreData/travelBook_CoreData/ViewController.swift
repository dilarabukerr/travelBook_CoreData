//
//  ViewController.swift
//  travelBook_CoreData
//
//  Created by Dilara Büker on 22.02.2024.
//

import UIKit
import MapKit //harita kullanmak için
import CoreLocation //kullanıcıdan konum almak için
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var locationManager = CLLocationManager() // Konum yöneticisi tanımı
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Konum izni isteği
        locationManager.delegate = self //konum yöneticisinin delegesini ayarla
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //lokasyonun güvenilirliğini ayarlama.
        locationManager.requestWhenInUseAuthorization() //kullanım sırasında konum iste
        locationManager.startUpdatingLocation()//kullanıcının yerini alma.
//burada info kısmında privacy ayarlarından location için when in use seçeneğini seçebilirsin.
        
        //Harita ayarları
        mapView.delegate = self
        mapView.showsUserLocation = true //kullanıcı konumunu haritada göster

        
        // Uzun basma (long press) hareketi tanımlama ve bu hareketi dinleme
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)//kullanıcının harita üzerinde bir yere uzun süre basması durumunda belirli bir işlemin gerçekleşmesini sağlar.
    }
    
    //konum izni değişikliklerini kontrol et
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse { //eğer konum izni kullanım sırasında verildiyse
            locationManager.startUpdatingLocation()//konum güncellemelerini başlat
        }
    }
    
    //konum güncellemelerini işle
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return} //en son konumu al, Eğer locations dizisi boş değilse, en son konumu al ve location sabitine ata, Eğer locations dizisi boş ise, fonksiyonu burada erken sonlandır
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)//konumu merkez alarak bir bölge oluşturur
        mapView.setRegion(region, animated: true)//harita görünümünün bölgesini güncelle
    }
    
    //konum izni reddedildiğinde
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("konum izni hatası")
    }
    
    //uzun basma (long press) işlemi gerçekleştiğinde çağrılan fonksiyon
    @objc func handleLongPress (gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            //uzun basılan ilk noktayı al
            let touchPoint = gesture.location(in: mapView)
            //dokunulan noktayı harita koordinatlarına dönüştür
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            //pin ekleme fonksiyonunu çağır
            addPin(coordinate: coordinate)
        }
    }
    
    //verilen koordinatlara bir pin ekleyen fonksiyon
    func addPin (coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = nameText.text //isim metin kutusundaki değeri pinin başlığına ata
        annotation.subtitle = commentText.text //açıklama metin kutusundaki değeri pinin altbaşlığına ata
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func saveButton(_ sender: Any) {
       
    }
}

