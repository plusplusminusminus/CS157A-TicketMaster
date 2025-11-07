DROP DATABASE ticketMaster;

CREATE DATABASE ticketMaster;

USE ticketMaster;

CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY AUTO_INCREMENT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100) UNIQUE NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	BirthDate DATE NOT NULL
);

CREATE TABLE Venue (
	VenueID INT PRIMARY KEY AUTO_INCREMENT,
	VenueName VARCHAR(100) NOT NULL,
	Address VARCHAR(100),
	City VARCHAR(50),
	State VARCHAR(2),
	Capacity INT
);

CREATE TABLE EventCoordinator (
	CoordinatorID INT PRIMARY KEY AUTO_INCREMENT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100) UNIQUE NOT NULL,
	PhoneNumber VARCHAR(20),
	BirthDate DATE
);

CREATE TABLE Event (
	EventID INT PRIMARY KEY AUTO_INCREMENT,
	CoordinatorID INT NOT NULL,
	VenueID INT NOT NULL,
	EventName VARCHAR(100) NOT NULL,
	Date DATE NOT NULL,
	StartTime TIME NOT NULL,
	EndTime TIME NOT NULL,

	FOREIGN KEY (CoordinatorID) REFERENCES EventCoordinator(CoordinatorID),
	FOREIGN KEY (VenueID) REFERENCES Venue(VenueID)
);

CREATE TABLE Ticket (
	TicketID INT PRIMARY KEY AUTO_INCREMENT,
	EventID INT NOT NULL,
	SeatIdentifier VARCHAR(20) NOT NULL,
	Price DECIMAL(10,2) NOT NULL,
	Status VARCHAR(50) DEFAULT 'Available'
	CHECK (Status IN ('Available', 'Reserved', 'Paid', 'Cancelled')), 
	FOREIGN KEY (EventID) REFERENCES Event(EventID)
);

CREATE TABLE Orders (
	OrderID INTEGER PRIMARY KEY AUTO_INCREMENT,
    PurchaseDate DATE NOT NULL,
    CustomerID INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE OrderItems (
	OrderItemsID INTEGER PRIMARY KEY AUTO_INCREMENT,
    Description VARCHAR(200) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    OrderID INT NOT NULL,
    TicketID INT NOT NULL,
	FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
	FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

INSERT INTO Orders (PurchaseDate, CustomerID) VALUES
('2025-10-20', 1),
('2025-10-21', 2);

INSERT INTO OrderItems (Description, Price, OrderID, TicketID) VALUES
('Music Festival', 75.00, 1, 1),
('Rock Concert', 85.00, 2, 3);

SELECT OrderID, PurchaseDate, FirstName, LastName
FROM Orders O
JOIN Customer C
ON O.CustomerID = C.CustomerID;

SELECT O.OrderID, OI.Description, OI.Price, T.SeatID, E.EventName
FROM OrderItems OI
JOIN Orders O ON OI.OrderID = O.OrderID
JOIN Ticket T ON OI.TicketID = T.TicketID
JOIN Event E ON T.EventID = E.EventID
ORDER BY O.OrderID, T.SeatID;

SELECT EventName, Date, StartTime, EndTime
FROM Event
WHERE VenueID IN (
    SELECT VenueID
    FROM Venue
    WHERE Capacity > 200
    );
    
UPDATE EventCoordinator
SET PhoneNumber = '916-533-6428'
WHERE CoordinatorID = 2;

SELECT * FROM EventCoordinator;

DELIMITER //

CREATE TRIGGER trg_ticket_cancel_to_available
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
-- If the new status is 'Cancelled', automatically make it 'Available' again
IF NEW.Status = 'Cancelled' THEN
SET NEW.Status = 'Available';
END IF;
END //

DELIMITER ;