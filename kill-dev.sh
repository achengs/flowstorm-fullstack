#!/bin/bash

echo "🛑 Killing all FlowStorm development processes..."

# Kill FlowStorm debugger processes
echo "Killing FlowStorm debuggers..."
pkill -f "flow-storm-dbg" 2>/dev/null && echo "✅ FlowStorm debuggers killed" || echo "ℹ️  No FlowStorm debuggers running"

# Kill shadow-cljs processes
echo "Killing shadow-cljs..."
pkill -f "shadow-cljs" 2>/dev/null && echo "✅ shadow-cljs killed" || echo "ℹ️  No shadow-cljs running"

# Kill nREPL server processes
echo "Killing nREPL server..."
pkill -f "nrepl.server" 2>/dev/null && echo "✅ nREPL server killed" || echo "ℹ️  No nREPL server running"

# Kill backend server processes
echo "Killing backend server..."
pkill -f "org.foo.backend.core" 2>/dev/null && echo "✅ Backend server killed" || echo "ℹ️  No backend server running"

# Alternative: Kill by port if processes are stubborn
echo "Checking for stubborn processes on ports..."

# Function to kill process using a specific port
kill_port() {
    local port=$1
    local pid=$(lsof -ti :$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        kill -9 $pid 2>/dev/null && echo "✅ Killed process on port $port (PID: $pid)"
    else
        echo "ℹ️  Port $port is free"
    fi
}

kill_port 7722  # Frontend FlowStorm
kill_port 7888  # nREPL server
kill_port 8021  # Frontend HTTP server
kill_port 3000  # Backend HTTP server

echo "🎉 All processes cleaned up! Ready to run ./start-dev.sh"