(ns org.foo.backend.handlers
  (:require [ring.util.response :as response]
            [cheshire.core :as json]))

(defn extract-request-id [request]
  (get-in request [:headers "x-request-id"]))

(defn log-request-id [request-id operation]
  (println (str "FlowStorm Trace [" request-id "]: " operation)))

(defn validate-input [numbers request-id]
  (log-request-id request-id "Validating input numbers")
  (if (and (vector? numbers)
           (every? number? numbers)
           (not-empty numbers))
    numbers
    (throw (ex-info "Invalid input: numbers must be a non-empty vector of numbers"
                    {:request-id request-id :input numbers}))))

(defn sum-numbers [numbers request-id]
  (log-request-id request-id "Summing all numbers")
  (reduce + numbers))

(defn apply-multiplier [sum request-id]
  (log-request-id request-id "Applying multiplier (x2)")
  (* sum 2))

(defn calculate-factorial [n request-id]
  (log-request-id request-id (str "Calculating factorial of " n))
  (if (<= n 1)
    1
    (* n (calculate-factorial (dec n) request-id))))

(defn add-bonus-calculation [result request-id]
  (log-request-id request-id "Adding bonus calculation (factorial of digit count)")
  (let [digit-count (count (str result))
        factorial-bonus (calculate-factorial digit-count request-id)]
    (+ result factorial-bonus)))

(defn format-result [final-result request-id numbers]
  (log-request-id request-id "Formatting final response")
  {:request-id request-id
   :input numbers
   :result final-result
   :message (str "Processed " (count numbers) " numbers with multi-step calculation")
   :timestamp (System/currentTimeMillis)})

(defn perform-calculation [numbers request-id]
  (log-request-id request-id "Starting multi-step calculation")
  (-> numbers
      (validate-input request-id)
      (sum-numbers request-id)
      (apply-multiplier request-id)
      (add-bonus-calculation request-id)
      (format-result request-id numbers)))

(defn calculate [request]
  (let [request-id (extract-request-id request)]
    (log-request-id request-id "Received calculate request")
    (try
      (let [body    (-> request :body slurp (json/parse-string true))
            numbers (:numbers body)]
        (log-request-id request-id (str "Processing numbers: " numbers))
        (let [result (perform-calculation numbers request-id)]
          (log-request-id request-id "Sending successful response")
          (response/response result)))
      (catch Exception e
        (log-request-id request-id (str "Error: " (.getMessage e)))
        (response/bad-request
          {:error      (.getMessage e)
           :request-id request-id})))))
