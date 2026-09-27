-- Đảm bảo sử dụng đúng cơ sở dữ liệu hệ thống PayFlow
CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

-- 1. Giả định cấu trúc bảng dữ liệu ban đầu phục vụ dự án
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 2. TẠO INDEX TỐI ƯU HÓA TRUY VẤN
-- Tạo Composite Index kết hợp ngày tháng và trạng thái để MySQL quét phạm vi nhanh nhất
CREATE INDEX idx_trans_date_status ON transactions(transaction_date, status);


-- 3. CÂU LỆNH TRUY VẤN ĐÃ ĐƯỢC TỐI ƯU HÓA (Đạt chuẩn SARGable)
-- TRƯỚC TỐI ƯU (Non-SARGable): Tránh dùng hàm YEAR(), MONTH() bọc quanh cột Index gây mất hiệu năng
-- SELECT * FROM transactions WHERE YEAR(transaction_date) = 2026 AND status = 'completed';

-- SAU TỐI ƯU (SARGable): Thay thế bằng so sánh khoảng (Range Scan) giúp MySQL tận dụng triệt để Index
EXPLAIN SELECT 
    transaction_id, 
    user_id, 
    amount, 
    transaction_date, 
    status
FROM transactions
WHERE transaction_date >= '2026-01-01 00:00:00' 
  AND transaction_date <= '2026-12-31 23:59:59'
  AND status = 'completed';
