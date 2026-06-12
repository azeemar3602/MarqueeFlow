-- MarqueeFlow MySQL schema (v1.4)
-- Run when MySQL is available: mysql -u user -p marqueeflow < src/db/schema.sql

CREATE DATABASE IF NOT EXISTS marqueeflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE marqueeflow;

CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(120) NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('owner','manager','head_waiter','waiter') NOT NULL,
  status ENUM('active','inactive') DEFAULT 'active',
  business_id CHAR(36) NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS businesses (
  id CHAR(36) PRIMARY KEY,
  owner_id CHAR(36) NOT NULL,
  business_name VARCHAR(200) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  address TEXT NULL,
  currency_code CHAR(3) DEFAULT 'PKR',
  subscription_plan_id VARCHAR(32) NULL,
  status ENUM('active','suspended') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subscription_plans (
  id VARCHAR(32) PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  price_monthly INT NULL,
  currency_code CHAR(3) DEFAULT 'PKR',
  user_limit INT NULL,
  features_json JSON NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  is_recommended TINYINT(1) DEFAULT 0,
  request_custom TINYINT(1) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS business_subscriptions (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  plan_id VARCHAR(32) NOT NULL,
  status ENUM('trial','active','expired','cancelled') NOT NULL,
  trial_start DATETIME NULL,
  trial_end DATETIME NULL,
  current_period_start DATETIME NULL,
  current_period_end DATETIME NULL
);

CREATE TABLE IF NOT EXISTS custom_plan_requests (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  requested_team_size INT NOT NULL,
  contact_name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  note TEXT NULL,
  status ENUM('pending','approved','rejected','follow_up') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS team_members (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  role ENUM('owner','manager','head_waiter','waiter') NOT NULL,
  permissions_json JSON NULL,
  invited_by CHAR(36) NULL,
  status ENUM('active','inactive') DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS team_invites (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  role ENUM('manager','head_waiter') NOT NULL,
  permissions_json JSON NULL,
  invite_token VARCHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  status ENUM('pending','accepted','expired','cancelled') DEFAULT 'pending'
);

CREATE TABLE IF NOT EXISTS customers (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  notes TEXT NULL
);

CREATE TABLE IF NOT EXISTS slots (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  date DATE NOT NULL,
  slot_name ENUM('morning','evening','night') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  capacity INT NOT NULL DEFAULT 1,
  booked_count INT NOT NULL DEFAULT 0,
  status ENUM('available','partial','full','blocked') DEFAULT 'available'
);

CREATE TABLE IF NOT EXISTS packages (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  price INT NOT NULL,
  inclusions_json JSON NULL,
  status ENUM('active','inactive') DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS bookings (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  customer_id CHAR(36) NOT NULL,
  booking_code VARCHAR(20) NOT NULL,
  event_date DATE NOT NULL,
  slot_id CHAR(36) NOT NULL,
  event_type VARCHAR(80) NOT NULL,
  guest_count INT NOT NULL,
  package_id CHAR(36) NULL,
  status ENUM('pending','confirmed','cancelled','completed','refunded') DEFAULT 'pending',
  notes TEXT NULL,
  advance_paid INT DEFAULT 0,
  remaining_amount INT DEFAULT 0,
  payment_status ENUM('unpaid','advance_paid','partially_paid','fully_paid','refunded') DEFAULT 'unpaid',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  booking_id CHAR(36) NOT NULL,
  amount INT NOT NULL,
  payment_type ENUM('advance','partial','full','refund') NOT NULL,
  payment_status ENUM('recorded','void') DEFAULT 'recorded',
  payment_date DATE NOT NULL,
  note TEXT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  user_id CHAR(36) NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(40) NOT NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id CHAR(36) PRIMARY KEY,
  business_id CHAR(36) NOT NULL,
  user_id CHAR(36) NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(40) NOT NULL,
  entity_id CHAR(36) NULL,
  old_value_json JSON NULL,
  new_value_json JSON NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
