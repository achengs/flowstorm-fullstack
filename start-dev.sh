#!/bin/bash

echo "🚀 Starting Full-Stack FlowStorm Development Environment"
echo "=========================================================="

# Check for node_modules and prompt to install if missing
if [ ! -d "node_modules" ]; then
    echo "⚠️ Node modules not found. It seems you haven't run 'npm install'."
    read -p "Do you want to run 'npm install' now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Running 'npm install'..."
        npm install
        if [ $? -ne 0 ]; then
            echo "❌ 'npm install' failed. Please run it manually and then restart the script."
            exit 1
        fi
        echo "✅ 'npm install' complete."
    else
        echo "🛑 Please run 'npm install' manually and then restart the script."
        exit 1
    fi
fi

# Check if ports are available
if lsof -i :7722 >/dev/null 2>&1; then
    echo "❌ Port 7722 (Frontend FlowStorm) is busy"
    echo "   Kill existing process: pkill -f flow-storm"
    exit 1
fi

# Backend FlowStorm no longer uses separate port - using local debugging

if lsof -i :8021 >/dev/null 2>&1; then
    echo "❌ Port 8021 (Frontend HTTP) is busy"
    echo "   Kill existing process: pkill -f shadow-cljs"
    exit 1
fi

if lsof -i :3000 >/dev/null 2>&1; then
    echo "❌ Port 3000 (Backend HTTP) is busy"
    echo "   Kill existing process: pkill -f 'backend.core'"
    exit 1
fi

if lsof -i :7888 >/dev/null 2>&1; then
    echo "❌ Port 7888 (nREPL) is busy"
    echo "   Kill existing process: pkill -f 'nrepl.server'"
    exit 1
fi

echo "✅ All ports available"
echo ""

# Start FlowStorm debuggers
echo "🔍 Starting Frontend FlowStorm Debugger (port 7722)..."
clj -A:cljs-storm -Sforce -Sdeps '{:deps {com.github.flow-storm/flow-storm-dbg {:mvn/version "RELEASE"}}}' \
    -X flow-storm.debugger.main/start-debugger \
    :repl-type :shadow :build-id :dev-test :ws-port 7722 &
FRONTEND_FLOWSTORM_PID=$!

sleep 3

# Backend FlowStorm will be embedded in backend server process (local debugging)

# Start application servers
echo "🌐 Starting Frontend Server (shadow-cljs on port 8021)..."
npx shadow-cljs watch :dev-test &
FRONTEND_PID=$!

sleep 5

echo "🔌 Starting nREPL Server (port 7888)..."
clj -A:backend-storm -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.1.1"}}}' -M -e "(require '[nrepl.server :as nrepl]) (nrepl/start-server :port 7888) (println \"nREPL server started on port 7888\") @(promise)" &
NREPL_PID=$!

sleep 2

echo "🔧 Starting Backend Server with FlowStorm (Ring on port 3000)..."
clj -Sforce -Sdeps '{:deps {} :aliases {:dev {:classpath-overrides {org.clojure/clojure nil} :extra-deps {com.github.flow-storm/clojure {:mvn/version "1.12.1"} com.github.flow-storm/flow-storm-dbg {:mvn/version "4.4.6"}}}}}' -A:dev -A:backend-storm -M -m org.foo.backend.core &
BACKEND_PID=$!

sleep 3

echo ""
echo "🎉 Full-Stack FlowStorm Environment Ready!"
echo "=========================================="
echo ""
echo "📱 Frontend UI: http://localhost:8021/index.html"
echo "🔍 Frontend FlowStorm: Check JavaFX window (port 7722)"
echo "🔍 Backend FlowStorm: Check JavaFX window (embedded in backend server)"
echo "🔌 nREPL: localhost:7888 (for CIDER hot-reload)"
echo "🔧 Backend API: http://localhost:3000/api/calculate"
echo ""
echo "🧪 Test the full flow:"
echo "   1. Open http://localhost:8021/index.html"
echo "   2. Click 'Calculate on Backend' button"
echo "   3. Watch traces in both FlowStorm debuggers"
echo "   4. Follow the UUID correlation across both sides"
echo ""
echo "Process IDs:"
echo "   Frontend FlowStorm: $FRONTEND_FLOWSTORM_PID"
echo "   Backend FlowStorm:  (embedded in backend server)"
echo "   nREPL Server:       $NREPL_PID"
echo "   Frontend Server:    $FRONTEND_PID"
echo "   Backend Server:     $BACKEND_PID"
echo ""
echo "💀 To stop all processes:"
echo "   kill $FRONTEND_FLOWSTORM_PID $NREPL_PID $FRONTEND_PID $BACKEND_PID"
echo ""
echo "Press Ctrl+C to stop all services..."

# Wait for user interrupt
trap 'echo ""; echo "🛑 Stopping all services..."; kill $FRONTEND_FLOWSTORM_PID $NREPL_PID $FRONTEND_PID $BACKEND_PID 2>/dev/null; echo "✅ All services stopped"; exit 0' INT

# Keep script running
wait