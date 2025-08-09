(ns org.foo.myscript
  (:require [reagent.dom :as dom]
            [reagent.core :as r]
            [ajax.core :refer [POST]]))

(defonce app-state (r/atom {:result nil
                           :loading false
                           :error nil
                           :request-id nil}))

(defn generate-request-id []
  (str (random-uuid)))

(defn call-backend [numbers]
  (let [request-id (generate-request-id)]
    (js/console.log "FlowStorm Trace: Generating request ID:" request-id)
    (swap! app-state assoc :loading true :error nil :request-id request-id)
    (POST "http://localhost:3000/api/calculate"
          {:params          {:numbers numbers}
           :headers         {"X-Request-ID" request-id
                             "Content-Type" "application/json"}
           :format          :json
           :response-format :json
           :handler         (fn [response]
                              (js/console.log "FlowStorm Trace: Received response for request:" request-id)
                              (swap! app-state assoc
                                     :loading false
                                     :result response
                                     :error nil))
           :error-handler   (fn [error]
                              (js/console.log "FlowStorm Trace: Error for request:" request-id error)
                              (swap! app-state assoc
                                     :loading false
                                     :error (str "Request failed: " (get-in error [:response :status-text]))
                                     :result nil))})))

(defn calculate-button []
  [:div
   [:h2 "Full-Stack FlowStorm Demo"]
   [:p "Click the button to trigger a backend calculation and trace the full request flow in FlowStorm."]
   [:button
    {:on-click (fn []
                 (js/console.log "FlowStorm Trace: Button clicked, calling backend")
                 (call-backend [10 20 30]))
     :disabled (:loading @app-state)}
    (if (:loading @app-state)
      "Calculating..."
      "Calculate on Backend")]
   [:div
    (when (:loading @app-state)
      [:p "Loading..."])
    (when (:result @app-state)
      [:div
       [:h3 "Result:"]
       [:p (str (:result @app-state))]
       [:p [:small "Request ID: " (:request-id @app-state)]]])
    (when (:error @app-state)
      [:div
       [:h3 "Error:"]
       [:p {:style {:color "red"}} (:error @app-state)]])]])

(defn app []
  [:div
   [calculate-button]])

(defn init []
  (js/console.log "FlowStorm Demo App Starting...")
  (dom/render [app] (.getElementById js/document "app")))

(init)
