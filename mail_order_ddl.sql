CREATE DATABASE IF NOT EXISTS mail_order_db;
USE mail_order_db;

-- Bang luu thong tin nhan vien tiep nhan don hang
CREATE TABLE EMPLOYEE (
    empId INT PRIMARY KEY COMMENT 'Ma nhan vien',
    first_name VARCHAR(50) NOT NULL COMMENT 'Ten nhan vien',
    last_name VARCHAR(50) NOT NULL COMMENT 'Ho nhan vien',
    zip_code VARCHAR(10) COMMENT 'Ma buu chinh khu vuc'
);

-- Bang luu thong tin khach hang
CREATE TABLE CUSTOMER (
    custId INT PRIMARY KEY COMMENT 'Ma khach hang',
    first_name VARCHAR(50) NOT NULL COMMENT 'Ten khach hang',
    last_name VARCHAR(50) NOT NULL COMMENT 'Ho khach hang',
    zip_code VARCHAR(10) COMMENT 'Ma buu chinh khu vuc'
);

-- Bang danh muc linh kien
CREATE TABLE PART (
    partId INT PRIMARY KEY COMMENT 'Ma linh kien',
    part_name VARCHAR(100) NOT NULL COMMENT 'Ten linh kien',
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0) COMMENT 'Don gia linh kien',
    qty_in_stock INT NOT NULL CHECK (qty_in_stock >= 0) COMMENT 'So luong ton kho'
);

-- Bang luu thong tin don dat hang
CREATE TABLE ORDERS (
    orderId INT PRIMARY KEY COMMENT 'Ma don hang',
    empId INT NOT NULL COMMENT 'Ma nhan vien phu trach don',
    custId INT NOT NULL COMMENT 'Ma khach hang dat don',
    receipt_date DATE NOT NULL COMMENT 'Ngay nhan don',
    expected_ship_date DATE COMMENT 'Ngay giao hang du kien',
    actual_ship_date DATE COMMENT 'Ngay giao hang thuc te',
    CONSTRAINT fk_orders_emp FOREIGN KEY (empId) REFERENCES EMPLOYEE(empId),
    CONSTRAINT fk_orders_cust FOREIGN KEY (custId) REFERENCES CUSTOMER(custId)
);

-- Bang chi tiet tung linh kien trong don hang
CREATE TABLE ORDER_DETAILS (
    orderId INT COMMENT 'Ma don hang',
    partId INT COMMENT 'Ma linh kien',
    quantity INT NOT NULL CHECK (quantity > 0) COMMENT 'So luong dat mua',
    PRIMARY KEY (orderId, partId),
    CONSTRAINT fk_detail_order FOREIGN KEY (orderId) REFERENCES ORDERS(orderId) ON DELETE CASCADE,
    CONSTRAINT fk_detail_part FOREIGN KEY (partId) REFERENCES PART(partId)
);

-- Danh index de tim don hang theo khach va tim linh kien theo ten nhanh hon
CREATE INDEX idx_orders_custId ON ORDERS(custId);
CREATE INDEX idx_part_name ON PART(part_name);

-- Thu tuc lay ten khach hang va ten nhan vien phu trach cua mot don hang
DELIMITER //
CREATE PROCEDURE getOrderSummary (
    IN ma_don INT,
    OUT ten_khach VARCHAR(101),
    OUT ten_nv VARCHAR(101)
)
BEGIN
    SELECT 
        CONCAT(c.first_name, ' ', c.last_name), 
        CONCAT(e.first_name, ' ', e.last_name)
    INTO ten_khach, ten_nv
    FROM ORDERS o
    JOIN CUSTOMER c ON o.custId = c.custId
    JOIN EMPLOYEE e ON o.empId = e.empId
    WHERE o.orderId = ma_don;
END //
DELIMITER ;