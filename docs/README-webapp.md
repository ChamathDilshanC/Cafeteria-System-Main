# Web Application - Cafeteria Management System

> Modern Frontend Web Application for Cafeteria Users and Staff

[![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML)
[![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/CSS)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org/)

## 📋 Overview

The Web Application is the frontend interface for the Cafeteria Management System, providing an intuitive user experience for customers to browse menus, place orders, and track their order status. It also includes staff-facing interfaces for managing the kitchen, orders, and menu items. The application communicates exclusively through the **API Gateway** for all backend operations.

## 🚀 Features

### Customer Features

- **User Authentication**: Login and registration
- **Menu Browsing**: View categorized menu items with images
- **Search & Filter**: Find items by name, category, or price
- **Shopping Cart**: Add items, manage quantities, view total
- **Order Placement**: Submit orders with payment method selection
- **Order Tracking**: View real-time order status updates
- **Order History**: View past orders and reorder
- **Profile Management**: Update user information

### Staff Features (Kitchen Staff, Admin)

- **Kitchen Dashboard**: View active orders and queue
- **Order Management**: Update order status (PREPARING, READY)
- **Menu Management**: Add, edit, delete menu items
- **Image Upload**: Upload food images to Google Cloud Storage
- **Category Management**: Organize menu items by categories
- **Staff Assignment**: Assign orders to kitchen staff

## 🛠️ Tech Stack

| Technology        | Version/Type | Purpose                             |
| ----------------- | ------------ | ----------------------------------- |
| HTML5             | -            | Page structure and semantics        |
| CSS3              | -            | Styling and responsive design       |
| JavaScript (ES6+) | -            | Client-side logic and interactivity |
| Fetch API         | -            | HTTP requests to API Gateway        |
| LocalStorage      | -            | JWT token and user session storage  |
| Node.js           | 18+          | Development server (http-server)    |
| API Gateway       | -            | Backend communication endpoint      |

## 📡 Application Configuration

| Property                    | Value                       |
| --------------------------- | --------------------------- |
| **Development Server Port** | `3000`                      |
| **API Gateway Base URL**    | `http://localhost:8080/api` |
| **Token Storage**           | localStorage                |
| **Session Management**      | JWT-based                   |

## 📁 Project Structure

```
webapp/
├── index.html                 # Main landing page
├── login.html                 # Login page
├── register.html              # Registration page
├── menu.html                  # Menu browsing page
├── cart.html                  # Shopping cart page
├── orders.html                # Order history page
├── order-detail.html          # Single order view
├── profile.html               # User profile page
├── kitchen.html               # Kitchen dashboard (staff only)
├── admin.html                 # Admin panel (admin only)
├── css/
│   ├── styles.css            # Global styles
│   ├── menu.css              # Menu-specific styles
│   ├── kitchen.css           # Kitchen dashboard styles
│   └── admin.css             # Admin panel styles
├── js/
│   ├── api.js                # API Gateway communication
│   ├── auth.js               # Authentication logic
│   ├── app.js                # Main application logic
│   ├── menu.js               # Menu page logic
│   ├── cart.js               # Cart management
│   ├── orders.js             # Orders page logic
│   ├── kitchen.js            # Kitchen dashboard logic
│   └── utils.js              # Utility functions
├── assets/
│   ├── images/               # Static images
│   └── icons/                # Icons and logos
└── package.json              # Node.js dependencies (optional)
```

## 📦 Installation & Setup

### Prerequisites

- Node.js 18+ (for development server)
- API Gateway running on `http://localhost:8080`
- All backend services operational

### Install Development Server

```bash
# Install http-server globally
npm install -g http-server

# OR use a different server like live-server
npm install -g live-server
```

### Run Locally

#### Option 1: Using http-server

```bash
cd webapp
http-server -p 3000 -c-1
```

#### Option 2: Using live-server (with auto-reload)

```bash
cd webapp
live-server --port=3000
```

#### Option 3: Using Python (no installation needed)

```bash
cd webapp
python -m http.server 3000
```

### Access Application

```
http://localhost:3000
```

## 🔧 Configuration

### API Gateway Base URL

Update the API base URL in `js/api.js`:

```javascript
// Development
const API_BASE_URL = "http://localhost:8080/api";

// Production (GCP)
// const API_BASE_URL = 'https://your-api-gateway.example.com/api';
```

### Environment-Specific Configuration

Create a `config.js` file for environment-specific settings:

```javascript
// js/config.js
const CONFIG = {
  development: {
    apiBaseUrl: "http://localhost:8080/api",
    imageBaseUrl: "https://storage.googleapis.com/cafeteria-menu-images",
  },
  production: {
    apiBaseUrl: "https://api.cafeteria-system.com/api",
    imageBaseUrl: "https://storage.googleapis.com/cafeteria-menu-images",
  },
};

const ENV = "development"; // Change to 'production' for production
const API_CONFIG = CONFIG[ENV];
```

## 🌐 Key Application Flows

### 1. User Authentication Flow

```
User visits webapp
    ↓
[No token] → Redirect to login.html
    ↓
Enter credentials
    ↓
POST /api/auth/login → API Gateway → User Service
    ↓
Receive JWT token
    ↓
Store token in localStorage
    ↓
Redirect to menu.html
```

### 2. Menu Browsing Flow

```
User visits menu.html
    ↓
GET /api/categories → API Gateway → Menu Service
    ↓
Display categories
    ↓
GET /api/menu/items?category=X → API Gateway → Menu Service
    ↓
Display menu items with images from GCS
    ↓
User clicks "Add to Cart"
    ↓
Store in localStorage cart
```

### 3. Order Placement Flow

```
User reviews cart.html
    ↓
Click "Checkout"
    ↓
POST /api/orders → API Gateway → Order Service
    ↓ (Order Service calls)
    ├─→ User Service (validate user)
    └─→ Menu Service (validate items, get prices)
    ↓
Order created
    ↓
Redirect to order-detail.html
    ↓
Display order status
```

### 4. Kitchen Dashboard Flow (Staff)

```
Kitchen staff opens kitchen.html
    ↓
Authenticate with KITCHEN_STAFF role
    ↓
GET /api/kitchen/queue → API Gateway → Kitchen Service (MongoDB)
    ↓
Display active orders
    ↓
Staff clicks "Start Preparing"
    ↓
POST /api/kitchen/orders/{id}/start → Kitchen Service
    ↓
Update order status in MongoDB
    ↓
Refresh queue display
```

## 💻 Key JavaScript Modules

### api.js - API Communication

```javascript
// js/api.js
const API_BASE_URL = "http://localhost:8080/api";

class ApiService {
  getAuthToken() {
    return localStorage.getItem("authToken");
  }

  async request(endpoint, options = {}) {
    const token = this.getAuthToken();
    const headers = {
      "Content-Type": "application/json",
      ...options.headers,
    };

    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      // Token expired, redirect to login
      localStorage.removeItem("authToken");
      window.location.href = "/login.html";
      return;
    }

    return response.json();
  }

  // Authentication
  async login(email, password) {
    return this.request("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  }

  async register(userData) {
    return this.request("/auth/register", {
      method: "POST",
      body: JSON.stringify(userData),
    });
  }

  // Menu
  async getMenuItems(categoryId = null) {
    const query = categoryId ? `?category=${categoryId}` : "";
    return this.request(`/menu/items${query}`);
  }

  async getCategories() {
    return this.request("/categories");
  }

  // Orders
  async createOrder(orderData) {
    return this.request("/orders", {
      method: "POST",
      body: JSON.stringify(orderData),
    });
  }

  async getOrderById(orderId) {
    return this.request(`/orders/${orderId}`);
  }

  async getUserOrders(userId) {
    return this.request(`/orders/user/${userId}`);
  }

  // Kitchen (staff only)
  async getKitchenQueue() {
    return this.request("/kitchen/queue");
  }

  async startPreparingOrder(orderId, staffId) {
    return this.request(`/kitchen/orders/${orderId}/start`, {
      method: "POST",
      body: JSON.stringify({ staffId }),
    });
  }

  async completeOrder(orderId, staffId) {
    return this.request(`/kitchen/orders/${orderId}/complete`, {
      method: "POST",
      body: JSON.stringify({ staffId }),
    });
  }
}

const api = new ApiService();
```

### auth.js - Authentication Logic

```javascript
// js/auth.js
class AuthManager {
  saveToken(token) {
    localStorage.setItem("authToken", token);
  }

  getToken() {
    return localStorage.getItem("authToken");
  }

  saveUser(user) {
    localStorage.setItem("currentUser", JSON.stringify(user));
  }

  getUser() {
    const userStr = localStorage.getItem("currentUser");
    return userStr ? JSON.parse(userStr) : null;
  }

  logout() {
    localStorage.removeItem("authToken");
    localStorage.removeItem("currentUser");
    window.location.href = "/login.html";
  }

  isAuthenticated() {
    return !!this.getToken();
  }

  hasRole(requiredRole) {
    const user = this.getUser();
    return user && user.role === requiredRole;
  }

  requireAuth() {
    if (!this.isAuthenticated()) {
      window.location.href = "/login.html";
      return false;
    }
    return true;
  }

  requireRole(requiredRole) {
    if (!this.requireAuth()) return false;

    if (!this.hasRole(requiredRole)) {
      alert("Access denied. Insufficient permissions.");
      window.location.href = "/menu.html";
      return false;
    }
    return true;
  }
}

const auth = new AuthManager();
```

### cart.js - Shopping Cart Management

```javascript
// js/cart.js
class CartManager {
  constructor() {
    this.CART_KEY = "cafeteria_cart";
  }

  getCart() {
    const cartStr = localStorage.getItem(this.CART_KEY);
    return cartStr ? JSON.parse(cartStr) : [];
  }

  saveCart(cart) {
    localStorage.setItem(this.CART_KEY, JSON.stringify(cart));
  }

  addItem(menuItem, quantity = 1) {
    const cart = this.getCart();
    const existingItem = cart.find((item) => item.id === menuItem.id);

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.push({
        id: menuItem.id,
        name: menuItem.name,
        price: menuItem.price,
        quantity: quantity,
        imageUrl: menuItem.imageUrl,
      });
    }

    this.saveCart(cart);
    this.updateCartBadge();
  }

  removeItem(itemId) {
    let cart = this.getCart();
    cart = cart.filter((item) => item.id !== itemId);
    this.saveCart(cart);
    this.updateCartBadge();
  }

  updateQuantity(itemId, quantity) {
    const cart = this.getCart();
    const item = cart.find((item) => item.id === itemId);
    if (item) {
      item.quantity = quantity;
      this.saveCart(cart);
      this.updateCartBadge();
    }
  }

  clearCart() {
    localStorage.removeItem(this.CART_KEY);
    this.updateCartBadge();
  }

  getTotal() {
    const cart = this.getCart();
    return cart.reduce((total, item) => total + item.price * item.quantity, 0);
  }

  getItemCount() {
    const cart = this.getCart();
    return cart.reduce((count, item) => count + item.quantity, 0);
  }

  updateCartBadge() {
    const badge = document.getElementById("cart-badge");
    if (badge) {
      const count = this.getItemCount();
      badge.textContent = count;
      badge.style.display = count > 0 ? "inline" : "none";
    }
  }
}

const cart = new CartManager();
```

## 🎨 UI Pages

### 1. Landing Page (index.html)

- Hero section with cafeteria branding
- Quick links to menu, login, register
- Featured items or daily specials

### 2. Login Page (login.html)

```html
<form id="login-form">
  <input type="email" name="email" placeholder="Email" required />
  <input type="password" name="password" placeholder="Password" required />
  <button type="submit">Login</button>
</form>
```

### 3. Menu Page (menu.html)

- Category filter buttons
- Grid layout of menu items with images
- Add to cart buttons
- Search bar

### 4. Cart Page (cart.html)

- List of cart items with quantity controls
- Subtotal, tax, total calculation
- Checkout button
- Continue shopping link

### 5. Kitchen Dashboard (kitchen.html)

**Access**: KITCHEN_STAFF, ADMIN only

- Real-time order queue
- Order status cards (PENDING, PREPARING, READY)
- Drag-and-drop order assignment (optional)
- Staff workload indicator

## 🧪 Testing

### Manual Testing Checklist

✅ **Authentication**

- [ ] User can register with valid data
- [ ] User can login with correct credentials
- [ ] Invalid credentials show error message
- [ ] JWT token is stored in localStorage
- [ ] Logout clears token and redirects to login

✅ **Menu Browsing**

- [ ] Menu items load from API Gateway
- [ ] Images from GCS are displayed correctly
- [ ] Category filtering works
- [ ] Search functionality works
- [ ] Add to cart updates cart badge

✅ **Cart & Checkout**

- [ ] Cart displays correct items and quantities
- [ ] Total calculation is accurate
- [ ] Checkout creates order via API
- [ ] Order confirmation displays

✅ **Kitchen Dashboard**

- [ ] Only staff users can access
- [ ] Queue displays active orders
- [ ] Status updates reflect in MongoDB
- [ ] Real-time updates work (if WebSocket implemented)

### Browser Compatibility

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

## 🐳 Deployment

### Static File Hosting

#### Option 1: Serve with PM2 (alongside backend)

```javascript
// ecosystem.config.js
{
  name: 'webapp',
  script: 'http-server',
  args: ['/path/to/webapp', '-p', '3000', '-c-1'],
  cwd: '/path/to/webapp',
  env: {
    NODE_ENV: 'production'
  }
}
```

```bash
pm2 start ecosystem.config.js --only webapp
```

#### Option 2: GCP Cloud Storage Static Hosting

```bash
# Upload to GCS bucket
gsutil -m cp -r webapp/* gs://cafeteria-webapp-bucket/

# Make bucket public
gsutil iam ch allUsers:objectViewer gs://cafeteria-webapp-bucket

# Enable website configuration
gsutil web set -m index.html -e 404.html gs://cafeteria-webapp-bucket
```

Access at: `https://storage.googleapis.com/cafeteria-webapp-bucket/index.html`

#### Option 3: GCP Cloud Run (Container)

```dockerfile
# Dockerfile
FROM nginx:alpine
COPY webapp/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/webapp
gcloud run deploy webapp --image gcr.io/PROJECT_ID/webapp --platform managed
```

#### Option 4: Nginx on GCP VM

```nginx
# /etc/nginx/sites-available/cafeteria-webapp
server {
    listen 80;
    server_name cafeteria.example.com;

    root /var/www/cafeteria-webapp;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # API Gateway proxy (optional)
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔒 Security Considerations

### Production Security Checklist

✅ **Token Management**

- Store JWT in localStorage (or httpOnly cookies for added security)
- Implement token refresh mechanism
- Clear tokens on logout

✅ **API Communication**

- Use HTTPS in production
- Validate all user inputs
- Sanitize data before display (prevent XSS)

✅ **Access Control**

- Check user roles before rendering staff/admin pages
- Validate permissions on backend (never trust frontend)

✅ **Content Security Policy (CSP)**

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self';
               script-src 'self' 'unsafe-inline';
               style-src 'self' 'unsafe-inline';
               img-src 'self' https://storage.googleapis.com;"
/>
```

## 📊 Performance Optimization

### Best Practices

- ✅ Minify CSS and JavaScript in production
- ✅ Lazy load images
- ✅ Cache API responses where appropriate
- ✅ Use CDN for static assets
- ✅ Implement pagination for long lists
- ✅ Compress images (WebP format)

## 📚 Additional Resources

- [Fetch API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- [LocalStorage Guide](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

## 🔗 Service Integration

### Backend Communication

- **API Gateway** (port 8080): All API requests routed through gateway
  - `/api/auth/**` → User Service
  - `/api/users/**` → User Service
  - `/api/menu/**` → Menu Service
  - `/api/categories/**` → Menu Service
  - `/api/orders/**` → Order Service
  - `/api/kitchen/**` → Kitchen Service

### External Resources

- **Google Cloud Storage**: Menu item images
- **API Gateway**: Single entry point for all backend services

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Frontend Web Application
**Maintained By**: ITS 2130 Project Team
