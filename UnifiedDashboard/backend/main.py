"""
BrainSAIT Unified Dashboard - Backend API
FastAPI-based backend for unified dashboard observability
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from typing import Dict, List, Any
import asyncio
import json
from datetime import datetime
from pathlib import Path
import sqlite3

# Initialize FastAPI app
app = FastAPI(
    title="BrainSAIT Unified Dashboard API",
    version="1.0.0",
    description="Unified observability platform for payments, agents, and workflows"
)

# CORS middleware for macOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
    
    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                pass

manager = ConnectionManager()

# Database initialization
def init_db():
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    # Payment transactions table
    c.execute('''CREATE TABLE IF NOT EXISTS payments
                 (id TEXT PRIMARY KEY,
                  gateway TEXT,
                  amount REAL,
                  currency TEXT,
                  status TEXT,
                  timestamp DATETIME,
                  metadata TEXT)''')
    
    # Agent status table
    c.execute('''CREATE TABLE IF NOT EXISTS agent_status
                 (agent_id TEXT PRIMARY KEY,
                  name TEXT,
                  status TEXT,
                  health TEXT,
                  last_heartbeat DATETIME,
                  metrics TEXT)''')
    
    # Workflow tasks table
    c.execute('''CREATE TABLE IF NOT EXISTS workflows
                 (id TEXT PRIMARY KEY,
                  name TEXT,
                  status TEXT,
                  agent_id TEXT,
                  created_at DATETIME,
                  updated_at DATETIME,
                  data TEXT)''')
    
    conn.commit()
    conn.close()

init_db()

# ============================================================================
# PAYMENT ENDPOINTS
# ============================================================================

@app.get("/api/v1/payments/overview")
async def get_payment_overview():
    """Get payment channels overview"""
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    # Get payment statistics
    c.execute('''SELECT gateway, COUNT(*), SUM(amount), AVG(amount)
                 FROM payments
                 WHERE date(timestamp) = date('now')
                 GROUP BY gateway''')
    
    stats = {}
    for row in c.fetchall():
        stats[row[0]] = {
            "count": row[1],
            "total": row[2],
            "average": row[3]
        }
    
    conn.close()
    
    return {
        "paylinc": {
            "status": "active",
            "today_volume": stats.get("paylinc", {}).get("total", 0),
            "transactions": stats.get("paylinc", {}).get("count", 0),
            "channels": {
                "wallet": "active",
                "healthcare": "active",
                "bnpl": "active",
                "cross_border": "active"
            }
        },
        "stripe": {
            "status": "active",
            "today_volume": stats.get("stripe", {}).get("total", 0),
            "transactions": stats.get("stripe", {}).get("count", 0)
        },
        "paypal": {
            "status": "active",
            "today_volume": stats.get("paypal", {}).get("total", 0),
            "transactions": stats.get("paypal", {}).get("count", 0)
        },
        "sarie": {
            "status": "active",
            "today_volume": stats.get("sarie", {}).get("total", 0),
            "transactions": stats.get("sarie", {}).get("count", 0)
        },
        "nphies": {
            "status": "active",
            "claims_processed": stats.get("nphies", {}).get("count", 0),
            "total_amount": stats.get("nphies", {}).get("total", 0)
        }
    }

@app.get("/api/v1/payments/recent")
async def get_recent_payments(limit: int = 50):
    """Get recent payment transactions"""
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    c.execute('''SELECT * FROM payments
                 ORDER BY timestamp DESC
                 LIMIT ?''', (limit,))
    
    payments = []
    for row in c.fetchall():
        payments.append({
            "id": row[0],
            "gateway": row[1],
            "amount": row[2],
            "currency": row[3],
            "status": row[4],
            "timestamp": row[5],
            "metadata": json.loads(row[6]) if row[6] else {}
        })
    
    conn.close()
    return {"payments": payments}

# ============================================================================
# AGENT ENDPOINTS
# ============================================================================

@app.get("/api/v1/agents/status")
async def get_agents_status():
    """Get status of all LINC agents"""
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    c.execute('SELECT * FROM agent_status')
    
    agents = {
        "healthcare": [],
        "business": [],
        "automation": [],
        "content": [],
        "security": []
    }
    
    for row in c.fetchall():
        agent = {
            "agent_id": row[0],
            "name": row[1],
            "status": row[2],
            "health": row[3],
            "last_heartbeat": row[4],
            "metrics": json.loads(row[5]) if row[5] else {}
        }
        
        # Categorize agents
        if "LINC" in row[1]:
            if any(x in row[1] for x in ["Doctor", "Nurse", "Patient", "CareTeam"]):
                agents["healthcare"].append(agent)
            elif any(x in row[1] for x in ["Biz", "Pay", "Insight"]):
                agents["business"].append(agent)
            elif any(x in row[1] for x in ["Dev", "Auto", "Code"]):
                agents["automation"].append(agent)
            elif any(x in row[1] for x in ["Media", "Edu", "Chat"]):
                agents["content"].append(agent)
            elif any(x in row[1] for x in ["Master", "Auth", "OID"]):
                agents["security"].append(agent)
    
    conn.close()
    return agents

@app.get("/api/v1/agents/{agent_id}")
async def get_agent_details(agent_id: str):
    """Get detailed information about specific agent"""
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    c.execute('SELECT * FROM agent_status WHERE agent_id = ?', (agent_id,))
    row = c.fetchone()
    
    if not row:
        return {"error": "Agent not found"}
    
    agent = {
        "agent_id": row[0],
        "name": row[1],
        "status": row[2],
        "health": row[3],
        "last_heartbeat": row[4],
        "metrics": json.loads(row[5]) if row[5] else {},
        "recent_tasks": []
    }
    
    # Get recent workflow tasks
    c.execute('''SELECT * FROM workflows
                 WHERE agent_id = ?
                 ORDER BY updated_at DESC
                 LIMIT 10''', (agent_id,))
    
    for task_row in c.fetchall():
        agent["recent_tasks"].append({
            "id": task_row[0],
            "name": task_row[1],
            "status": task_row[2],
            "created_at": task_row[4],
            "updated_at": task_row[5]
        })
    
    conn.close()
    return agent

# ============================================================================
# WORKFLOW ENDPOINTS
# ============================================================================

@app.get("/api/v1/workflows/active")
async def get_active_workflows():
    """Get currently active workflows"""
    conn = sqlite3.connect('dashboard.db')
    c = conn.cursor()
    
    c.execute('''SELECT * FROM workflows
                 WHERE status IN ('running', 'pending')
                 ORDER BY created_at DESC''')
    
    workflows = []
    for row in c.fetchall():
        workflows.append({
            "id": row[0],
            "name": row[1],
            "status": row[2],
            "agent_id": row[3],
            "created_at": row[4],
            "updated_at": row[5],
            "data": json.loads(row[6]) if row[6] else {}
        })
    
    conn.close()
    return {"workflows": workflows}

# ============================================================================
# WEBSOCKET ENDPOINT FOR REAL-TIME UPDATES
# ============================================================================

@app.websocket("/ws/dashboard")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time dashboard updates"""
    await manager.connect(websocket)
    try:
        while True:
            # Send periodic updates
            await asyncio.sleep(5)
            
            # Broadcast current status
            status = {
                "timestamp": datetime.now().isoformat(),
                "payments": await get_payment_overview(),
                "agents": await get_agents_status(),
                "workflows": await get_active_workflows()
            }
            
            await websocket.send_json(status)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "BrainSAIT Unified Dashboard API",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

# ============================================================================
# SERVER-SENT EVENTS FOR LIVE UPDATES
# ============================================================================

async def event_generator():
    """Generate server-sent events for live updates"""
    while True:
        # Get current dashboard state
        data = {
            "timestamp": datetime.now().isoformat(),
            "payments": await get_payment_overview(),
            "agents": await get_agents_status()
        }
        
        yield f"data: {json.dumps(data)}\n\n"
        await asyncio.sleep(2)

@app.get("/api/v1/stream/dashboard")
async def stream_dashboard():
    """Server-sent events endpoint for dashboard updates"""
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream"
    )

# ============================================================================
# RUN SERVER
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
