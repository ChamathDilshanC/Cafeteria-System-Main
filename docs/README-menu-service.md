# Menu Service - Cafeteria Management System

> Menu & Food Item Management with Google Cloud Storage Integration

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![GCP](https://img.shields.io/badge/GCP-Cloud%20Storage-blue.svg)](https://cloud.google.com/storage)

## 📋 Overview

The Menu Service manages the cafeteria's food menu, including menu items, categories, pricing, availability, and images. It integrates with Google Cloud Storage (GCS) for storing and serving food item images, providing a scalable and reliable image hosting solution.

## 🚀 Features

- **Menu Item Management**: CRUD operations for food items
- **Category Management**: Organize items by categories (Breakfast, Lunch, Dinner, Snacks, Beverages)
- **Image Upload to GCS**: Upload food images to Google Cloud Storage
- **Image URL Generation**: Generate signed or public URLs for images
- **Availability Tracking**: Mark items as available/unavailable
- **Price Management**: Set and update item prices
- **Search & Filter**: Search by name, category, price range
- **Daily Specials**: Mark and highlight special items
- **Nutritional Information**: Store calories, allergens, dietary tags
- **Service Discovery**: Registered with Eureka for discoverability

## 🛠️ Tech Stack

| Technology                         | Version  | Purpose                   |
| ---------------------------------- | -------- | ------------------------- |
| Java                               | 25       | Programming Language      |
| Spring Boot                        | 4.0.3    | Application Framework     |
| Spring Cloud Config Client         | 2025.1.0 | Centralized Configuration |
| Spring Cloud Netflix Eureka Client | 2025.1.0 | Service Discovery         |
| Spring Data JPA                    | 4.0.3    | Database Access Layer     |
| MySQL                              | 8.0      | Relational Database       |
| Google Cloud Storage               | Latest   | Image Storage             |
| Maven                              | 3.9+     | Build Tool                |

## 📡 Service Configuration

| Property                | Value                      |
| ----------------------- | -------------------------- |
| **Service Name**        | `menu-service`             |
| **Port**                | `8082`                     |
| **Database**            | MySQL                      |
| **Database Name**       | `cafeteria_menu`           |
| **Cloud Storage**       | Google Cloud Storage (GCS) |
| **GCS Bucket**          | `cafeteria-menu-images`    |
| **Eureka Registration** | Yes                        |
| **Config Server**       | `http://localhost:8888`    |

## 💾 Database Schema

### Menu Items Table

```sql
CREATE TABLE menu_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id BIGINT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(500),
    gcs_file_path VARCHAR(500),
    is_available BOOLEAN DEFAULT TRUE,
    is_special BOOLEAN DEFAULT FALSE,
    calories INT,
    preparation_time_minutes INT DEFAULT 15,
    allergens TEXT,
    dietary_tags VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_category (category_id),
    INDEX idx_available (is_available),
    INDEX idx_special (is_special)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Categories Table

```sql
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    icon_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Sample Categories

- Breakfast (Toast, Pancakes, Cereals)
- Lunch (Rice Plates, Sandwiches, Salads)
- Dinner (Main Courses, Sides)
- Snacks (Chips, Cookies, Fruits)
- Beverages (Coffee, Tea, Juice, Soft Drinks)

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- MySQL 8.0
- Google Cloud Platform Account
- GCS Bucket configured
- Port 8082 available
- Config Server running on port 8888
- Service Registry running on port 8761

### Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE cafeteria_menu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Run initialization script
mysql -u root -p cafeteria_menu < init-scripts/mysql/02_create_menu_tables.sql
```

### Google Cloud Storage Setup

#### 1. Create GCS Bucket

```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Create bucket
gcloud storage buckets create gs://cafeteria-menu-images \
  --location=us-central1 \
  --uniform-bucket-level-access

# Set public read access (optional, for public images)
gcloud storage buckets add-iam-policy-binding gs://cafeteria-menu-images \
  --member=allUsers \
  --role=roles/storage.objectViewer
```

#### 2. Create Service Account

```bash
# Create service account
gcloud iam service-accounts create cafeteria-menu-sa \
  --display-name="Cafeteria Menu Service Account"

# Grant Storage Admin role
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:cafeteria-menu-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create ~/gcs-key.json \
  --iam-account=cafeteria-menu-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

#### 3. Configure Application

```yaml
# In menu-service.yml (Config Server)
gcp:
  storage:
    bucket-name: cafeteria-menu-images
    project-id: YOUR_PROJECT_ID
    credentials-location: file:/path/to/gcs-key.json
    # Or use environment variable
    # credentials-location: ${GCS_CREDENTIALS_PATH}
```

### Build

```bash
mvn clean install
```

### Run Locally

```bash
# Set GCS credentials environment variable
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcs-key.json

mvn spring-boot:run
```

## 🔧 Configuration

### application.yml (Local)

```yaml
server:
  port: 8082

spring:
  application:
    name: menu-service
  config:
    import: optional:configserver:http://localhost:8888
  servlet:
    multipart:
      enabled: true
      max-file-size: 10MB
      max-request-size: 10MB

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

### menu-service.yml (Config Server)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/cafeteria_menu?useSSL=false&serverTimezone=UTC
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root}
    driver-class-name: com.mysql.cj.jdbc.Driver

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect

# Google Cloud Storage Configuration
gcp:
  storage:
    bucket-name: ${GCS_BUCKET_NAME:cafeteria-menu-images}
    project-id: ${GCP_PROJECT_ID}
    credentials-location: ${GOOGLE_APPLICATION_CREDENTIALS}
    base-url: https://storage.googleapis.com/${GCS_BUCKET_NAME}
```

## 🌐 API Endpoints

### Menu Items Endpoints

#### Get All Menu Items

```http
GET /menu/items?category=1&available=true&page=0&size=20
```

**Response:**

```json
{
  "content": [
    {
      "id": 1,
      "name": "Chicken Burger",
      "description": "Grilled chicken with lettuce and tomato",
      "categoryId": 2,
      "categoryName": "Lunch",
      "price": 8.99,
      "imageUrl": "https://storage.googleapis.com/cafeteria-menu-images/chicken-burger.jpg",
      "isAvailable": true,
      "isSpecial": true,
      "calories": 650,
      "preparationTimeMinutes": 15,
      "allergens": "Gluten, Dairy",
      "dietaryTags": "High Protein"
    }
  ],
  "totalElements": 50,
  "totalPages": 3,
  "size": 20,
  "number": 0
}
```

#### Get Menu Item by ID

```http
GET /menu/items/{id}
```

#### Create Menu Item

```http
POST /menu/items
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Chicken Burger",
  "description": "Grilled chicken with lettuce and tomato",
  "categoryId": 2,
  "price": 8.99,
  "calories": 650,
  "preparationTimeMinutes": 15,
  "allergens": "Gluten, Dairy",
  "dietaryTags": "High Protein"
}
```

#### Upload Menu Item Image

```http
POST /menu/items/{id}/image
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

file: [Image File]
```

**Response:**

```json
{
  "imageUrl": "https://storage.googleapis.com/cafeteria-menu-images/items/1-chicken-burger-1678901234.jpg",
  "gcsPath": "items/1-chicken-burger-1678901234.jpg"
}
```

#### Update Menu Item

```http
PUT /menu/items/{id}
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Spicy Chicken Burger",
  "price": 9.99,
  "isAvailable": true
}
```

#### Toggle Item Availability

```http
PATCH /menu/items/{id}/availability
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "isAvailable": false
}
```

#### Delete Menu Item

```http
DELETE /menu/items/{id}
Authorization: Bearer <JWT_TOKEN>
```

### Category Endpoints

#### Get All Categories

```http
GET /categories
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "Breakfast",
    "description": "Morning meals and beverages",
    "displayOrder": 1,
    "isActive": true,
    "itemCount": 15
  },
  {
    "id": 2,
    "name": "Lunch",
    "description": "Midday meals",
    "displayOrder": 2,
    "isActive": true,
    "itemCount": 25
  }
]
```

#### Create Category

```http
POST /categories
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Desserts",
  "description": "Sweet treats and ice cream",
  "displayOrder": 6
}
```

#### Update Category

```http
PUT /categories/{id}
Authorization: Bearer <JWT_TOKEN>
```

### Search & Filter

#### Search Menu Items

```http
GET /menu/items/search?query=chicken&minPrice=5.0&maxPrice=15.0
```

#### Get Daily Specials

```http
GET /menu/items/specials
```

#### Get Items by Category

```http
GET /menu/items/category/{categoryId}
```

## ☁️ Google Cloud Storage Integration

### GCS Service Implementation

```java
@Service
public class GcsStorageService {

    @Value("${gcp.storage.bucket-name}")
    private String bucketName;

    private final Storage storage;

    public GcsStorageService(@Value("${gcp.storage.project-id}") String projectId) {
        this.storage = StorageOptions.newBuilder()
                .setProjectId(projectId)
                .build()
                .getService();
    }

    public String uploadImage(MultipartFile file, Long menuItemId) throws IOException {
        String fileName = generateFileName(file.getOriginalFilename(), menuItemId);
        String blobPath = "items/" + fileName;

        BlobId blobId = BlobId.of(bucketName, blobPath);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(file.getContentType())
                .build();

        storage.create(blobInfo, file.getBytes());

        // Return public URL
        return String.format("https://storage.googleapis.com/%s/%s", bucketName, blobPath);
    }

    public void deleteImage(String gcsPath) {
        BlobId blobId = BlobId.of(bucketName, gcsPath);
        storage.delete(blobId);
    }

    private String generateFileName(String originalFilename, Long menuItemId) {
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        return menuItemId + "-" + System.currentTimeMillis() + extension;
    }
}
```

### Image Upload Flow

```
Client (Web App)
    │
    ▼
POST /api/menu/items/1/image
    │
    ▼
Menu Service
    │
    ├─► Validate image (size, type)
    ├─► Generate unique filename
    ├─► Upload to GCS bucket
    ├─► Get public URL
    ├─► Update database record
    │
    ▼
Return Image URL
    │
    ▼
Client receives URL for display
```

### Supported Image Formats

- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)
- GIF (.gif)

### Image Constraints

- Maximum file size: 10 MB
- Recommended dimensions: 800x600 px
- Automatic optimization: Consider using ImageKit or Cloudinary for on-the-fly optimization

## 🧪 Testing

### cURL Examples

#### Create Menu Item

```bash
curl -X POST http://localhost:8080/api/menu/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Caesar Salad",
    "description": "Fresh romaine with Caesar dressing",
    "categoryId": 2,
    "price": 7.99,
    "calories": 350
  }'
```

#### Upload Image

```bash
curl -X POST http://localhost:8080/api/menu/items/1/image \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/path/to/image.jpg"
```

#### Get All Items

```bash
curl http://localhost:8080/api/menu/items
```

### Unit Tests

```bash
mvn test
```

### Integration Tests with GCS

```bash
# Set up test credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/test-key.json

mvn verify -Pintegration-tests
```

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app
COPY target/menu-service-1.0.0.jar app.jar
COPY gcs-key.json /app/gcs-key.json
EXPOSE 8082
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcs-key.json
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose

```yaml
menu-service:
  build: ./services/menu-service
  ports:
    - "8082:8082"
  depends_on:
    - mysql
    - config-server
    - service-registry
  environment:
    - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/cafeteria_menu
    - GOOGLE_APPLICATION_CREDENTIALS=/app/gcs-key.json
    - GCS_BUCKET_NAME=cafeteria-menu-images
  volumes:
    - ./gcs-key.json:/app/gcs-key.json:ro
```

## ☁️ Cloud Deployment (GCP)

### Using Service Account on GCP VM

When deployed on GCP VM with attached service account:

```bash
# No need to set GOOGLE_APPLICATION_CREDENTIALS
# GCP automatically provides credentials to VM

# Just set bucket name
export GCS_BUCKET_NAME=cafeteria-menu-images
export SPRING_DATASOURCE_URL=jdbc:mysql://${DB_IP}:3306/cafeteria_menu
```

### PM2 Configuration

```javascript
{
  name: 'menu-service',
  script: 'java',
  args: ['-jar', 'services/menu-service/target/menu-service-1.0.0.jar'],
  env: {
    SERVER_PORT: 8082,
    GCS_BUCKET_NAME: 'cafeteria-menu-images',
    SPRING_DATASOURCE_URL: 'jdbc:mysql://mysql-instance:3306/cafeteria_menu'
  }
}
```

## 📊 Monitoring

### Health Check

```bash
curl http://localhost:8082/actuator/health
```

### Custom Health Indicator for GCS

```java
@Component
public class GcsHealthIndicator implements HealthIndicator {

    private final Storage storage;

    @Override
    public Health health() {
        try {
            storage.list(bucketName, Storage.BucketListOption.pageSize(1));
            return Health.up().withDetail("gcs", "Connected").build();
        } catch (Exception e) {
            return Health.down().withDetail("gcs", "Connection failed").build();
        }
    }
}
```

## 🐛 Troubleshooting

### GCS Authentication Issues

```bash
# Verify credentials file exists
ls -la /path/to/gcs-key.json

# Test GCS access with gcloud CLI
gsutil ls gs://cafeteria-menu-images

# Check service account permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:cafeteria-menu-sa@*"
```

### Image Upload Failures

**Issue**: 403 Forbidden

- **Cause**: Service account lacks permissions
- **Solution**: Grant Storage Admin or Storage Object Creator role

**Issue**: Image not appearing

- **Cause**: Bucket not public or wrong URL
- **Solution**: Verify bucket IAM policy or generate signed URLs

## 📚 Additional Resources

- [Google Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Spring Cloud GCP](https://spring.io/projects/spring-cloud-gcp)
- [GCS Client Libraries](https://cloud.google.com/storage/docs/reference/libraries)

## 🔗 Service Integration

### Called By

- **API Gateway**: Routes `/api/menu/**` and `/api/categories/**`
- **Order Service**: Fetches menu item details and prices
- **Frontend (webapp)**: Displays menu with images

### External Services

- **Google Cloud Storage**: Image hosting and delivery
- **MySQL**: Menu data persistence

### Service Discovery

- **Registers with**: Eureka Service Registry (8761)
- **Fetches config from**: Config Server (8888)

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Business Service (Menu Management)
**Maintained By**: ITS 2130 Project Team
