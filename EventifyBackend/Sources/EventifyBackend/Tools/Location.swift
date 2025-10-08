
import Foundation

//MARK: - Pendiente todavia de implementar,no dio tiempo en Front.
struct Location {
    let lat: Double
    let lon: Double
}


//Formula de Haversine útil para cuando proximamente implementemos la localizacion para asi obtener los lugares cercanos.
extension Location {
    func distance(to other: Location) -> Double {
        let R = 6371.0
        let dLat = (other.lat - self.lat) * .pi / 180
        let dLon = (other.lon - self.lon) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(self.lat * .pi / 180) * cos(other.lat * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}

