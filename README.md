# Distributed Microservice Orchestration Platform

## Overview
The **Distributed Microservice Orchestration Platform** allows developers to manage, orchestrate, and scale microservices across multiple nodes. This platform is built using **Ballerina**, leveraging its native capabilities for network communication, concurrency, observability, and fault tolerance.

This platform automates key microservice tasks such as:
- **Service Discovery**
- **Dynamic Scaling**
- **Fault Tolerance**
- **Load Balancing**
- **Monitoring & Observability**

## Key Features
- **Automated Service Discovery**: Services can register and discover each other without manual configuration.
- **Dynamic Auto-Scaling**: Automatically scale up or down based on real-time traffic and resource usage.
- **Fault Tolerance**: Detect and recover from failures, ensuring high availability.
- **Load Balancing**: Evenly distribute incoming requests across available services.
- **Observability**: Track logs, metrics, and health checks with built-in observability tools.

## Tech Stack
- **Ballerina**: The core technology behind the platform, providing built-in support for network protocols, observability, and microservice orchestration.
- **Prometheus** (optional): For advanced metrics collection and monitoring.
- **Grafana** (optional): To visualize service health and performance metrics.

## Microservices Structure

### 1. **Service Registration & Discovery Microservice**
   - **Purpose**: Manage microservice registration and discovery.
   - **Endpoints**:
     - `POST /register`: Register a new microservice.
     - `GET /discover`: Discover available microservices.

### 2. **Task Management & Scheduling Microservice**
   - **Purpose**: Handle task distribution and scheduling across microservices.
   - **Endpoints**:
     - `POST /schedule`: Schedule tasks for microservices.
     - `GET /status/{serviceID}`: Check task status for a microservice.

### 3. **Service Scaling Microservice**
   - **Purpose**: Auto-scale services based on resource consumption.
   - **Endpoints**:
     - `POST /scale/up`: Trigger service scale-up.
     - `POST /scale/down`: Trigger service scale-down.
     - `GET /monitor/usage`: Monitor resource usage for scaling.

### 4. **Fault Tolerance Microservice**
   - **Purpose**: Detect service failures and implement recovery mechanisms.
   - **Endpoints**:
     - `GET /healthcheck/{serviceID}`: Perform health checks on services.
     - `POST /restart/{serviceID}`: Restart a failed service.
     - `GET /failover/{serviceID}`: Reroute traffic to a healthy service in case of failure.

### 5. **Load Balancer Microservice**
   - **Purpose**: Distribute incoming traffic evenly across service instances.
   - **Endpoints**:
     - `POST /balance/request`: Forward requests to the least loaded service.
     - `GET /load/{serviceID}`: Get the current load of a service.

### 6. **Observability & Monitoring Microservice**
   - **Purpose**: Collect and monitor service performance metrics and logs.
   - **Endpoints**:
     - `GET /logs/{serviceID}`: Retrieve logs for a service.
     - `GET /metrics/{serviceID}`: Collect performance metrics.
     - `GET /trace/{requestID}`: Trace a request for debugging purposes.

### 7. **Service Gateway Microservice**
   - **Purpose**: Central entry point for external requests, forwarding to the appropriate microservice.
   - **Endpoints**:
     - `POST /gateway/request`: Forward client requests to the appropriate service.
     - `GET /gateway/status`: Get the status of the gateway and connected services.

## Installation

### Prerequisites
- **Ballerina**: Install Ballerina by following the official guide: [Ballerina Installation Guide](https://ballerina.io/learn/installing-ballerina/).
- **Docker**: (Optional) If you wish to containerize the platform for deployment.
- **Prometheus & Grafana**: (Optional) For advanced observability and metrics visualization.

### Steps to Run Locally
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/microservice-orchestration-platform.git
   ```
   
2. **Navigate to the Project Directory**:
   ```bash
   cd microservice-orchestration-platform
   ```

3. **Build and Run the Platform**:
   ```bash
   ballerina build
   ballerina run
   ```

4. **Monitor Services** (Optional):
   - Use Prometheus for monitoring metrics:
     - Setup Prometheus using the provided `prometheus.yml` configuration.
   - Visualize metrics with Grafana:
     - Import Prometheus data into Grafana for visual dashboards.

## Usage

### Registering a Microservice
To register a new microservice, send a POST request to the `/register` endpoint:
```bash
curl -X POST http://localhost:8080/register -d '{ "serviceName": "myService", "serviceUrl": "http://my-service:8080" }'
```

### Discovering Services
To discover available services, send a GET request to the `/discover` endpoint:
```bash
curl http://localhost:8080/discover
```

### Monitoring Service Health
To check the health of a service, use the `/healthcheck` endpoint:
```bash
curl http://localhost:8080/healthcheck/myService
```

## Contributing
We welcome contributions! Please follow the guidelines below to contribute to this project.

1. Fork the repository.
2. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your commit message here"
   ```
4. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Create a Pull Request to merge your changes into `main`.

## License
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

## Contact
For any questions or inquiries, feel free to reach out to the project maintainer:
- **Email**: yourname@example.com
- **GitHub**: [yourusername](https://github.com/yourusername)

