"""
PayLinc Integration Module
Connects unified dashboard to PayLinc payment platform
OID: 1.3.6.1.4.1.61026
"""

import asyncio
from typing import Dict, List, Any, Optional
from datetime import datetime
import httpx
from dataclasses import dataclass
import json

# PayLinc API Configuration
PAYLINC_BASE_URL = "https://api.paylinc.sa/v1"
PAYLINC_WEBSOCKET_URL = "wss://ws.paylinc.sa"

@dataclass
class PaymentTransaction:
    """Payment transaction model"""
    id: str
    gateway: str  # paylinc, stripe, paypal, sarie, mada, nphies
    amount: float
    currency: str
    status: str
    timestamp: datetime
    metadata: Dict[str, Any]

@dataclass
class AgentStatus:
    """LINC Agent status model"""
    agent_id: str
    name: str
    category: str  # healthcare, business, automation, content, security
    status: str  # active, inactive, error
    health: str  # healthy, degraded, unhealthy
    metrics: Dict[str, Any]

class PayLincIntegration:
    """Integration with PayLinc payment platform"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.client = httpx.AsyncClient(
            base_url=PAYLINC_BASE_URL,
            headers={"Authorization": f"Bearer {api_key}"}
        )
    
    async def get_wallet_overview(self) -> Dict[str, Any]:
        """Get PayLinc wallet overview"""
        response = await self.client.get("/wallet/overview")
        return response.json()
    
    async def get_healthcare_payments(self) -> List[PaymentTransaction]:
        """Get healthcare payment transactions"""
        response = await self.client.get("/healthcare/payments/recent")
        data = response.json()
        
        return [
            PaymentTransaction(
                id=p["payment_id"],
                gateway="nphies",
                amount=p["amount"],
                currency=p["currency"],
                status=p["status"],
                timestamp=datetime.fromisoformat(p["created_at"]),
                metadata=p.get("metadata", {})
            )
            for p in data.get("payments", [])
        ]
    
    async def get_murabaha_bnpl_status(self) -> Dict[str, Any]:
        """Get Murabaha BNPL (Buy Now Pay Later) status"""
        response = await self.client.get("/bnpl/murabaha/overview")
        return response.json()
    
    async def get_sarie_settlements(self) -> List[Dict[str, Any]]:
        """Get SARIE instant payment settlements"""
        response = await self.client.get("/sarie/settlements/recent")
        return response.json().get("settlements", [])
    
    async def check_nphies_eligibility(self, national_id: str) -> Dict[str, Any]:
        """Check NPHIES patient eligibility"""
        response = await self.client.get(
            f"/healthcare/eligibility/{national_id}"
        )
        return response.json()
    
    async def get_cross_border_transactions(self) -> List[PaymentTransaction]:
        """Get cross-border payment transactions"""
        response = await self.client.get("/payments/cross-border")
        data = response.json()
        
        return [
            PaymentTransaction(
                id=p["cross_border_id"],
                gateway="paylinc",
                amount=p["recipient_amount"],
                currency=p["recipient_currency"],
                status=p.get("status", "completed"),
                timestamp=datetime.fromisoformat(p["created_at"]),
                metadata={
                    "sender_country": p["sender_country"],
                    "recipient_country": p["recipient_country"],
                    "fx_rate": p["fx_rate"]
                }
            )
            for p in data.get("payments", [])
        ]
    
    async def get_shariah_compliance_status(self) -> Dict[str, Any]:
        """Get Shariah compliance certification status"""
        response = await self.client.get("/compliance/shariah/status")
        return response.json()
    
    async def close(self):
        """Close the HTTP client"""
        await self.client.aclose()

class LINCAgentMonitor:
    """Monitor all 16 LINC agents"""
    
    AGENT_REGISTRY = {
        # Healthcare Agents
        "masterlinc": {"port": 8000, "category": "security"},
        "authlinc": {"port": 8001, "category": "security"},
        "doctorlinc": {"port": 8010, "category": "healthcare"},
        "nurslinc": {"port": 8011, "category": "healthcare"},
        "patientlinc": {"port": 8012, "category": "healthcare"},
        "careteamlinc": {"port": 8013, "category": "healthcare"},
        
        # Business Agents
        "bizlinc": {"port": 8020, "category": "business"},
        "paylinc": {"port": 8021, "category": "business"},
        "insightlinc": {"port": 8022, "category": "business"},
        
        # Automation Agents
        "devlinc": {"port": 8030, "category": "automation"},
        "autolinc": {"port": 8031, "category": "automation"},
        "codelinc": {"port": 8032, "category": "automation"},
        
        # Content Agents
        "medialinc": {"port": 8040, "category": "content"},
        "edulinc": {"port": 8041, "category": "content"},
        "chatlinc": {"port": 8042, "category": "content"},
        
        # Identity Agent
        "oidlinc": {"port": 8050, "category": "security"}
    }
    
    async def check_agent_health(self, agent_id: str) -> AgentStatus:
        """Check health of specific agent"""
        config = self.AGENT_REGISTRY.get(agent_id)
        if not config:
            raise ValueError(f"Unknown agent: {agent_id}")
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"http://localhost:{config['port']}/health",
                    timeout=5.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    return AgentStatus(
                        agent_id=agent_id,
                        name=agent_id.upper(),
                        category=config["category"],
                        status="active",
                        health="healthy",
                        metrics=data.get("metrics", {})
                    )
        except Exception as e:
            return AgentStatus(
                agent_id=agent_id,
                name=agent_id.upper(),
                category=config["category"],
                status="inactive",
                health="unhealthy",
                metrics={"error": str(e)}
            )
    
    async def check_all_agents(self) -> List[AgentStatus]:
        """Check health of all agents"""
        tasks = [
            self.check_agent_health(agent_id)
            for agent_id in self.AGENT_REGISTRY.keys()
        ]
        return await asyncio.gather(*tasks)

class UnifiedDashboardService:
    """Main service orchestrating all integrations"""
    
    def __init__(self, paylinc_api_key: str):
        self.paylinc = PayLincIntegration(paylinc_api_key)
        self.agent_monitor = LINCAgentMonitor()
    
    async def get_complete_overview(self) -> Dict[str, Any]:
        """Get complete dashboard overview"""
        
        # Gather all data concurrently
        wallet_data, healthcare_data, bnpl_data, agents_data = await asyncio.gather(
            self.paylinc.get_wallet_overview(),
            self.paylinc.get_healthcare_payments(),
            self.paylinc.get_murabaha_bnpl_status(),
            self.agent_monitor.check_all_agents(),
            return_exceptions=True
        )
        
        # Calculate totals
        total_revenue = 0
        if isinstance(wallet_data, dict):
            total_revenue += wallet_data.get("sar_balance", 0)
        
        # Count active agents
        active_agents = sum(
            1 for agent in agents_data 
            if isinstance(agent, AgentStatus) and agent.status == "active"
        )
        
        return {
            "timestamp": datetime.now().isoformat(),
            "overview": {
                "total_revenue": total_revenue,
                "active_agents": active_agents,
                "total_agents": len(self.agent_monitor.AGENT_REGISTRY),
                "today_transactions": len(healthcare_data) if isinstance(healthcare_data, list) else 0
            },
            "paylinc": {
                "wallet": wallet_data if not isinstance(wallet_data, Exception) else {},
                "healthcare": healthcare_data if not isinstance(healthcare_data, Exception) else [],
                "bnpl": bnpl_data if not isinstance(bnpl_data, Exception) else {}
            },
            "agents": {
                "status": [
                    {
                        "agent_id": agent.agent_id,
                        "name": agent.name,
                        "category": agent.category,
                        "status": agent.status,
                        "health": agent.health
                    }
                    for agent in agents_data
                    if isinstance(agent, AgentStatus)
                ]
            }
        }
    
    async def get_payment_analytics(self) -> Dict[str, Any]:
        """Get payment analytics across all channels"""
        
        # Get data from all payment channels
        healthcare_payments = await self.paylinc.get_healthcare_payments()
        cross_border = await self.paylinc.get_cross_border_transactions()
        sarie_settlements = await self.paylinc.get_sarie_settlements()
        
        # Aggregate by gateway
        by_gateway = {}
        all_transactions = healthcare_payments + cross_border
        
        for txn in all_transactions:
            if txn.gateway not in by_gateway:
                by_gateway[txn.gateway] = {
                    "count": 0,
                    "total": 0,
                    "currency": txn.currency
                }
            
            by_gateway[txn.gateway]["count"] += 1
            by_gateway[txn.gateway]["total"] += txn.amount
        
        return {
            "by_gateway": by_gateway,
            "total_transactions": len(all_transactions),
            "sarie_settlements": len(sarie_settlements),
            "total_volume": sum(txn.amount for txn in all_transactions)
        }
    
    async def close(self):
        """Close all connections"""
        await self.paylinc.close()

# Example usage
async def main():
    """Example usage of unified dashboard service"""
    
    # Initialize service (use your actual API key)
    service = UnifiedDashboardService(paylinc_api_key="your_api_key_here")
    
    try:
        # Get complete overview
        overview = await service.get_complete_overview()
        print("Dashboard Overview:")
        print(json.dumps(overview, indent=2, default=str))
        
        # Get payment analytics
        analytics = await service.get_payment_analytics()
        print("\nPayment Analytics:")
        print(json.dumps(analytics, indent=2, default=str))
        
    finally:
        await service.close()

if __name__ == "__main__":
    asyncio.run(main())
