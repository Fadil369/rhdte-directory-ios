# BrainSAIT Unified Dashboard

## Overview
A comprehensive, single-screen dashboard that integrates:
- **PayLinc**: Saudi Digital Payment Platform (Stripe, PayPal, SARIE, Mada)
- **16 Healthcare & Business Agents**: Complete workflow automation
- **Real-time Monitoring**: System health and performance metrics
- **Bilingual Support**: Full Arabic/English interface

## Quick Start

### Open Dashboard
```bash
cd ~/UnifiedDashboard/src
open index.html
```

Or run with live server:
```bash
cd ~/UnifiedDashboard/src
python3 -m http.server 8080
# Visit http://localhost:8080
```

## Features

✅ **Payment Platform (PayLinc)** - Stripe, PayPal, SARIE, Mada integration  
✅ **Healthcare Agents** - DoctorLINC, NurseLINC, PatientLINC, CareTeamLINC  
✅ **Business Agents** - BizLINC, PayLINC, InsightLINC, AuthLINC, OIDLINC  
✅ **Automation Agents** - DevLINC, AutoLINC, CodeLINC  
✅ **Content Agents** - MediaLINC, EduLINC, ChatLINC  
✅ **Real-time Metrics** - Revenue, transactions, uptime  
✅ **System Monitoring** - Infrastructure health, active workflows  

## Agent Endpoints

### Local Development
```
Core: http://localhost:8000 (MasterLINC)
Healthcare: http://localhost:8010-8013
Business: http://localhost:8020-8022
Automation: http://localhost:8030-8032
Content: http://localhost:8040-8042
```

### Production (Cloudflare Tunnels)
```
https://doctor.brainsait.io
https://pay.brainsait.io
https://auto.brainsait.io
... and 13 more agents
```

## Integration with PayLinc

The dashboard displays:
- Real-time transaction data
- Payment channel status (Stripe, PayPal, SARIE)
- Healthcare claim processing
- Shariah-compliant BNPL tracking
- Multi-currency wallet balances

## Next Steps

1. ✅ Dashboard created and ready to use
2. ⏭️ Deploy agents using provided Docker Compose files
3. ⏭️ Configure Cloudflare Tunnels for production access
4. ⏭️ Integrate live payment APIs (Stripe, PayPal, SARIE)
5. ⏭️ Connect to NPHIES for healthcare workflows

## Support
Email: fadil@brainsait.io  
Version: 1.0.0  
License: MIT
