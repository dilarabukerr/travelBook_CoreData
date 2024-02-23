//
//  ViewController.swift
//  travelBook_CoreData
//
//  Created by Dilara Büker on 22.02.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Storyboard üzerindeki arayüz öğeleri
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // Konum yöneticisi ve diğer değişkenler
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    // Seçilen mekanın bilgilerini tutacak değişkenler
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    // Harita üzerindeki işaretin bilgileri
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegeleri ayarla
        mapView.delegate = self
        locationManager.delegate = self
        
        // Konum yöneticisi ayarları
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Uzun dokunma jesti tanımla
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2 // 2 saniye basılı tutulması gerekiyor
        mapView.addGestureRecognizer(gestureRecognizer)
        
        // Eğer bir mekan seçilmişse, onun bilgilerini al
        if selectedTitle != "" {
            // CoreData'den mekan bilgilerini getir
            
            // AppDelegate'e erişim sağla
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // CoreData'nin bulunduğu context'i al
            let context = appDelegate.persistentContainer.viewContext
            
            // Mekanın ID'sini kullanarak mekanı bulmak için sorgu oluştur
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                // Sorguyu çalıştır ve sonuçları al
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    // Sonuçlar bulunduysa, her bir sonucu döngüyle işle
                    
                    for result in results as! [NSManagedObject] {
                        // Mekanın başlığını al
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            // Mekanın alt başlığını al
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                // Mekanın enlem değerini al
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    // Mekanın boylam değerini al
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        // Harita üzerine işareti ekle
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        locationManager.stopUpdatingLocation()
                                        
                                        // Haritayı seçilen mekanın etrafında ayarla
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        } else {
            // Yeni veri ekleme modu
        }
    }
    
    // Uzun dokunma jestine yanıt veren fonksiyon
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            // Harita üzerine işareti ekle
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
    }
    
    // Konum güncellendiğinde çağrılan fonksiyon
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            // Seçilen mekan varsa, başka bir şey yapma
        }
    }
    
    // Harita üzerindeki işaretin görünümünü özelleştiren fonksiyon
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    // İşaretin detaylarını gösteren butona basıldığında çağrılan fonksiyon
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            // İşaretin adresini al ve haritada aç
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    // Kaydet butonuna tıklandığında çağrılan fonksiyon
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        // CoreData ile bağlantıyı kur
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Yeni bir mekan oluştur ve verilerini ata
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        // Veriyi kaydet
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        // Yeni mekan eklendiğinde bildirim gönder
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        
        // Bir önceki ekrana geri dön
        navigationController?.popViewController(animated: true)
    }
}
