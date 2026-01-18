-- Export Trix Database Schema
-- MySQL Database

-- Create database
CREATE DATABASE IF NOT EXISTS export_trix;
USE export_trix;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'seller', 'admin', 'rider') DEFAULT 'user',
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    category VARCHAR(100) NOT NULL,
    seller_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE NOT NULL,
    buyer_id INT NOT NULL,
    rider_id INT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_type ENUM('Cash', 'Online') DEFAULT 'Cash',
    payment_status ENUM('Pending', 'Paid') DEFAULT 'Pending',
    status ENUM('Pending', 'Confirmed', 'Picked', 'OnTheWay', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_address TEXT NOT NULL,
    customer_map_link TEXT NULL,
    pickup_address TEXT NOT NULL,
    pickup_lat DECIMAL(10,8) NOT NULL,
    pickup_lng DECIMAL(11,8) NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_lat DECIMAL(10,8) NOT NULL,
    delivery_lng DECIMAL(11,8) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (rider_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Order items table (for products in orders)
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Add indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_rider ON orders(rider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Insert sample data (optional)
-- Sample users
INSERT INTO users (name, email, password, role, phone) VALUES
('Admin User', 'admin@exporttrix.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '+1234567890'),
('John Buyer', 'john@buyer.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', '+1234567891'),
('Jane Seller', 'jane@seller.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'seller', '+1234567892'),
('Mike Rider', 'mike@rider.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'rider', '+1234567893');

-- Sample products
INSERT INTO products (name, description, price, image_url, category, seller_id) VALUES
('Laptop Pro', 'High-performance laptop for professionals', 1200.00, 'https://example.com/laptop.jpg', 'Electronics', 3),
('Wireless Mouse', 'Ergonomic wireless mouse', 25.00, 'https://example.com/mouse.jpg', 'Electronics', 3),
('Office Chair', 'Comfortable office chair with lumbar support', 150.00, 'https://example.com/chair.jpg', 'Furniture', 3);

-- Sample orders
INSERT INTO orders (order_id, buyer_id, total_amount, payment_type, customer_name, customer_phone, customer_address, pickup_address, pickup_lat, pickup_lng, delivery_address, delivery_lat, delivery_lng) VALUES
('ORD001', 2, 25.00, 'Cash', 'John Doe', '+1234567891', '123 Main St, City', '456 Store Ave, City', 40.7128, -74.0060, '123 Main St, City', 40.7589, -73.9851);
