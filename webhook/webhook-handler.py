#!/usr/bin/env python3
import json
import subprocess
import logging
from datetime import datetime
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/webhook.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# Recovery action mappings
RECOVERY_ACTIONS = {
    'restart_nginx': 'restart-nginx.yml',
    'optimize_system': 'system-recovery.yml',
    'cleanup_memory': 'memory-cleanup.yml',
    'disk_cleanup': 'disk-cleanup.yml'
}

def execute_ansible_playbook(playbook, extra_vars=None):
    """Execute Ansible playbook with error handling"""
    try:
        cmd = [
            'ansible-playbook',
            f'/app/ansible/playbooks/{playbook}',
            '-i', '/app/ansible/inventory.ini',
            '-v'
        ]
        
        if extra_vars:
            cmd.extend(['--extra-vars', json.dumps(extra_vars)])
        
        logger.info(f"Executing command: {' '.join(cmd)}")
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            logger.info(f"Playbook {playbook} executed successfully")
            return True, result.stdout
        else:
            logger.error(f"Playbook {playbook} failed: {result.stderr}")
            return False, result.stderr
            
    except subprocess.TimeoutExpired:
        logger.error(f"Playbook {playbook} timed out")
        return False, "Execution timed out"
    except Exception as e:
        logger.error(f"Error executing playbook {playbook}: {str(e)}")
        return False, str(e)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    return process_alert(request, 'general')

@app.route('/webhook/critical', methods=['POST'])
def handle_critical_webhook():
    return process_alert(request, 'critical')

@app.route('/webhook/warning', methods=['POST'])
def handle_warning_webhook():
    return process_alert(request, 'warning')

def process_alert(request, alert_type):
    """Process incoming alert and trigger recovery actions"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data received'}), 400
        
        logger.info(f"Received {alert_type} alert: {json.dumps(data, indent=2)}")
        
        alerts = data.get('alerts', [])
        responses = []
        
        for alert in alerts:
            status = alert.get('status', 'unknown')
            
            # Only process firing alerts
            if status != 'firing':
                logger.info(f"Skipping {status} alert")
                continue
            
            labels = alert.get('labels', {})
            annotations = alert.get('annotations', {})
            
            alert_name = labels.get('alertname', 'Unknown')
            recovery_action = annotations.get('recovery_action', '')
            
            logger.info(f"Processing alert: {alert_name}, Recovery action: {recovery_action}")
            
            if recovery_action in RECOVERY_ACTIONS:
                playbook = RECOVERY_ACTIONS[recovery_action]
                
                # Prepare extra variables for the playbook
                extra_vars = {
                    'alert_name': alert_name,
                    'severity': labels.get('severity', 'unknown'),
                    'service': labels.get('service', 'unknown'),
                    'instance': labels.get('instance', 'unknown'),
                    'timestamp': datetime.now().isoformat()
                }
                
                success, output = execute_ansible_playbook(playbook, extra_vars)
                
                response = {
                    'alert': alert_name,
                    'action': recovery_action,
                    'success': success,
                    'output': output,
                    'timestamp': datetime.now().isoformat()
                }
                
                responses.append(response)
            else:
                logger.warning(f"No recovery action defined for alert: {alert_name}")
                responses.append({
                    'alert': alert_name,
                    'action': 'none',
                    'success': False,
                    'message': 'No recovery action defined',
                    'timestamp': datetime.now().isoformat()
                })
        
        return jsonify({
            'status': 'processed',
            'alert_type': alert_type,
            'responses': responses
        })
        
    except Exception as e:
        logger.error(f"Error processing webhook: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Create logs directory
    os.makedirs('/app/logs', exist_ok=True)
    
    app.run(host='0.0.0.0', port=8080, debug=False)