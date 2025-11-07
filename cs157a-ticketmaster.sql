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

CREATE TABLE EventCoordinatorEvent (
	EventCoordinatorEventID INT PRIMARY KEY AUTO_INCREMENT,
    CoordinatorID INTEGER NOT NULL,
    EventID INTEGER NOT NULL,
	FOREIGN KEY (CoordinatorID) REFERENCES EventCoordinator(CoordinatorID),
    FOREIGN KEY (EventID) REFERENCES Event(EventID)
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

CREATE TABLE `Order` (
	OrderID INTEGER PRIMARY KEY AUTO_INCREMENT,
    PurchaseDate DATE NOT NULL,
    CustomerID INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE OrderItem (
	OrderItemID INTEGER PRIMARY KEY AUTO_INCREMENT,
    ItemDescription VARCHAR(200) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    OrderID INT NOT NULL,
    TicketID INT NOT NULL,
	FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
	FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

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

SELECT OrderID, PurchaseDate, FirstName, LastName
FROM `Order` O
JOIN Customer C
ON O.CustomerID = C.CustomerID;

SELECT O.OrderID, OI.ItemDescription, OI.Price, T.SeatIdentifier, E.EventName
FROM OrderItem OI
JOIN `Order` O ON OI.OrderID = O.OrderID
JOIN Ticket T ON OI.TicketID = T.TicketID
JOIN Event E ON T.EventID = E.EventID
ORDER BY O.OrderID, T.SeatIdentifier;

SELECT EventName, EventDate, StartTime, EndTime
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