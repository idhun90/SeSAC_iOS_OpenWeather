import Foundation
import CoreLocation

import Alamofire
import SwiftyJSON

class OpenWeatherAPIManager {
    
    private init() {}
    
    static let shared = OpenWeatherAPIManager()
    
    func requestOpenWeather(lat: CLLocationDegrees, lon: CLLocationDegrees, completionHandler: @escaping (Weather) -> ()) {
        //let url = "\(EndPoint.openWeatherURL)?lat={lat}&lon={lon}&appid=\(APIKey.OepnWeather)&lang=kr"
        let url = "\(EndPoint.openWeatherURL)?lat=\(lat)&lon=\(lon)&appid=\(APIKey.OepnWeather)&lang=kr"
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                print("=============")
                
                let value = Weather(temp: json["main"]["temp"].doubleValue, feelsLikeTemp: json["main"]["feels_like"].doubleValue, humidity: json["main"]["humidity"].intValue, windSpeed: json["wind"]["speed"].doubleValue)
                
                completionHandler(value)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestCityName(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/geo/1.0/reverse?lat=\(lat)&lon=\(lon)&appid=\(APIKey.OepnWeather)"
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                print("=============")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
//
//    집 주소
//    북 37.65809°, 동 127.04545°
    // 좌표로 지역 이름
//http://api.openweathermap.org/geo/1.0/reverse?lat={lat}&lon={lon}&limit={limit}&appid={API key}

}

