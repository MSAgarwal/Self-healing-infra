# Self-Healing Infrastructure Monitoring System

A comprehensive monitoring and automated recovery system built with Prometheus, Grafana, Alertmanager, and custom webhook handlers. This system automatically detects service failures and performs recovery actions without manual intervention.

## Architecture Overview

This self-healing infrastructure consists of:

- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notification management
- **Nginx Exporter**: Nginx metrics collection
- **Node Exporter**: System metrics collection
- **Webhook Handler**: Custom alert processing and automated recovery
- **Recovery Scripts**: Automated service restart mechanisms

## Features

- **Automated Service Recovery**: Automatically restarts failed services
- **Real-time Monitoring**: Comprehensive metrics collection from all infrastructure components
- **Alert Management**: Intelligent alert routing with webhook integration
- **Service Health Checks**: Continuous monitoring of critical services (Nginx, Prometheus, Alertmanager)
- **Self-Healing Capabilities**: Minimal manual intervention required
- **Dashboard Visualization**: Rich Grafana dashboards for monitoring system health

## Screenshots

### 1. System Ready State
![System Ready](/screenshots/image6-system-ready.png)
*All services running and healthy with service URLs displayed for easy access*

### 2. Service Status Monitoring
![Service Status](/screenshots/image10-service-targets.png)
*Prometheus targets page showing health status and scrape information for all monitored endpoints*

### 3. Failure Simulation
![Recovery Simulation](/screenshots/image7-failure-simulation.png)
*Simulating nginx failure using test scripts and monitoring the recovery process*

### 4. Alert Management Interface
![Alertmanager Interface - Initial State](/screenshots/image1-alertmanager-interface.png)
*Alertmanager interface showing alert filtering options and the critical-webhook alert configuration*

### 5. Service Alert Dashboard (Pending State)
![Service Alerts - Pending](/screenshots/image2-nginx-alert-pending.png)
*Prometheus alerts dashboard showing NginxDown alert in PENDING state with service details*

### 6. Service Alert Dashboard (Firing State)
![Service Alerts - Firing](/screenshots/image3-nginx-alert-firing.png)
*Alert escalated to FIRING state, indicating NGINX service has been down for the configured threshold*

### 7. Metrics Visualization
![Nginx Metrics Graph](/screenshots/image4-nginx-metrics-graph.png)
*Grafana dashboard showing nginx_up metrics over time, displaying service availability patterns*

### 8. Webhook Alert Processing (Firing)
![Webhook Processing - Alert](/screenshots/image8-webhook-alert-firing.png)
*Webhook handler receiving and processing critical alerts from Alertmanager*

### 9. Webhook Alert Processing (Resolution)
![Webhook Processing - Resolution](/screenshots/image9-webhook-alert-resolved.png)
*Alert resolution processing showing successful recovery and alert status change*

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/MSAgarwal/Self-healing-infra.git
   cd Self-healing-infra
   ```

2. **Start the monitoring stack**:
   ```bash
   docker-compose up -d
   ```

3. **Access the interfaces**:
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 (admin/admin123)
   - Alertmanager: http://localhost:9093
   - Nginx: http://localhost:80

## Configuration

### Alert Rules
Alert rules are configured in `prometheus/alert-rules.yml`:

```yaml
groups:
- name: service_alerts
  rules:
  - alert: NginxDown
    expr: nginx_up == 0
    for: 30s
    labels:
      severity: critical
      service: nginx
    annotations:
      description: "NGINX service has been down for more than 30 seconds."
      recovery_action: "restart_nginx"
      summary: "NGINX service is down"
```

### Recovery Actions
The webhook handler processes alerts and executes corresponding recovery scripts:

- **nginx failure**: Automatically restarts nginx container
- **service health checks**: Continuous monitoring with automated recovery
- **Alert resolution**: Automatic alert resolution after successful recovery

## Monitoring Targets

The system monitors the following components:

- **Alertmanager**: `http://alertmanager:9093/metrics`
- **Nginx Exporter**: `http://nginx-exporter:9113/metrics`  
- **Node Exporter**: `http://node-exporter:9100/metrics`
- **Prometheus**: `http://localhost:9090/metrics`

## Testing Self-Healing

To test the self-healing functionality:

1. **Simulate service failure**:
   ```bash
   ./scripts/simulate-failure.sh nginx
   ```

2. **Monitor the recovery process**:
   - Check Prometheus alerts: Alert should fire within 30 seconds
   - Check webhook logs: Recovery action should be triggered
   - Verify service restoration: nginx should restart automatically

3. **Verify alert resolution**:
   - Alert should resolve automatically after service recovery
   - Check Grafana dashboards for service uptime metrics

## File Structure

```
Self-healing-infra/
├── docker-compose.yml           # Main orchestration file
├── prometheus/
│   ├── prometheus.yml          # Prometheus configuration
│   └── alert-rules.yml         # Alert rule definitions
├── grafana/
│   └── dashboards/             # Grafana dashboard configs
├── alertmanager/
│   └── alertmanager.yml        # Alertmanager configuration
├── scripts/
│   ├── simulate-failure.sh     # Failure simulation script
│   ├── test-recovery.sh        # Recovery testing script
│   └── health-check.sh         # Health monitoring script
└── webhook-handler/
    └── app.py                  # Custom webhook processing logic
```

## Key Components

### Webhook Handler
Processes Prometheus alerts and triggers appropriate recovery actions:
- Receives alert webhooks from Alertmanager
- Parses alert metadata and determines recovery actions
- Executes recovery scripts and reports status
- Logs all recovery attempts for audit purposes

### Recovery Scripts
Automated scripts for service recovery:
- Container restart mechanisms
- Service health validation
- Rollback procedures for failed recoveries
- Notification of recovery status

## Troubleshooting

### Common Issues

1. **Alerts not firing**: Check Prometheus targets and rule evaluation
2. **Recovery not working**: Verify webhook handler connectivity and permissions
3. **Services not starting**: Check Docker logs and resource availability

### Logs and Monitoring

- **Prometheus logs**: `docker logs prometheus`
- **Webhook handler logs**: `docker logs webhook-handler`
- **Alertmanager logs**: `docker logs alertmanager`
- **Recovery script logs**: Check `/var/log/recovery.log`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section above
- Review the logs for error details

---

**Note**: This system is designed for demonstration and learning purposes. For production use, ensure proper security measures, backup strategies, and monitoring coverage for your specific infrastructure requirements.