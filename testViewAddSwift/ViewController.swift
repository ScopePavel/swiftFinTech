//
//  ViewController.swift
//  testViewAddSwift
//
//  Created by Pavel Scope on 13/11/2018.
//  Copyright © 2018 Pavel Scope. All rights reserved.
//

import UIKit






class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  var companies = ["Apple":"AAPL","Microsoft":"MSFT","Google":"GOOG", "FaceBook":"FB","Amazon":"AMZN"]
  
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
   
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyPriceChangeLabel: UILabel!
    @IBOutlet weak var companyPriceLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyNameShowLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    
   
    enum tag {
    case nameCompany
    case money
    case image
    }
    func reloadAllComponents() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.creataDictanory()
        self.companyPickerView.delegate = self
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.startAnimating()
        
        self.reqestQuoteUpdate()
        

    }
    
    
    

    
    func creataDictanory() -> [String:String]{
        var dict : [String:String] = [:]
        struct GroceryProduct: Decodable {
            var symbol: String
            var companyName: String
            
        }
        
        let url = URL(string: "https://api.iextrading.com/1.0/stock/market/list/infocus")!
        
        let dataTask = URLSession.shared.dataTask(with: url ) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("Network error")
                    return
            }
            
            do {
            let cource =  try  JSONDecoder().decode([GroceryProduct].self, from: data)
               
                for obj in cource {
                    dict[obj.companyName] =  obj.symbol
                }
                
              print(dict)
            } catch {
                
            }
            
            
            
        }
        dataTask.resume()
        return dict
    }
    
    
    
    func reqestQuote(for symbol: String) {
        let url = URL(string: "https://api.iextrading.com/1.0//stock/\(symbol)/company")!
        let url2 = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/delayed-quote")!
        let url3 = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/logo")!
        let dataTask = URLSession.shared.dataTask(with: url ) { (data, response, error) in
            guard
            error == nil,
            (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
            else {
                print("Network error")
                return
            }
            self.parseQuote(data:data, tagName: .nameCompany)
        }
        let dataTask2 = URLSession.shared.dataTask(with: url2 ) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("Network error")
                    return
            }
            self.parseQuote(data:data, tagName:.money)
        }
        let dataTask3 = URLSession.shared.dataTask(with: url3 ) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("Network error")
                    return
            }
            self.parseQuote(data:data, tagName:.image)
        }
        dataTask.resume()
        dataTask2.resume()
        dataTask3.resume()
    }
    
    
    func parseQuote(data : Data, tagName : tag) {
        switch tagName {
        case .nameCompany:
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)

                guard
                    let json = jsonObject as? [String: Any],
                    let companyName = json["companyName"] as? String,
                    let symbol = json["symbol"] as? String,
                    let CEO = json["CEO"] as? String,
                    let website = json["website"] as? String
                    
                    else {
                        print("Invalid json format")
                        return
                }
                DispatchQueue.main.async {
                    self.displayStockInfo(companyName: companyName, symbol:symbol, CEO:CEO, website:website)
                }
            } catch {
                print("JSON parsing error" + error.localizedDescription)
            }
        case .money:
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [String: Any],
                    let delayedPrice = json["delayedPrice"] as? Double
                    
                    else {
                        print("Invalid json format")
                        return
                }
                DispatchQueue.main.async {
                    self.displayStockInfo(delayedPrice: delayedPrice)
                }
            } catch {
                print("JSON parsing error" + error.localizedDescription)
            }
        case .image:
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [String: Any],
                    let imageForCite = json["url"] as? String
                    
                    else {
                        print("Invalid json format")
                        return
                }
                DispatchQueue.main.async {
                    self.displayStockInfo(imageForCite: imageForCite)
                }
            } catch {
                print("JSON parsing error" + error.localizedDescription)
            }
        }
        
    }
    
    func displayStockInfo(companyName:String, symbol:String,CEO:String, website:String) {
        self.indicatorView.stopAnimating()
        self.companyNameShowLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.companyPriceChangeLabel.text = CEO
      
    }
    
    func displayStockInfo(imageForCite:String) {
        self.indicatorView.stopAnimating()
       
        
        let url = URL(string:imageForCite)!
        let dataTask = URLSession.shared.dataTask(with: url ) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("Network error")
                    return }
            
            
            let image = UIImage(data: data)
            guard let name = image else {return}
            DispatchQueue.main.async {
                self.logoImageView.image = name
            }
            
            
            
        }
        dataTask.resume()
    }
    
    func displayStockInfo(delayedPrice:Double) {
        self.indicatorView.stopAnimating()
        if delayedPrice > 1000 {
            self.companyPriceLabel.textColor = UIColor.green
        } else {
            self.companyPriceLabel.textColor = UIColor.red
        }
        self.companyPriceLabel.text = "\(delayedPrice)"
    }
    

    
    func reqestQuoteUpdate() {
        
        self.indicatorView.startAnimating()
        self.companyNameShowLabel.text = "-"
        self.companyPriceLabel.text = "-"
        self.companyPriceLabel.textColor = UIColor.black
        self.companySymbolLabel.text = "-"
        self.companyPriceChangeLabel.text = "-"
        self.logoImageView.image = nil
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
       
        self.reqestQuote(for: selectedSymbol)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        self.reqestQuoteUpdate()
    }
}
