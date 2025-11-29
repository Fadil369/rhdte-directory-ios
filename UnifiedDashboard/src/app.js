function dashboardApp() {
    return {
        currentLang: 'en',
        currentTab: 'paylinc',
        currentDateTime: '',
        showAgentModal: false,
        selectedAgent: null,
        
        translations: {
            en: {
                title: 'BrainSAIT Unified Dashboard',
                subtitle: 'Integrated Payment, Healthcare & Automation Platform'
            },
            ar: {
                title: 'لوحة برين سايت الموحدة',
                subtitle: 'منصة متكاملة للمدفوعات والرعاية الصحية والأتمتة'
            }
        },
        
        tabs: [
            { id: 'paylinc', name: 'PayLinc', icon: 'fas fa-credit-card' },
            { id: 'healthcare', name: 'Healthcare', icon: 'fas fa-heartbeat' },
            { id: 'business', name: 'Business', icon: 'fas fa-briefcase' },
            { id: 'automation', name: 'Automation', icon: 'fas fa-robot' },
            { id: 'system', name: 'System', icon: 'fas fa-server' }
        ],
        
        metrics: [
            { id: 1, label: 'Total Revenue', value: 'SAR 2.5M', trend: 12.5, icon: 'fas fa-dollar-sign' },
            { id: 2, label: 'Active Agents', value: '16', trend: 6.2, icon: 'fas fa-robot' },
            { id: 3, label: 'Transactions', value: '45.2K', trend: 18.3, icon: 'fas fa-exchange-alt' },
            { id: 4, label: 'Uptime', value: '99.9%', trend: 0.1, icon: 'fas fa-check-circle' }
        ],
        
        paymentChannels: [
            {
                id: 1,
                name: 'Stripe',
                volume: 'SAR 1.2M',
                transactions: '12,450',
                status: 'active'
            },
            {
                id: 2,
                name: 'PayPal',
                volume: 'SAR 850K',
                transactions: '8,320',
                status: 'active'
            },
            {
                id: 3,
                name: 'SARIE',
                volume: 'SAR 450K',
                transactions: '5,180',
                status: 'active'
            }
        ],
        
        recentTransactions: [
            { id: 'TXN-001', type: 'Healthcare', amount: 'SAR 500', status: 'completed', date: '2025-11-29 10:23' },
            { id: 'TXN-002', type: 'Subscription', amount: 'SAR 299', status: 'completed', date: '2025-11-29 10:15' },
            { id: 'TXN-003', type: 'BNPL', amount: 'SAR 1,200', status: 'processing', date: '2025-11-29 09:54' },
            { id: 'TXN-004', type: 'QR Payment', amount: 'SAR 75', status: 'completed', date: '2025-11-29 09:32' },
            { id: 'TXN-005', type: 'Healthcare', amount: 'SAR 350', status: 'completed', date: '2025-11-29 09:18' }
        ],
        
        healthcareAgents: [
            {
                id: 'doctor',
                name: 'DoctorLINC',
                description: 'Clinical decision support & documentation',
                icon: 'fas fa-user-md',
                status: 'online',
                subdomain: 'doctor.brainsait.io',
                port: 8010
            },
            {
                id: 'nurse',
                name: 'NurseLINC',
                description: 'Nursing workflow automation',
                icon: 'fas fa-notes-medical',
                status: 'online',
                subdomain: 'nurse.brainsait.io',
                port: 8011
            },
            {
                id: 'patient',
                name: 'PatientLINC',
                description: 'Patient experience platform',
                icon: 'fas fa-procedures',
                status: 'online',
                subdomain: 'patient.brainsait.io',
                port: 8012
            },
            {
                id: 'careteam',
                name: 'CareTeamLINC',
                description: 'Multi-provider coordination',
                icon: 'fas fa-users',
                status: 'online',
                subdomain: 'careteam.brainsait.io',
                port: 8013
            }
        ],
        
        businessAgents: [
            {
                id: 'biz',
                name: 'BizLINC',
                description: 'Healthcare business intelligence',
                icon: 'fas fa-chart-line',
                status: 'online',
                subdomain: 'biz.brainsait.io',
                port: 8020
            },
            {
                id: 'pay',
                name: 'PayLINC',
                description: 'Payment processing',
                icon: 'fas fa-credit-card',
                status: 'online',
                subdomain: 'pay.brainsait.io',
                port: 8021
            },
            {
                id: 'insight',
                name: 'InsightLINC',
                description: 'Analytics and reporting',
                icon: 'fas fa-chart-pie',
                status: 'online',
                subdomain: 'insight.brainsait.io',
                port: 8022
            },
            {
                id: 'auth',
                name: 'AuthLINC',
                description: 'Authentication & RBAC',
                icon: 'fas fa-shield-alt',
                status: 'online',
                subdomain: 'auth.brainsait.io',
                port: 8001
            },
            {
                id: 'oid',
                name: 'OIDLINC',
                description: 'Digital identity management',
                icon: 'fas fa-id-card',
                status: 'online',
                subdomain: 'oid.brainsait.io',
                port: 8050
            }
        ],
        
        automationAgents: [
            {
                id: 'dev',
                name: 'DevLINC',
                description: 'DevOps & infrastructure',
                icon: 'fas fa-code-branch',
                status: 'online',
                subdomain: 'dev.brainsait.io',
                port: 8030
            },
            {
                id: 'auto',
                name: 'AutoLINC',
                description: 'Workflow orchestration',
                icon: 'fas fa-project-diagram',
                status: 'online',
                subdomain: 'auto.brainsait.io',
                port: 8031
            },
            {
                id: 'code',
                name: 'CodeLINC',
                description: 'Development assistance',
                icon: 'fas fa-code',
                status: 'online',
                subdomain: 'code.brainsait.io',
                port: 8032
            },
            {
                id: 'media',
                name: 'MediaLINC',
                description: 'Multimedia processing',
                icon: 'fas fa-photo-video',
                status: 'online',
                subdomain: 'media.brainsait.io',
                port: 8040
            },
            {
                id: 'edu',
                name: 'EduLINC',
                description: 'Learning management',
                icon: 'fas fa-graduation-cap',
                status: 'online',
                subdomain: 'edu.brainsait.io',
                port: 8041
            },
            {
                id: 'chat',
                name: 'ChatLINC',
                description: 'Multilingual communication',
                icon: 'fas fa-comments',
                status: 'online',
                subdomain: 'chat.brainsait.io',
                port: 8042
            }
        ],
        
        infrastructureServices: [
            { id: 1, name: 'PostgreSQL', status: 'healthy', uptime: '99.99%' },
            { id: 2, name: 'Redis', status: 'healthy', uptime: '99.98%' },
            { id: 3, name: 'Cloudflare Tunnels', status: 'healthy', uptime: '100%' },
            { id: 4, name: 'MasterLINC Orchestrator', status: 'healthy', uptime: '99.95%' },
            { id: 5, name: 'FHIR Server', status: 'healthy', uptime: '99.92%' },
            { id: 6, name: 'NPHIES Integration', status: 'healthy', uptime: '99.89%' }
        ],
        
        init() {
            this.updateDateTime();
            setInterval(() => this.updateDateTime(), 1000);
            this.initWorkflowChart();
        },
        
        updateDateTime() {
            const now = new Date();
            const options = { 
                year: 'numeric', 
                month: 'short', 
                day: 'numeric', 
                hour: '2-digit', 
                minute: '2-digit',
                second: '2-digit'
            };
            this.currentDateTime = now.toLocaleDateString('en-US', options);
        },
        
        toggleLanguage() {
            this.currentLang = this.currentLang === 'en' ? 'ar' : 'en';
            document.documentElement.dir = this.currentLang === 'ar' ? 'rtl' : 'ltr';
        },
        
        openAgentDetails(agent) {
            this.selectedAgent = agent;
            this.showAgentModal = true;
        },
        
        initWorkflowChart() {
            setTimeout(() => {
                const ctx = document.getElementById('workflowChart');
                if (ctx) {
                    new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: ['Healthcare', 'Business', 'Automation', 'Content'],
                            datasets: [{
                                data: [35, 25, 25, 15],
                                backgroundColor: [
                                    'rgba(16, 185, 129, 0.8)',
                                    'rgba(59, 130, 246, 0.8)',
                                    'rgba(139, 92, 246, 0.8)',
                                    'rgba(245, 158, 11, 0.8)'
                                ],
                                borderWidth: 0
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        color: 'white',
                                        padding: 15
                                    }
                                }
                            }
                        }
                    });
                }
            }, 100);
        }
    }
}
