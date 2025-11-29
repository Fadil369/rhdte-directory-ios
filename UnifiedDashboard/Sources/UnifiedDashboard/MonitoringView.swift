import SwiftUI
import Charts

struct MonitoringView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // System Metrics
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                MetricCard(title: "CPU Usage", value: "45%", trend: .up, color: .blue)
                MetricCard(title: "Memory", value: "62%", trend: .stable, color: .purple)
                MetricCard(title: "Disk I/O", value: "23%", trend: .down, color: .green)
                MetricCard(title: "Network", value: "78 MB/s", trend: .up, color: .orange)
            }
            
            // Performance Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance Trends (Last 24 Hours)")
                    .font(.headline)
                
                PerformanceChart()
                    .frame(height: 250)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
            }
            
            // System Health
            VStack(alignment: .leading, spacing: 12) {
                Text("System Health")
                    .font(.headline)
                
                HealthIndicatorRow(service: "API Response Time", value: "142ms", status: .healthy)
                HealthIndicatorRow(service: "Database Connections", value: "45/100", status: .healthy)
                HealthIndicatorRow(service: "Queue Depth", value: "234", status: .warning)
                HealthIndicatorRow(service: "Error Rate", value: "0.02%", status: .healthy)
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: Trend
    let color: Color
    
    enum Trend {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .orange
            case .down: return .green
            case .stable: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundStyle(trend.color)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct PerformanceChart: View {
    let dataPoints: [ChartData] = (0..<24).map { hour in
        ChartData(hour: hour, value: Double.random(in: 20...80))
    }
    
    var body: some View {
        Chart(dataPoints) { data in
            LineMark(
                x: .value("Hour", data.hour),
                y: .value("Value", data.value)
            )
            .foregroundStyle(.blue.gradient)
            
            AreaMark(
                x: .value("Hour", data.hour),
                y: .value("Value", data.value)
            )
            .foregroundStyle(.blue.opacity(0.1).gradient)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 4)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text("\(hour)h")
                    }
                }
            }
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let hour: Int
    let value: Double
}

struct HealthIndicatorRow: View {
    let service: String
    let value: String
    let status: HealthStatus
    
    enum HealthStatus {
        case healthy, warning, critical
        
        var color: Color {
            switch self {
            case .healthy: return .green
            case .warning: return .orange
            case .critical: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .healthy: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundStyle(status.color)
            Text(service)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
