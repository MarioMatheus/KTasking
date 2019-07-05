import LoggerAPI
import Health
import KituraContracts

fileprivate let healthRoute = Routes.health.rawValue

func initializeHealthRoutes(app: App) {
    
    app.router.get(healthRoute) { (respondWith: (Status?, RequestError?) -> Void) -> Void in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
    
}
