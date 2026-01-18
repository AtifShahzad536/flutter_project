# Export Trix PHP API Backend

A complete PHP/MySQL backend API for the Export Trix e-commerce and delivery platform, designed to work with Flutter mobile and web applications.

## Features

- **User Authentication** - Registration, login, JWT-based authentication
- **Role-based Access Control** - Users, Sellers, Riders, Admins
- **Product Management** - CRUD operations for products
- **Order Management** - Complete order lifecycle with rider assignment
- **Dashboard Statistics** - Analytics for riders and admins
- **RESTful API** - Clean, well-structured API endpoints
- **Security** - Password hashing, JWT tokens, input sanitization

## Requirements

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache/Nginx web server
- PDO PHP extension
- JSON PHP extension

## Installation

### 1. Database Setup

1. Create a MySQL database named `export_trix`
2. Import the database schema:

```bash
mysql -u username -p export_trix < database/schema.sql
```

### 2. Configuration

1. Copy and configure the database settings in `config/config.php`:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'export_trix');
define('DB_USER', 'your_mysql_username');
define('DB_PASS', 'your_mysql_password');
```

2. Update the JWT secret key:

```php
define('JWT_SECRET', 'your_unique_jwt_secret_key');
```

### 3. Web Server Setup

#### Apache

Create a `.htaccess` file in the root directory:

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

#### Nginx

Add to your Nginx configuration:

```nginx
location /server-php {
    try_files $uri $uri/ /server-php/index.php?$query_string;
}
```

### 4. Permissions

Ensure the web server can write to the logs directory (if using logging):

```bash
chmod 755 logs/
```

## API Endpoints

### Authentication (`/api/auth`)

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Forgot password
- `GET /api/auth/profile` - Get user profile (requires auth)

### Products (`/api/products`)

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get single product
- `POST /api/products` - Create product (seller/admin only)
- `PUT /api/products/{id}` - Update product (seller/admin only)
- `DELETE /api/products/{id}` - Delete product (seller/admin only)
- `GET /api/products/seller/{seller_id}` - Get products by seller
- `GET /api/products/category/{category}` - Get products by category
- `POST /api/products/search` - Search products (requires auth)

### Orders (`/api/orders`) - All endpoints require authentication

- `POST /api/orders` - Create new order
- `GET /api/orders/my-orders` - Get current user's orders
- `GET /api/orders/available` - Get available orders (riders only)
- `GET /api/orders/{id}` - Get order details
- `POST /api/orders/{id}/pick` - Pick/accept order (riders only)
- `PUT /api/orders/{id}` - Update order status (riders only)
- `GET /api/orders/rider` - Get rider's orders

### Dashboard (`/api/dashboard`)

- `GET /api/dashboard/stats` - Get dashboard statistics (riders)
- `GET /api/dashboard/rider-stats` - Get rider statistics
- `GET /api/dashboard/admin-stats` - Get admin statistics (admins only)

## API Usage Examples

### User Registration

```bash
curl -X POST http://localhost/server-php/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "user",
    "phone": "+1234567890"
  }'
```

### User Login

```bash
curl -X POST http://localhost/server-php/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Create Product (requires auth)

```bash
curl -X POST http://localhost/server-php/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "Laptop Pro",
    "description": "High-performance laptop",
    "price": 1200.00,
    "image_url": "https://example.com/laptop.jpg",
    "category": "Electronics"
  }'
```

### Create Order (requires auth)

```bash
curl -X POST http://localhost/server-php/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "products": [
      {
        "product_id": 1,
        "quantity": 1,
        "price": 1200.00
      }
    ],
    "total_amount": 1200.00,
    "payment_type": "Cash",
    "customer": {
      "name": "Jane Smith",
      "phone": "+1234567890",
      "address": "123 Main St, City"
    },
    "pickup_location": {
      "address": "456 Store Ave, City",
      "lat": 40.7128,
      "lng": -74.0060
    },
    "delivery_location": {
      "address": "123 Main St, City",
      "lat": 40.7589,
      "lng": -73.9851
    }
  }'
```

## User Roles

- **User**: Can place orders and view order history
- **Seller**: Can create and manage products
- **Rider**: Can view available orders, accept assignments, update delivery status
- **Admin**: Full access to all endpoints and admin statistics

## Security Features

- Password hashing using PHP's `password_hash()`
- JWT token-based authentication
- Input sanitization and validation
- SQL injection prevention using prepared statements
- CORS support for cross-origin requests

## Database Schema

The database includes the following main tables:

- `users` - User accounts with role-based permissions
- `products` - Product catalog with seller relationships
- `orders` - Order management with status tracking
- `order_items` - Order items linking products to orders

## Error Handling

The API returns consistent JSON responses:

```json
{
  "success": false,
  "message": "Error description"
}
```

HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `405` - Method Not Allowed
- `500` - Internal Server Error

## Development

### Testing

You can test the API using:

1. Postman collection (create your own based on endpoints)
2. cURL commands (see examples above)
3. Your Flutter application

### Logging

Enable request logging by uncommenting the logging line in `index.php`:

```php
file_put_contents(__DIR__ . '/logs/api_requests.log', json_encode($log_data) . "\n", FILE_APPEND);
```

### Debug Mode

Debug mode is enabled by default in development. Set error reporting to 0 in production:

```php
error_reporting(0);
ini_set('display_errors', 0);
```

## Production Deployment

1. Disable error reporting and display errors
2. Use HTTPS for all API calls
3. Set secure JWT secret key
4. Implement rate limiting
5. Set up proper database backups
6. Monitor API logs for suspicious activity

## Support

For issues and questions, please refer to the API documentation or check the error responses for detailed information.
