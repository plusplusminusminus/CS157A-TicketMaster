DROP DATABASE ticketMaster;

CREATE DATABASE ticketMaster;

USE ticketMaster;

-- CUSTOMER
CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY AUTO_INCREMENT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100) UNIQUE NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	BirthDate DATE NOT NULL
);

-- VENUE
CREATE TABLE Venue (
	VenueID INT PRIMARY KEY AUTO_INCREMENT,
	VenueName VARCHAR(100) NOT NULL,
	Address VARCHAR(100),
	City VARCHAR(50),
	State VARCHAR(2),
	Capacity INT
);

-- EVENT COORDINATOR
CREATE TABLE EventCoordinator (
	CoordinatorID INT PRIMARY KEY AUTO_INCREMENT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100) UNIQUE NOT NULL,
	PhoneNumber VARCHAR(20),
	BirthDate DATE
); 

-- EVENT
CREATE TABLE `Event` (
	EventID INT PRIMARY KEY AUTO_INCREMENT,
	CoordinatorID INT NOT NULL,
	VenueID INT NOT NULL,
	EventName VARCHAR(100) NOT NULL,
	EventDate DATE NOT NULL,
	StartTime TIME NOT NULL,
	EndTime TIME NOT NULL,

	FOREIGN KEY (CoordinatorID) REFERENCES EventCoordinator(CoordinatorID),
	FOREIGN KEY (VenueID) REFERENCES Venue(VenueID)
); 

-- EVENTCOORDINATOREVENT (link table)
CREATE TABLE EventCoordinatorEvent (
	EventCoordinatorEventID INT PRIMARY KEY AUTO_INCREMENT,
    CoordinatorID INTEGER NOT NULL,
    EventID INTEGER NOT NULL,
	FOREIGN KEY (CoordinatorID) REFERENCES EventCoordinator(CoordinatorID),
    FOREIGN KEY (EventID) REFERENCES Event(EventID)
);

-- TICKET
CREATE TABLE Ticket (
	TicketID INT PRIMARY KEY AUTO_INCREMENT,
	EventID INT NOT NULL,
	SeatIdentifier VARCHAR(20) NOT NULL,
	Price DECIMAL(10,2) NOT NULL,
    Status ENUM('Available', 'Reserved', 'Paid', 'Cancelled') DEFAULT 'Available',
	FOREIGN KEY (EventID) REFERENCES Event(EventID)
); 

-- ORDER
CREATE TABLE `Order` (
	OrderID INTEGER PRIMARY KEY AUTO_INCREMENT,
    PurchaseDate DATE NOT NULL,
    CustomerID INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- ORDER ITEM
CREATE TABLE OrderItem (
	OrderItemID INTEGER PRIMARY KEY AUTO_INCREMENT,
    ItemDescription VARCHAR(200) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    OrderID INT NOT NULL,
    TicketID INT NOT NULL,
	FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
	FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

-- WAITLIST (weak entity)
CREATE TABLE Waitlist (
	EventID INT NOT NULL,
	CustomerID INT NOT NULL,
	Status ENUM('Waiting', 'Joined') NOT NULL DEFAULT 'Waiting',
	DateAdded DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (EventID, CustomerID),
	FOREIGN KEY (EventID) REFERENCES `Event`(EventID) ON DELETE CASCADE,
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

-- REVIEW (weak entity)
CREATE TABLE Review (
	EventID INT NOT NULL,
	CustomerID INT NOT NULL,
	Stars TINYINT NOT NULL CHECK (Stars BETWEEN 1 AND 5),
	Comment VARCHAR(500),
	PRIMARY KEY (EventID, CustomerID),
	FOREIGN KEY (EventID) REFERENCES `Event`(EventID) ON DELETE CASCADE,
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

INSERT INTO Customer (FirstName, LastName, Email, PhoneNumber, BirthDate) VALUES
('Mohammed', 'Nassar', 'mohammed.nassar@sjsu.edu', '764-283-2938', '2001-01-01'),
('Kathlyn', 'Malixi', 'kathlyn.malixi@sjsu.edu', '293-292-3849', '2001-05-10'),
('Emily', 'Lu', 'emily.lu@sjsu.edu', '123-567-2839', '2001-04-21'),
('Tyler', 'Moquin', 'tyler.moquin@sjsu.edu', '384-283-2839', '2001-07-21');

INSERT INTO EventCoordinator (FirstName, LastName, PhoneNumber, Email, BirthDate) VALUES
('Rick', 'Astley', '555-293-2839', 'rick.astley@music.com', '2001-05-05');

INSERT INTO Venue (VenueName, Address, City, State, Capacity) VALUES
('SAP Center', '525 West Santa Clara Street, San Jose, CA 95113', 'San Jose', 'CA', 20000);

INSERT INTO `Event` (CoordinatorID, VenueID, EventName, EventDate, StartTime, EndTime) VALUES
(1, 1, 'Music Festival', '2025-11-01', '19:00:00', '21:30:00'),
(1, 1, 'Rock Concert', '2025-12-10', '18:30:00', '22:00:00');

INSERT INTO EventCoordinatorEvent (CoordinatorID, EventID) VALUES
(1, 1);

INSERT INTO Ticket (Price, SeatIdentifier, Status, EventID) VALUES
(75.00, 'A-01', 'available', 1),
(75.00, 'A-02', 'available', 1),
(85.00, 'A-03', 'available', 1);

INSERT INTO `Order` (PurchaseDate, CustomerID) VALUES
('2025-10-20', 1),
('2025-10-21', 2);

INSERT INTO OrderItem (ItemDescription, Price, OrderID, TicketID) VALUES
('Music Festival', 75.00, 1, 1),
('Rock Concert', 85.00, 2, 3);

INSERT INTO Waitlist (EventID, CustomerID, Status, DateAdded) VALUES
(1, 1, 'Waiting', '2025-10-15'),
(1, 3, 'Joined', '2025-10-16');

INSERT INTO Review (Stars, Comment, CustomerID, EventID)
VALUES 
(5, "Hello, this was a good show!", 1, 1),
(5, "Had a Great Time", 2, 1),
(2, "Too loud!", 3, 2);

SELECT * FROM Customer;

SELECT * FROM EventCoordinator;

SELECT * FROM Venue;

SELECT * FROM `Event`;

SELECT * FROM EventCoordinatorEvent;

SELECT * FROM Ticket;

SELECT * FROM `Order`;

SELECT * FROM OrderItem;

SELECT * FROM Review;

SELECT * FROM Waitlist;

-- INNER JOIN retrieves all orders along with the customer information for each purchase
SELECT OrderID, PurchaseDate, FirstName, LastName
FROM `Order` O
JOIN Customer c
ON O.CustomerID = C.CustomerID;

-- INNER JOIN across multiple tables retrieves detailed order items,
-- including ticket details and the corresponding event information
SELECT O.OrderID, OI.ItemDescription, OI.Price, T.SeatIdentifier, E.EventName
FROM OrderItem OI
JOIN `Order` O ON OI.OrderID = O.OrderID
JOIN Ticket T ON OI.TicketID = T.TicketID
JOIN Event E ON T.EventID = E.EventID
ORDER BY O.OrderID, T.SeatIdentifier;

-- OUTER JOIN lists all customers, including those who have not placed any orders
SELECT c.CustomerID, c.FirstName, c.LastName, o.OrderID, o.PurchaseDate
FROM Customer c
LEFT JOIN `Order` o ON c.CustomerID = o.CustomerID;

-- Aggregate query using SUM() and COUNT() to calculate total revenue and number of tickets sold per event
-- Uses HAVING filters out events with no sales
SELECT
	E.EventName,
    SUM(OI.Price) AS TotalRevenue,
    COUNT(OI.OrderItemID) AS TicketsSold
FROM OrderItem AS OI
JOIN Ticket T ON OI.TicketID = T.TicketID
JOIN Event E ON T.EventID = E.EventID
GROUP BY E.EventName
HAVING SUM(OI.Price) > 0
ORDER BY TotalRevenue DESC;

-- SUBQUERY involves an inner query and an outer query (a SELECT statement is inside another statement)
-- Selects the name, date, start time and end time from the event where the venue has a capacity greater than 200
SELECT EventName, EventDate, StartTime, EndTime
FROM Event
WHERE VenueID IN (
    SELECT VenueID
    FROM Venue
    WHERE Capacity > 200
    );
    
-- UPDATE statement only changes already existing elements in the tables
-- Updates phone number of event coordinator with coordinatorID 2
UPDATE EventCoordinator
SET PhoneNumber = '916-533-6428'
WHERE CoordinatorID = 2;

SELECT * FROM EventCoordinator;

-- The trigger fires before the update actually happens
-- It sees that you tried to set the Status to 'Cancelled', but instead changes the new value to 'Available'.
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

DELIMITER ;

-- Test Trigger
INSERT INTO Ticket (Price, SeatIdentifier, Status, EventID) VALUES
(75.00, 'A-04', 'Reserved', 1);

SELECT * FROM Ticket WHERE TicketID = 4;

UPDATE Ticket 
SET Status = 'Cancelled' 
WHERE TicketID = 4;

-- Status should be 'Available'
SELECT * FROM Ticket WHERE TicketID = 4;

-- to speed up event date searches
CREATE INDEX idx_event_date ON `Event`(EventDate);
-- Improves performance when searching for Event by date
-- Example:
SELECT * FROM `Event` WHERE EventDate BETWEEN '2025-12-01' AND '2025-12-31';