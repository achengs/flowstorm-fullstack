(ns org.foo.backend.core
  (:require [org.httpkit.server :as server]
            [reitit.ring :as ring]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.json :refer [wrap-json-response]]
            [ring.util.response :as response]
            [org.foo.backend.handlers :as handlers]
            [flow-storm.api :as fs-api]))

(def routes
  ["/api"
   ["/calculate" {:post handlers/calculate}]])

(def app
  (-> (ring/ring-handler
       (ring/router routes))
      wrap-json-response
      (wrap-cors :access-control-allow-origin [#"http://localhost:8021"]
                 :access-control-allow-methods [:get :post :put :delete]
                 :access-control-allow-headers ["Content-Type" "X-Request-ID"])))

(defonce server (atom nil))

(defn start-server []
  (when-not @server
    (println "Starting FlowStorm local debugger...")
    (try
      (fs-api/local-connect {:title "Backend FlowStorm Debugger"})
      (println "✅ FlowStorm debugger connected successfully!")
      (catch Exception e
        (println "⚠️  FlowStorm connection failed:" (.getMessage e))))
    (println "Starting backend server on http://localhost:3000")
    (reset! server (server/run-server app {:port 3000}))
    (println "Backend server started!")))

(defn stop-server []
  (when @server
    (println "Stopping backend server...")
    (@server)
    (reset! server nil)
    (println "Backend server stopped!")))

(defn -main [& args]
  (start-server)
  (println "Backend server running. Press Ctrl+C to stop."))

(comment
  (start-server)
  (stop-server))
