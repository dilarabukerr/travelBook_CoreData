//
//  ListViewController.swift
//  travelBook_CoreData
//
//  Created by Dilara Büker on 24.02.2024.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Storyboard'dan bağladığımız arayüz öğeleri
    @IBOutlet weak var tableView: UITableView!
    
    // Mekanların başlık ve ID bilgilerini tutacak değişkenler
    var titleArray = [String]()
    var idArray = [UUID]()
    
    // Seçilen mekanın bilgilerini tutacak değişkenler
    var chosenTitle = ""
    var chosenTitleId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar'a "+" butonu ekle ve butona tıklanınca çağrılacak fonksiyonu belirle
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        // TableView'nin delegelerini ayarla
        tableView.delegate = self
        tableView.dataSource = self
        
        // Verileri yükle
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Yeni mekan eklendiğinde verileri güncellemek için NotificationCenter'a abone ol
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    // CoreData'den mekan verilerini getiren fonksiyon
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                // Mevcut verileri temizle
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                // Yeni verileri ekle
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    // TableView'yi güncelle
                    tableView.reloadData()
                }
            }
        } catch {
            print("error")
        }
    }
    
    // "+" butonuna tıklandığında çağrılan fonksiyon
    @objc func addButtonClicked() {
        // Seçilen mekanı sıfırla ve ViewController'a geçiş yap
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    // TableView'deki satır sayısını belirten fonksiyon
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    // TableView'deki hücreleri oluşturan fonksiyon
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        // Başlık bilgisini hücreye yerleştir
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    // TableView'deki bir satıra tıklandığında çağrılan fonksiyon
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçilen mekanın bilgilerini al ve ViewController'a geçiş yap
        chosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    // Geçiş yapmadan önce ViewController'a veri aktaran fonksiyon
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedTitleID = chosenTitleId
        }
    }
}
