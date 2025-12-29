create database stock
go
use stock
go
CREATE TABLE Users (
    UserId INT IDENTITY PRIMARY KEY,
    Username VARCHAR(50),
    Password VARCHAR(50),
    Role VARCHAR(20)
);
CREATE TABLE Locations (
    LocationId INT IDENTITY PRIMARY KEY,
    LocationName VARCHAR(100)
);
CREATE TABLE SpareParts (
    PartId INT IDENTITY PRIMARY KEY,
    PartCode VARCHAR(50),
    PartName VARCHAR(100),
    Brand VARCHAR(50),
    Model VARCHAR(50),
    Category VARCHAR(50)
);
CREATE TABLE StockTransactions (
    TransactionId INT IDENTITY PRIMARY KEY,
    PartId INT,
    Quantity INT,
    TransactionType VARCHAR(10), -- IN / OUT
    LocationId INT,
    TransactionDate DATETIME DEFAULT GETDATE(),
    UserId INT,
    Reason VARCHAR(100),

    FOREIGN KEY (PartId) REFERENCES SpareParts(PartId),
    FOREIGN KEY (LocationId) REFERENCES Locations(LocationId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
go
CREATE VIEW vw_CurrentStock AS
SELECT 
    sp.PartId,
    sp.PartName,
    l.LocationName,
    SUM(
        CASE 
            WHEN st.TransactionType = 'IN' THEN st.Quantity 
            ELSE -st.Quantity 
        END
    ) AS AvailableStock
FROM StockTransactions st
JOIN SpareParts sp ON st.PartId = sp.PartId
JOIN Locations l ON st.LocationId = l.LocationId
GROUP BY sp.PartId, sp.PartName, l.LocationName;
go
ALTER VIEW vw_CurrentStock AS
SELECT 
    sp.PartId,
    sp.PartCode,
    sp.PartName,
    l.LocationName,
    SUM(
        CASE 
            WHEN st.TransactionType = 'IN' THEN st.Quantity 
            ELSE -st.Quantity 
        END
    ) AS AvailableStock
FROM StockTransactions st
JOIN SpareParts sp ON st.PartId = sp.PartId
JOIN Locations l ON st.LocationId = l.LocationId
GROUP BY 
    sp.PartId,
    sp.PartCode,
    sp.PartName,
    l.LocationName;

go
CREATE VIEW vw_StockInReport AS
SELECT 
    sp.PartName,
    st.Quantity,
    l.LocationName,
    u.Username,
    st.TransactionDate
FROM StockTransactions st
JOIN SpareParts sp ON st.PartId = sp.PartId
JOIN Locations l ON st.LocationId = l.LocationId
JOIN Users u ON st.UserId = u.UserId
WHERE st.TransactionType = 'IN';

go
CREATE VIEW vw_StockOutReport AS
SELECT 
    sp.PartName,
    st.Quantity,
    l.LocationName,
    u.Username,
    st.Reason,
    st.TransactionDate
FROM StockTransactions st
JOIN SpareParts sp ON st.PartId = sp.PartId
JOIN Locations l ON st.LocationId = l.LocationId
JOIN Users u ON st.UserId = u.UserId
WHERE st.TransactionType = 'OUT';
go
CREATE VIEW vw_LowStock AS
SELECT *
FROM vw_CurrentStock
WHERE AvailableStock < 5;
go
ALTER VIEW vw_LowStock AS
SELECT
    PartId,
    PartCode,
    PartName,
    LocationName,
    AvailableStock
FROM vw_CurrentStock
WHERE AvailableStock < 5;
GO
-- USERS
INSERT INTO Users (Username, Password, Role)
VALUES ('admin', '123', 'Admin');

-- LOCATIONS
INSERT INTO Locations (LocationName)
VALUES ('Showroom');

-- SPARE PARTS
INSERT INTO SpareParts (PartCode, PartName, Brand, Model, Category)
VALUES ('BP001', 'Brake Pad', 'Maruti', 'Swift', 'Brake');

INSERT INTO Users (Username, Password, Role) VALUES

('user1', 'user123', 'Staff'),
('user2', 'user234', 'Staff'),
('user3', 'user345', 'Staff'),
('user4', 'user456', 'Staff'),
('user5', 'user567', 'Staff'),
('user6', 'user678', 'Staff'),
('user7', 'user789', 'Staff'),
('user8', 'user890', 'Staff'),
('user9', 'user901', 'Staff');

INSERT INTO Locations (LocationName) VALUES

('Main Warehouse'),
('Spare Parts Room 1'),
('Spare Parts Room 2'),
('Service Center'),
('Repair Bay 1'),
('Repair Bay 2'),
('Front Counter'),
('Back Storage'),
('Temporary Storage');

INSERT INTO SpareParts (PartCode, PartName, Brand, Model, Category) VALUES
('BP002', 'Brake Disc', 'Hyundai', 'i20', 'Brake'),
('OG001', 'Oil Gasket', 'Honda', 'City', 'Engine'),
('FT001', 'Fuel Tank', 'Toyota', 'Corolla', 'Fuel'),
('SP001', 'Spark Plug', 'Maruti', 'Alto', 'Engine'),
('AF001', 'Air Filter', 'Hyundai', 'Verna', 'Filter'),
('CF001', 'Cabin Filter', 'Honda', 'Civic', 'Filter'),
('BP003', 'Brake Caliper', 'Toyota', 'Fortuner', 'Brake'),
('RT001', 'Radiator', 'Maruti', 'Baleno', 'Cooling'),
('WP001', 'Water Pump', 'Hyundai', 'Creta', 'Cooling'),
('AL001', 'Alternator', 'Honda', 'Jazz', 'Electrical'),
('BT001', 'Battery', 'Toyota', 'Yaris', 'Electrical'),
('TL001', 'Tail Light', 'Maruti', 'Swift', 'Lighting'),
('HL001', 'Headlight', 'Hyundai', 'i10', 'Lighting'),
('WN001', 'Windshield Wiper', 'Honda', 'City', 'Accessories'),
('MT001', 'Motor Oil 1L', 'Toyota', 'Corolla', 'Lubricants'),
('MT002', 'Motor Oil 5L', 'Maruti', 'Alto', 'Lubricants'),
('TR001', 'Timing Belt', 'Honda', 'Civic', 'Engine'),
('CL001', 'Clutch Plate', 'Hyundai', 'i20', 'Transmission'),
('GB001', 'Gear Box', 'Toyota', 'Fortuner', 'Transmission');
go
CREATE TABLE Suppliers (
    SupplierId INT IDENTITY PRIMARY KEY,
    SupplierName VARCHAR(100),
    ContactNo VARCHAR(20),
    Address VARCHAR(200)
);

CREATE TABLE GRN (
    GrnId INT IDENTITY PRIMARY KEY,
    GrnNo VARCHAR(30),
    SupplierId INT,
    InvoiceNo VARCHAR(50),
    ReceivedDate DATETIME DEFAULT GETDATE(),
    CreatedBy INT,
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE GRN_Items (
    GrnItemId INT IDENTITY PRIMARY KEY,
    GrnId INT,
    PartId INT,
    Quantity INT,
    LocationId INT,
    FOREIGN KEY (GrnId) REFERENCES GRN(GrnId),
    FOREIGN KEY (PartId) REFERENCES SpareParts(PartId),
    FOREIGN KEY (LocationId) REFERENCES Locations(LocationId)
);

INSERT INTO Suppliers (SupplierName, ContactNo, Address) VALUES
('AutoTech Spares Pvt Ltd', '9876543210', 'Guindy, Chennai'),
('SpeedWay Auto Parts', '9123456780', 'Gandhipuram, Coimbatore'),
('Prime Motors Supplies', '9988776655', 'BTM Layout, Bangalore'),
('DriveLine Components', '9090909090', 'KK Nagar, Madurai'),
('Torque Auto Solutions', '9365478291', 'Thillai Nagar, Trichy'),
('Rapid Gear Distributors', '9445566778', 'Hasthampatti, Salem'),
('Elite Car Accessories', '9797979797', 'Perundurai Road, Erode'),
('Metro Auto Traders', '9551122334', 'T Nagar, Chennai'),
('Highway Spares Hub', '9887766554', 'SIPCOT, Hosur'),
('Velocity Motors India', '9012345678', 'Avinashi Road, Tiruppur');

CREATE TABLE PartUnits (
    UnitId INT IDENTITY PRIMARY KEY,
    GrnId INT,
    PartId INT,
    Barcode VARCHAR(100) UNIQUE,
    LocationId INT,
    Status VARCHAR(10) DEFAULT 'IN',
    CreatedOn DATETIME DEFAULT GETDATE()
);
go
CREATE VIEW vw_GRN_List AS
SELECT
    g.GrnId,
    g.GrnNo,
    s.SupplierName,
    g.InvoiceNo,
    g.ReceivedDate,
    SUM(gi.Quantity) AS TotalQty,
    COUNT(pu.UnitId) AS ScannedUnits
FROM GRN g
JOIN Suppliers s ON g.SupplierId = s.SupplierId
JOIN GRN_Items gi ON g.GrnId = gi.GrnId
LEFT JOIN PartUnits pu ON g.GrnId = pu.GrnId
GROUP BY
    g.GrnId,
    g.GrnNo,
    s.SupplierName,
    g.InvoiceNo,
    g.ReceivedDate;

    ALTER TABLE GRN
ADD CreatedDate DATETIME DEFAULT GETDATE();

ALTER TABLE PartUnits
ADD PartUnitId INT IDENTITY PRIMARY KEY;

ALTER TABLE PartUnits
ADD CreatedDate DATETIME DEFAULT GETDATE();

