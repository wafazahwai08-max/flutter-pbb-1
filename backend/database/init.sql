
CREATE DATABASE IF NOT EXISTS products_db;

USE products_db;

CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12,2) NOT NULL DEFAULT 0,
    category VARCHAR(100),
    thumbnail TEXT,
    stock INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO products
(title, description, price, category, thumbnail, stock)
VALUES
('Wireless Headphones', 'Headphone wireless untuk kebutuhan sehari-hari', 650000, 'electronics', '', 20),
('Smart Watch', 'Jam tangan pintar dengan fitur kesehatan', 899000, 'electronics', '', 15),
('Running Shoes', 'Sepatu olahraga untuk aktivitas lari', 450000, 'sports', '', 30);
