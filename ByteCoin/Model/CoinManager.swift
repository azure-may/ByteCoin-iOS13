//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, coinModel: CoinModel)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest-sandbox.coinapi.io/v1/exchangerate/BTC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(S.key)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlQuery: String) {
        if let url = URL(string: urlQuery) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    if let coinData = self.parseJSON(safeData){
                        self.delegate?.didUpdateRate(self, coinModel: coinData)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ bytcoinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: bytcoinData)
            let rate = String(format: "%.4f", decodedData.rate)
            let curr = decodedData.asset_id_quote
            let coinModel = CoinModel(rate: rate, curr: curr)
            return coinModel
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
}
