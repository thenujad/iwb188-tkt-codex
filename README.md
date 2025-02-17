# 🎻 Orchestro: Distributed Microservice Orchestration Tool 🚀

## 🌐 Overview
**Orchestro** is a Distributed Microservice Orchestration Platform that allows developers to manage, orchestrate, and scale services across multiple nodes. With the adoption of a [cell-based architecture](https://github.com/wso2/reference-architecture/blob/master/reference-architecture-cell-based.md), Orchestro takes a modular approach to service orchestration, enabling isolation, self-contained deployments, and independent scaling.

The platform is built using **Ballerina**, leveraging its capabilities for network communication, observability, fault tolerance, and microservice orchestration. Orchestro automates service management tasks like:
- 🕵️‍♂️ **Service Discovery**
- 📈 **Dynamic Scaling**
- 🔧 **Fault Tolerance**
- ⚖️ **Load Balancing**
- 🔍 **Monitoring & Observability**

## 🔑 Key Features
- 🏗️ **Cell-based Architecture**: Deploy services as "cells" that encapsulate microservices, configurations, and observability features, allowing modular deployments.
- 🔍 **Automated Service Discovery**: Cells can dynamically discover each other for inter-cell communication.
- 📊 **Dynamic Auto-Scaling**: Scale cells up or down based on real-time traffic and resource utilization.
- 🔄 **Fault Tolerance**: Isolate failures within cells and implement recovery mechanisms to ensure high availability.
- ⚖️ **Load Balancing**: Distribute incoming requests evenly across cells.
- 👀 **Enhanced Observability**: Track logs, metrics, and traces across different cells for comprehensive monitoring.

### 🌟 Benefits
- 🚀 **Improved Scalability**: Automatically scales services up or down based on demand, ensuring efficient use of resources.
- 🔒 **High Availability & Fault Tolerance**: Ensures service continuity by detecting failures and rerouting traffic to healthy services or restarting failed instances.
- 🛠️ **Simplified Service Management**: Automates common tasks like service discovery, load balancing, and health checks, reducing the complexity of managing microservices.
- 📊 **Enhanced Observability**: Built-in monitoring and logging help in tracking the performance, availability, and resource usage of services.
- 💸 **Cost Efficiency**: Optimizes resource allocation by scaling services dynamically, which reduces infrastructure costs.

### ⚡ Advantages
- 🌍 **Decentralized & Flexible Architecture**: Supports cell-based architecture, making it easier to manage, scale, and update services independently.
- 💻 **Developer Productivity**: Allows developers to focus on core service logic instead of handling orchestration complexities.
- ⏩ **Rapid Development & Deployment**: Facilitates a microservices approach that speeds up the development lifecycle, enabling faster iterations and updates.
- 🔄 **Built-In Fault Recovery Mechanisms**: Offers automated health checks, restart mechanisms, and failover strategies for resilient service operations.
- 🔗 **Seamless Integration**: Can be easily integrated with existing infrastructure and tools, including monitoring solutions like Prometheus and Grafana.

### ⚙️ Usages
- 🛠️ **Microservice Orchestration**: Ideal for managing complex microservice architectures in distributed environments.
- ☁️ **Cloud-Native Deployments**: Suitable for cloud-based applications that require dynamic scaling and orchestration.
- 🤖 **DevOps Automation**: Supports automation of deployment workflows, scaling policies, and service monitoring.
- 🔔 **Event-Driven Systems**: Can be used to trigger scaling or recovery actions based on events or metrics.
- 🕸️ **Service Mesh Support**: Works well with service mesh patterns, offering service discovery, traffic management, and security features.

## 🏗️ Cell-Based Architecture
The architecture uses the concept of "cells" to group related microservices and provide a self-contained operational unit. Each cell includes:
- 🚪 **Service Gateway**: Entry point for handling incoming requests and forwarding them to the appropriate service.
- 🕸️ **Service Mesh**: Manages communication between services inside and outside the cell.
- 📊 **Scaling Unit**: Monitors cell-specific metrics to auto-scale services based on predefined rules.
- 👀 **Observability Module**: Collects logs, metrics, and traces for monitoring and debugging.

### 🧬 Structure of a Cell
A typical cell structure includes:
1. 🚪 **Service Gateway**: Acts as a unified entry point for accessing services within the cell.
2. 🛠️ **Core Microservices**: The primary business logic services of the cell.
3. 🧩 **Auxiliary Services**: Support services for tasks like logging, monitoring, and scaling.
4. 🕹️ **Cell Controller**: Manages the lifecycle of services within the cell.

## 🛠️ Tech Stack
- 💻 **Ballerina**: Core language for developing and orchestrating services.
- 🐋 **Docker**: For containerizing cells to ensure consistency across environments.

## 📝 Installation

### ⚙️ Prerequisites
- 💻 **Ballerina**: Install [Ballerina](https://ballerina.io/learn/installing-ballerina/).
- 🐋 **Docker**: If deploying cells as containers.

### 🔧 Steps to Run Locally
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/orchestro.git
   ```
2. **Navigate to the Project Directory**:
   ```bash
   cd orchestro
   ```
3. **Build the Platform**:
   ```bash
   ballerina build
   ```
4. **Run the Platform**:
   ```bash
   ballerina run
   ```
5. **Deploy a Cell**:
   - Define your cell configuration in a Ballerina file (e.g., `my-cell.bal`).
   - Run the cell:
     ```bash
     ballerina run my-cell.bal
     ```

## 📚 Usage

### 🛠️ Creating a New Cell
To create a new cell, define a Ballerina file (`my-cell.bal`) with the following structure:
```ballerina
import ballerina/http;
import ballerina/log;

// Define cell-specific listener
listener http:Listener cellListener = new(8081);

// Define services within the cell
service / on cellListener {
    resource function get greet(http:Caller caller, http:Request req) returns error? {
        check caller->respond("Hello from Orchestro Cell!");
    }
}
```
Run the cell:
```bash
ballerina run my-cell.bal
```

### 🔗 Inter-Cell Communication
Cells can communicate with each other using the built-in service mesh. For example, to call a service in another cell:
```ballerina
http:Client clientEndpoint = check new("http://other-cell:8081");
http:Response response = check clientEndpoint->get("/greet");
```

### ⚖️ Scaling Cells
Orchestro supports dynamic auto-scaling based on cell metrics. To configure scaling:
1. Update the scaling configuration in the cell's config file.
2. Deploy the updated configuration.

### 📊 Monitoring Cells
To monitor a cell, configure Prometheus to scrape metrics from Orchestro:
1. Set up Prometheus with a configuration file:
   ```yaml
   scrape_configs:
     - job_name: 'orchestro'
       static_configs:
         - targets: ['localhost:8080']
   ```
2. Visualize the metrics in Grafana by importing the Prometheus data.

## 🔧 How to Use Orchestro for Other Developments
1. **Modular Development**: Develop each cell independently and deploy it as a separate unit.
2. **Reuse Cells Across Projects**: Define reusable cells and share them across different Orchestro projects.
3. **Integrate with External Systems**: Use Orchestro's service mesh capabilities to integrate with third-party services.
4. **Custom Observability**: Extend the built-in observability module to include custom metrics and logging.
5. **Advanced Orchestration with Kubernetes**: Deploy containerized cells in a Kubernetes cluster for large-scale applications.

## 🤝 Contributing
We welcome contributions! To contribute:
1. Fork the repository.
2. Create a new branch for your changes:
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
5. Open a Pull Request to merge your changes.

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.