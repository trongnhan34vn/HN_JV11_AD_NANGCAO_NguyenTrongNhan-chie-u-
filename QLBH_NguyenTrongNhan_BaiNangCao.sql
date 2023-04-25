CREATE DATABASE QLBH_NguyenTrongNhan;
USE QLBH_NguyenTrongNhan;

CREATE TABLE Customer
(
	cID INT PRIMARY KEY AUTO_INCREMENT,
    `Name` VARCHAR(25),
    cAge TINYINT
);

INSERT INTO Customer (`Name`, cAge) VALUES
("Minh Quan", 10),
("Ngoc Oanh", 20),
("Hong Ha", 50);

CREATE TABLE `Order`
(
	oID INT PRIMARY KEY AUTO_INCREMENT,
	cID INT,
    FOREIGN KEY (cID) REFERENCES Customer(cID),
    oDate DATETIME,
    oToTalPrice INT
);

INSERT INTO `Order` (cID, oDate) VALUES
(1, "2006-03-21"),
(2, "2006-03-23"),
(1, "2006-03-16");

CREATE TABLE Product
(
	pID INT PRIMARY KEY AUTO_INCREMENT,
    pName VARCHAR(25),
    pPrice INT
);

INSERT INTO Product (pName, pPrice) VALUES
("May Giat", 3),
("Tu Lanh", 5),
("Dieu Hoa", 7),
("Quat", 1),
("Bep Dien", 2);

CREATE TABLE OrderDetail
(
	oID INT,
    pID INT,
    odQTY INT,
    FOREIGN KEY (oID) REFERENCES `Order`(oID),
    FOREIGN KEY (pID) REFERENCES Product(pID)
);

INSERT INTO OrderDetail VALUES
(1,1,3),
(1,3,7),
(1,4,2),
(2,1,1),
(3,1,8),
(2,5,4),
(2,3,3);

-- 2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa đơn mới hơn nằm trên
SELECT o.oID, o.cID, o.oDate, o.oTotalPrice FROM `Order` o 
ORDER BY o.oDate DESC;

-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất như sau:
SELECT p.pName, p.pPrice 
FROM Product p 
WHERE pPrice = (
	SELECT Max(pPrice) FROM Product
);

-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách đó như sau:
SELECT c.`Name`, p.pName FROM Customer c
JOIN `Order` o ON o.cID = c.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON p.pID = od.pID;

-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào như sau:
SELECT c.`Name` FROM Customer c 
WHERE c.`Name` NOT IN (
	SELECT cName FROM (
		SELECT c.`Name` AS cName, p.pName FROM Customer c
		JOIN `Order` o ON o.cID = c.cID
		JOIN OrderDetail od ON o.oID = od.oID
		JOIN Product p ON p.pID = od.pID
	) cName
);

-- 6. Hiển thị chi tiết của từng hóa đơnnhư sau : [20]
SELECT o.oID, o.oDate, od.odQTY, p.pName, p.pPrice FROM `Order` o
JOIN OrderDetail od ON od.oID = o.oID
JOIN Product p ON p.pID = od.pID;

-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện trong hoá đơn
SELECT o.oID, o.oDate, SUM(od.odQTY * p.pPrice) AS Total FROM `Order` o
JOIN OrderDetail od ON od.oID = o.oID
JOIN Product p ON p.pID = od.pID
GROUP BY o.oID;

-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị như sau:
SELECT SUM(Total) AS Sales FROM (
	SELECT o.oID, o.oDate, SUM(od.odQTY * p.pPrice) AS Total FROM `Order` o
	JOIN OrderDetail od ON od.oID = o.oID
	JOIN Product p ON p.pID = od.pID
	GROUP BY o.oID
) AS Total;

-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng.
ALTER TABLE OrderDetail 
DROP FOREIGN KEY orderdetail_ibfk_1,
DROP FOREIGN KEY orderdetail_ibfk_2;

ALTER TABLE `Order`
DROP FOREIGN KEY order_ibfk_1;

ALTER TABLE Customer 
MODIFY cID INT PRIMARY KEY;

ALTER TABLE Customer
DROP PRIMARY KEY;

ALTER TABLE `Order`
MODIFY oID INT PRIMARY KEY;

ALTER TABLE `Order`
DROP PRIMARY KEY;

ALTER TABLE Product
MODIFY pID INT PRIMARY KEY;

ALTER TABLE Product
DROP PRIMARY KEY;

-- 10. Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo: 
CREATE TRIGGER cusUpdate 
AFTER UPDATE ON Customer 
FOR EACH ROW
UPDATE `Order` set cID = new.cID WHERE cID = old.cID;

UPDATE Customer 
SET cID = 7 WHERE cID = 2;
SELECT c.cID, o.oID, o.oDate FROM Customer c 
JOIN `Order` o ON o.cID = c.cID;

-- 11. Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong bảng OrderDetail:
DELIMITER //
CREATE PROCEDURE delProduct (
	productName VARCHAR(50)
)
BEGIN 
	DELETE FROM Product WHERE pName = productName;
    DELETE FROM OrderDetail WHERE pID = (SELECT pID FROM Product WHERE pName = productName);
END //
DELIMITER ;

call delProduct("Quat");













