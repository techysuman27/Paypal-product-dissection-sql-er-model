CREATE DATABASE IF NOT EXISTS paypal_db;
USE paypal_db;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    account_type ENUM('personal', 'business') NOT NULL,
    verification_status BOOLEAN DEFAULT FALSE
);

CREATE TABLE Profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    phone_number VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE PaymentMethods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    payment_method_type ENUM('credit_card', 'debit_card', 'bank_account') NOT NULL,
    card_number VARBINARY(255), -- Store encrypted
    expiry_date DATE,
    bank_account_number VARBINARY(255), -- Store encrypted
    billing_address_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (billing_address_id) REFERENCES Profiles(profile_id)
);

CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    payment_method_id INT,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    transaction_status ENUM('completed', 'pending', 'refunded') DEFAULT 'pending',
    transaction_type ENUM('payment', 'transfer', 'withdrawal') NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
    FOREIGN KEY (payment_method_id) REFERENCES PaymentMethods(payment_method_id)
);

CREATE TABLE Balances (
    balance_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    amount DECIMAL(10,2) DEFAULT 0.00,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(100),
    notification_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notification_status ENUM('sent', 'read') DEFAULT 'sent',
    transaction_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id)
);

CREATE TABLE Disputes (
    dispute_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    dispute_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    dispute_reason TEXT,
    dispute_status ENUM('open', 'resolved', 'closed') DEFAULT 'open',
    resolution TEXT,
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id),
    FOREIGN KEY (buyer_id) REFERENCES Users(user_id),
    FOREIGN KEY (seller_id) REFERENCES Users(user_id)
);


