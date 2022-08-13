import UIKit
import CoreLocation

import Alamofire
import SwiftyJSON
import Kingfisher

class OpenWeatherViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel! //습도 %
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var feelsLikeTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet var labelBackgroundViewlist: [UIView]!
    @IBOutlet var weatherLabelList: [UILabel]!
    
    let locationManager = CLLocationManager()
    var wheaterData: Weather?

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        currentTime()
        
        locationManager.delegate = self
        
        
    }
        
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 접근 불가", message: "기기의 설정에서 위치 서비스를 활성화해주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        
        requestLocationServiceAlert.addAction(goSetting)
        requestLocationServiceAlert.addAction(cancel)
        
        present(requestLocationServiceAlert, animated: true, completion: nil)
    }

    func layout() {
        for count in 0...labelBackgroundViewlist.count - 1 {
            labelBackgroundViewlist[count].backgroundColor = .white
            labelBackgroundViewlist[count].layer.cornerRadius = 7
        }
        
        for count in 0...weatherLabelList.count - 1 {
            weatherLabelList[count].text = "위치 서비스가 꺼져 있음"
        }
        
        locationLabel.font = .systemFont(ofSize: 28)
        dateLabel.font = .systemFont(ofSize: 13)
        tempLabel.font = .systemFont(ofSize: 15)
        humidityLabel.font = .systemFont(ofSize: 15)
        windSpeedLabel.font = .systemFont(ofSize: 15)
        feelsLikeTempLabel.font = .systemFont(ofSize: 15)
        iconImageView.backgroundColor = .white
        iconImageView.layer.cornerRadius = 7
    }
    
    func currentTime() {
        let date = DateFormatter()
        date.dateFormat = "M월 dd일 hh시 mm분"
        date.locale = Locale(identifier: "ko_KR")
        
        let currentDate = Date()
        dateLabel.text = date.string(from: currentDate)
        
    }
}
//MARK: - 위치 서비스 관련 메소드
extension OpenWeatherViewController {
    
    //MARK: 위치 서비스 활성화 체크
    func checkDeviceLocationServiceAuthorzation() {
        
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            checkUserCurrentLocationAuthorization(authorizationStatus)
        } else {
            print("위치 서비스가 비활성화 상태입니다.")
        }
    }
    
    //MARK: 앱 위치 접근 허용 체크
    func checkUserCurrentLocationAuthorization(_ authorizationstatus: CLAuthorizationStatus) {
        
        switch authorizationstatus {
        case .notDetermined:
            print("권한 팝업 띄워진 상태")
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            print("권한 사용 불가 또는 거부된 상태")
            showRequestLocationServiceAlert()
            
        case .authorizedAlways:
            print("항상 허용, 먼저 WehnInUse 호출")
            
        case .authorizedWhenInUse:
            print("앱을 사용하는 동안 허용")
            locationManager.startUpdatingLocation()
            
        default:
            print("오류 발생")
        }
        
    }
}

//MARK: - CLLocationDelegate
extension OpenWeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, "-> 사용자 위치를 가져왔습니다.")
        
        
        if let coodinate = locations.last?.coordinate {
            print("현재 위치 latitude 좌표 = \(coodinate.latitude)")
            print("현재 위치 longitude 좌표 = \(coodinate.longitude)")
            
            OpenWeatherAPIManager.shared.requestCity(lat: coodinate.latitude, lon: coodinate.longitude) { value in
                self.locationLabel.text = value
            }
            
            OpenWeatherAPIManager.shared.requestOpenWeather(lat: coodinate.latitude, lon: coodinate.longitude) { [self] value in
                self.wheaterData = value
                
                guard let wheaterData = self.wheaterData else { return }
                
                let temp = String(format: "%.f", wheaterData.temp - 273.15)
                let fellsLikeTemp = String(format: "%.f", wheaterData.feelsLikeTemp - 273.15)
                let humidity = wheaterData.humidity
                let windSpeed = String(format: "%.1f", wheaterData.windSpeed)
                let iconUrl = "\(EndPoint.icodnURL)/\(wheaterData.icon)@2x.png"
                let url = URL(string: iconUrl)
                
                self.tempLabel.text = "지금은 \(temp)℃에요"
                self.feelsLikeTempLabel.text = "체감온도는 \(fellsLikeTemp)℃에요"
                self.humidityLabel.text = "\(humidity)% 만큼 습해요"
                self.windSpeedLabel.text = "\(windSpeed)m/s의 바람이 불고 있어요"
                self.iconImageView.kf.setImage(with: url)
            }
            
//            OpenWeatherAPIManager.shared.requestCityName(lat: coodinate.latitude, lon: coodinate.longitude) { value in
//                
//                self.locationLabel.text = value
//            }
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "-> 사용자 위치를 가져오지 못 했습니다.")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function,"-> 권한 상태가 변경되었습니다.")
        checkDeviceLocationServiceAuthorzation()
    }
    
}
