# Kitchen Service - Cafeteria Management System

> Kitchen Operations & Order Queue Management with MongoDB

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-green.svg)](https://www.mongodb.com/)

## 📋 Overview

The Kitchen Service manages all kitchen operations, including order queue management, preparation tracking, and staff coordination. Unlike other services that use MySQL, this service uses **MongoDB** for flexible, document-based storage of kitchen operations and real-time order updates.

## 🚀 Features

- **Order Queue Management**: Real-time kitchen order queue
- **Order Status Updates**: Update order status (PREPARING, READY)
- **Preparation Time Tracking**: Track actual vs estimated preparation time
- **Kitchen Staff Assignment**: Assign orders to specific kitchen staff
- **Priority Management**: Prioritize urgent or special orders
- **Kitchen Display System (KDS)**: Real-time dashboard data
- **Order History**: Historical kitchen operations data
- **MongoDB Integration**: NoSQL database for flexible schema and real-time updates
- **WebSocket Ready**: Foundation for real-time kitchen notifications
- **Service Discovery**: Registered with Eureka for discoverability

## 🛠️ Tech Stack

| Technology                         | Version  | Purpose                   |
| ---------------------------------- | -------- | ------------------------- |
| Java                               | 25       | Programming Language      |
| Spring Boot                        | 4.0.3    | Application Framework     |
| Spring Cloud Config Client         | 2025.1.0 | Centralized Configuration |
| Spring Cloud Netflix Eureka Client | 2025.1.0 | Service Discovery         |
| Spring Data MongoDB                | 4.0.3    | MongoDB Integration       |
| MongoDB                            | 7.0      | NoSQL Document Database   |
| Maven                              | 3.9+     | Build Tool                |

## 📡 Service Configuration

| Property                | Value                                            |
| ----------------------- | ------------------------------------------------ |
| **Service Name**        | `kitchen-service`                                |
| **Port**                | `8084`                                           |
| **Database**            | MongoDB                                          |
| **Database Name**       | `cafeteria_kitchen`                              |
| **Collections**         | kitchen_orders, kitchen_queue, staff_assignments |
| **Eureka Registration** | Yes                                              |
| **Config Server**       | `http://localhost:8888`                          |

## 💾 MongoDB Collections

### Why MongoDB for Kitchen Service?

MongoDB is ideal for this service because:

- ✅ **Flexible Schema**: Kitchen orders may have varying structures
- ✅ **Real-time Updates**: Excellent for frequently changing order statuses
- ✅ **Embedded Documents**: Store order items within orders naturally
- ✅ **High Write Performance**: Kitchen operations involve frequent status updates
- ✅ **Horizontal Scalability**: Can scale for high-traffic cafeterias

### Kitchen Orders Collection

```json
{
  "_id": "65f8a1b2c3d4e5f6g7h8i9j0",
  "orderId": 123,
  "orderNumber": "ORD-20260318-123",
  "userId": 1,
  "userName": "John Doe",
  "items": [
    {
      "menuItemId": 5,
      "menuItemName": "Chicken Burger",
      "quantity": 2,
      "specialInstructions": "No onions",
      "status": "PREPARING"
    },
    {
      "menuItemId": 12,
      "menuItemName": "Coca Cola",
      "quantity": 1,
      "status": "READY"
    }
  ],
  "totalAmount": 20.48,
  "status": "PREPARING",
  "priority": "NORMAL",
  "assignedStaffId": 5,
  "assignedStaffName": "Chef Mike",
  "estimatedReadyTime": "2026-03-18T13:30:00Z",
  "actualStartTime": "2026-03-18T13:05:00Z",
  "actualReadyTime": null,
  "notes": "Extra napkins please",
  "createdAt": "2026-03-18T13:00:00Z",
  "updatedAt": "2026-03-18T13:05:00Z"
}
```

### Kitchen Queue Collection

```json
{
  "_id": "65f8a1b2c3d4e5f6g7h8i9j1",
  "orderId": 123,
  "orderNumber": "ORD-20260318-123",
  "position": 3,
  "status": "PENDING",
  "priority": "NORMAL",
  "addedAt": "2026-03-18T13:00:00Z"
}
```

### Staff Assignments Collection

```json
{
  "_id": "65f8a1b2c3d4e5f6g7h8i9j2",
  "staffId": 5,
  "staffName": "Chef Mike",
  "currentOrders": [123, 125, 128],
  "orderCount": 3,
  "shiftStart": "2026-03-18T06:00:00Z",
  "shiftEnd": "2026-03-18T14:00:00Z",
  "status": "ACTIVE"
}
```

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- MongoDB 7.0
- Port 8084 available
- Config Server running on port 8888
- Service Registry running on port 8761

### MongoDB Setup

#### Using Docker (Recommended)

```bash
# Start MongoDB with Docker Compose
docker-compose up -d mongodb

# Or manually
docker run -d \
  --name cafeteria-mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=admin123 \
  -e MONGO_INITDB_DATABASE=cafeteria_kitchen \
  mongo:7.0
```

#### Using Local Installation

```bash
# Install MongoDB 7.0
# https://www.mongodb.com/docs/manual/installation/

# Start MongoDB service
sudo systemctl start mongod  # Linux
brew services start mongodb-community@7.0  # macOS

# Create database and user
mongosh
use cafeteria_kitchen
db.createUser({
  user: "cafeteria_admin",
  pwd: "SecurePassword123",
  roles: ["readWrite"]
})
```

### Build

```bash
mvn clean install
```

### Run Locally

```bash
mvn spring-boot:run
```

## 🔧 Configuration

### application.yml (Local)

```yaml
server:
  port: 8084

spring:
  application:
    name: kitchen-service
  config:
    import: optional:configserver:http://localhost:8888

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

### kitchen-service.yml (Config Server)

```yaml
spring:
  data:
    mongodb:
      host: ${MONGODB_HOST:localhost}
      port: ${MONGODB_PORT:27017}
      database: cafeteria_kitchen
      username: ${MONGODB_USERNAME:admin}
      password: ${MONGODB_PASSWORD:admin123}
      authentication-database: admin
      # Alternative: Connection URI
      # uri: mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOST}:${MONGODB_PORT}/cafeteria_kitchen?authSource=admin

# Kitchen Configuration
kitchen:
  queue:
    max-concurrent-orders: 10
    default-preparation-time: 15 # minutes
    priority-boost-time: -5 # subtract minutes for priority orders
```

## 🌐 API Endpoints

### Kitchen Queue Endpoints

#### Get Kitchen Queue

```http
GET /kitchen/queue
Authorization: Bearer <JWT_TOKEN>
```

**Response:**

```json
[
  {
    "orderId": 123,
    "orderNumber": "ORD-20260318-123",
    "position": 1,
    "status": "PREPARING",
    "priority": "HIGH",
    "estimatedReadyTime": "2026-03-18T13:30:00Z",
    "items": [
      {
        "menuItemName": "Chicken Burger",
        "quantity": 2
      }
    ],
    "assignedStaff": "Chef Mike"
  },
  {
    "orderId": 124,
    "orderNumber": "ORD-20260318-124",
    "position": 2,
    "status": "PENDING",
    "priority": "NORMAL"
  }
]
```

#### Get Specific Kitchen Order

```http
GET /kitchen/orders/{orderId}
Authorization: Bearer <JWT_TOKEN>
```

#### Pull Next Order from Queue

```http
POST /kitchen/queue/next
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "staffId": 5,
  "staffName": "Chef Mike"
}
```

**Response:**

```json
{
  "orderId": 124,
  "orderNumber": "ORD-20260318-124",
  "items": [...],
  "assignedStaffId": 5,
  "assignedStaffName": "Chef Mike",
  "status": "PREPARING",
  "startedAt": "2026-03-18T13:10:00Z"
}
```

### Order Status Updates

#### Update Order Status

```http
PATCH /kitchen/orders/{orderId}/status
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "status": "READY",
  "staffId": 5
}
```

#### Update Item Status

```http
PATCH /kitchen/orders/{orderId}/items/{itemId}/status
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "status": "READY"
}
```

#### Mark Order as Preparing

```http
POST /kitchen/orders/{orderId}/start
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "staffId": 5,
  "estimatedReadyTime": "2026-03-18T13:30:00Z"
}
```

#### Mark Order as Ready

```http
POST /kitchen/orders/{orderId}/complete
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "staffId": 5,
  "notes": "Order ready at counter 3"
}
```

### Priority Management

#### Set Order Priority

```http
PATCH /kitchen/orders/{orderId}/priority
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "priority": "HIGH"
}
```

**Priority Levels:**

- `LOW`: Standard orders, longer estimated time
- `NORMAL`: Regular orders (default)
- `HIGH`: Priority orders (VIP, urgent)
- `URGENT`: Immediate attention required

### Staff Management

#### Get Active Staff

```http
GET /kitchen/staff/active
Authorization: Bearer <JWT_TOKEN>
```

#### Get Staff Workload

```http
GET /kitchen/staff/{staffId}/workload
Authorization: Bearer <JWT_TOKEN>
```

**Response:**

```json
{
  "staffId": 5,
  "staffName": "Chef Mike",
  "currentOrders": 3,
  "ordersToday": 25,
  "averagePreparationTime": 12,
  "status": "ACTIVE"
}
```

### Dashboard & Statistics

#### Get Kitchen Dashboard

```http
GET /kitchen/dashboard
Authorization: Bearer <JWT_TOKEN>
```

**Response:**

```json
{
  "ordersInQueue": 5,
  "ordersInProgress": 3,
  "ordersCompletedToday": 142,
  "averagePreparationTime": 14.5,
  "activeStaff": 4,
  "currentLoad": "MEDIUM"
}
```

## 🔄 MongoDB Operations

### Repository Example

```java
@Repository
public interface KitchenOrderRepository extends MongoRepository<KitchenOrder, String> {

    // Find orders by status
    List<KitchenOrder> findByStatus(OrderStatus status);

    // Find orders assigned to staff
    List<KitchenOrder> findByAssignedStaffId(Long staffId);

    // Find orders by priority ordered by creation time
    List<KitchenOrder> findByPriorityOrderByCreatedAtAsc(Priority priority);

    // Complex query using @Query annotation
    @Query("{ 'status': ?0, 'priority': { $in: ?1 } }")
    List<KitchenOrder> findByStatusAndPriorities(OrderStatus status, List<Priority> priorities);

    // Aggregation example: Count orders by status
    @Aggregation(pipeline = {
        "{ '$group': { '_id': '$status', 'count': { '$sum': 1 } } }"
    })
    List<StatusCount> countOrdersByStatus();
}
```

### Service Layer Example

```java
@Service
public class KitchenOrderService {

    private final KitchenOrderRepository kitchenOrderRepository;
    private final MongoTemplate mongoTemplate;

    public KitchenOrder updateOrderStatus(String orderId, OrderStatus newStatus, Long staffId) {
        KitchenOrder order = kitchenOrderRepository.findById(orderId)
            .orElseThrow(() -> new NotFoundException("Order not found"));

        order.setStatus(newStatus);
        order.setUpdatedAt(LocalDateTime.now());

        if (newStatus == OrderStatus.PREPARING) {
            order.setActualStartTime(LocalDateTime.now());
        } else if (newStatus == OrderStatus.READY) {
            order.setActualReadyTime(LocalDateTime.now());
        }

        return kitchenOrderRepository.save(order);
    }

    public List<KitchenOrder> getKitchenQueue() {
        // Get pending and preparing orders, ordered by priority and time
        Query query = new Query();
        query.addCriteria(Criteria.where("status")
            .in(OrderStatus.PENDING, OrderStatus.PREPARING));
        query.with(Sort.by(
            Sort.Order.asc("priority"),
            Sort.Order.asc("createdAt")
        ));

        return mongoTemplate.find(query, KitchenOrder.class);
    }
}
```

## 🧪 Testing

### cURL Examples

#### Get Kitchen Queue

```bash
TOKEN="your-jwt-token"
curl http://localhost:8080/api/kitchen/queue \
  -H "Authorization: Bearer $TOKEN"
```

#### Start Preparing Order

```bash
curl -X POST http://localhost:8080/api/kitchen/orders/123/start \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "staffId": 5,
    "estimatedReadyTime": "2026-03-18T13:30:00Z"
  }'
```

#### Mark Order Ready

```bash
curl -X POST http://localhost:8080/api/kitchen/orders/123/complete \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"staffId": 5}'
```

### MongoDB Shell Testing

```javascript
// Connect to MongoDB
mongosh mongodb://admin:admin123@localhost:27017/cafeteria_kitchen?authSource=admin

// View kitchen orders
db.kitchen_orders.find().pretty()

// Count orders by status
db.kitchen_orders.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } }
])

// Find high priority orders
db.kitchen_orders.find({ priority: "HIGH" })

// Find orders assigned to specific staff
db.kitchen_orders.find({ assignedStaffId: 5 })

// Update order status
db.kitchen_orders.updateOne(
  { orderId: 123 },
  { $set: { status: "READY", actualReadyTime: new Date() } }
)
```

### Unit Tests

```bash
mvn test
```

### Integration Tests with MongoDB

```bash
# Using embedded MongoDB (Flapdoodle)
mvn verify -Pintegration-tests
```

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app
COPY target/kitchen-service-1.0.0.jar app.jar
EXPOSE 8084
ENV MONGODB_HOST=mongodb
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### docker-compose.yml Integration

```yaml
mongodb:
  image: mongo:7.0
  container_name: cafeteria-mongodb
  ports:
    - "27017:27017"
  environment:
    MONGO_INITDB_ROOT_USERNAME: admin
    MONGO_INITDB_ROOT_PASSWORD: admin123
    MONGO_INITDB_DATABASE: cafeteria_kitchen
  volumes:
    - mongodb_data:/data/db

kitchen-service:
  build: ./services/kitchen-service
  ports:
    - "8084:8084"
  depends_on:
    - mongodb
    - config-server
    - service-registry
  environment:
    - MONGODB_HOST=mongodb
    - MONGODB_PORT=27017
    - MONGODB_USERNAME=admin
    - MONGODB_PASSWORD=admin123
    - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://service-registry:8761/eureka/

volumes:
  mongodb_data:
```

## ☁️ Cloud Deployment (GCP)

### MongoDB Atlas (Managed MongoDB)

#### Setup

1. Create MongoDB Atlas cluster
2. Get connection string
3. Configure application

```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://username:password@cluster.mongodb.net/cafeteria_kitchen?retryWrites=true&w=majority
```

### Self-Hosted MongoDB on GCP VM

```bash
# Install MongoDB on GCP VM
sudo apt-get update
sudo apt-get install -y mongodb-org=7.0

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Configure firewall (internal only)
gcloud compute firewall-rules create allow-mongodb \
  --allow tcp:27017 \
  --source-ranges 10.0.0.0/8
```

### PM2 Configuration

```javascript
{
  name: 'kitchen-service',
  script: 'java',
  args: ['-jar', 'services/kitchen-service/target/kitchen-service-1.0.0.jar'],
  env: {
    SERVER_PORT: 8084,
    MONGODB_HOST: 'mongodb-instance',
    MONGODB_PORT: 27017,
    MONGODB_USERNAME: 'admin',
    MONGODB_PASSWORD: process.env.MONGODB_PASSWORD
  }
}
```

## 📊 Monitoring

### Health Check

```bash
curl http://localhost:8084/actuator/health
```

**Expected Response:**

```json
{
  "status": "UP",
  "components": {
    "mongo": {
      "status": "UP",
      "details": {
        "version": "7.0.0"
      }
    }
  }
}
```

### MongoDB Metrics

```bash
# MongoDB connection metrics
curl http://localhost:8084/actuator/metrics/mongodb.driver.pool.size

# Collection metrics
curl http://localhost:8084/actuator/metrics/mongodb.driver.commands
```

## 🐛 Troubleshooting

### MongoDB Connection Issues

**Issue**: `MongoTimeoutException: Timed out after 30000 ms`

**Solutions:**

1. Verify MongoDB is running:

   ```bash
   docker ps | grep mongo
   # or
   sudo systemctl status mongod
   ```

2. Test connection:

   ```bash
   mongosh mongodb://admin:admin123@localhost:27017/cafeteria_kitchen?authSource=admin
   ```

3. Check connection string in configuration

**Issue**: Authentication failed

**Solution**: Verify credentials and authentication database:

```yaml
spring:
  data:
    mongodb:
      authentication-database: admin # Important!
```

### Performance Issues

**Slow Queries**: Add indexes

```javascript
// Create indexes in MongoDB
db.kitchen_orders.createIndex({ status: 1, priority: 1 });
db.kitchen_orders.createIndex({ assignedStaffId: 1 });
db.kitchen_orders.createIndex({ createdAt: 1 });
```

## 📚 Additional Resources

- [Spring Data MongoDB Documentation](https://docs.spring.io/spring-data/mongodb/docs/current/reference/html/)
- [MongoDB Documentation](https://www.mongodb.com/docs/manual/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [MongoDB Compass](https://www.mongodb.com/products/compass) - GUI for MongoDB

## 🔗 Service Integration

### Called By

- **API Gateway**: Routes `/api/kitchen/**` and `/api/queue/**`
- **Order Service**: Notifies of new orders

### Database Dependencies

- **MongoDB**: Kitchen orders, queue, and staff data

### Service Discovery

- **Registers with**: Eureka Service Registry (8761)
- **Fetches config from**: Config Server (8888)

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Business Service (Kitchen Operations)
**Database Type**: MongoDB (NoSQL)
**Maintained By**: ITS 2130 Project Team
