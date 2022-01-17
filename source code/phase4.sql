DROP DATABASE IF EXISTS cs4400spring2020;
CREATE DATABASE cs4400spring2020;
USE cs4400spring2020;

-- The following command turns off the Safe Update checks so that your
-- UPDATE and DELETE queries will work without restrictions.  You don't
-- have to replicate this command anywhere else in your code.
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE cs4400spring2020.`User`(
    username VARCHAR(55) PRIMARY KEY,
    `password` VARCHAR(255) NOT NULL,
    firstName VARCHAR(55) NOT NULL,
    lastName VARCHAR(55) NOT NULL,
    UNIQUE(firstName, lastName)
);

CREATE TABLE cs4400spring2020.Building (
	buildingName VARCHAR(55) PRIMARY KEY,
    description TEXT NOT NULL
);

CREATE TABLE cs4400spring2020.Station (
	stationName VARCHAR(55) PRIMARY KEY,
    buildingName VARCHAR(55) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    FOREIGN KEY (buildingName) REFERENCES Building (buildingName)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.Food (
	foodName VARCHAR(55) PRIMARY KEY
);

CREATE TABLE cs4400spring2020.Customer (
	username VARCHAR(55) PRIMARY KEY,
    balance DECIMAL(6, 2) NOT NULL,
    stationName VARCHAR(55),
    FOREIGN KEY (stationName) REFERENCES Station (stationName)
		ON DELETE SET NULL ON UPDATE RESTRICT,
	FOREIGN KEY (username) REFERENCES `User` (username)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE cs4400spring2020.Employee (
	username VARCHAR(55) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (username) REFERENCES `User` (username)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.Manager (
	username VARCHAR(55) PRIMARY KEY,
    FOREIGN KEY (username) REFERENCES Employee (username)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.FoodTruck (
	foodTruckName VARCHAR(55) PRIMARY KEY,
    stationName VARCHAR(55) NOT NULL,
    managerUsername VARCHAR(55) NOT NULL,
    FOREIGN KEY (stationName) REFERENCES Station (stationName)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (managerUsername) REFERENCES Manager (username)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.Staff (
	username VARCHAR(55) PRIMARY KEY,
    foodTruckName VARCHAR(55),
    FOREIGN KEY (username) REFERENCES Employee (username)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (foodTruckName) REFERENCES FoodTruck (foodTruckName)
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE cs4400spring2020.`Admin` (
	username VARCHAR(55) PRIMARY KEY,
    FOREIGN KEY (username) REFERENCES Employee (username)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.Orders (
	orderID INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    customerUsername VARCHAR(55) NOT NULL,
    FOREIGN KEY (customerUsername) REFERENCES Customer (username)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.MenuItem (
	price DECIMAL(6,2) NOT NULL,
    foodTruckName VARCHAR(55) NOT NULL,
    foodName VARCHAR(55) NOT NULL,
    PRIMARY KEY (foodTruckName, foodName),
    FOREIGN KEY (foodName) REFERENCES Food (foodName)
		ON UPDATE RESTRICT ON DELETE RESTRICT,
	FOREIGN KEY (foodTruckName) REFERENCES FoodTruck (foodTruckName)
		ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE cs4400spring2020.BuildingTag (
	buildingName VARCHAR(55) NOT NULL,
    tag VARCHAR(55) NOT NULL,
    PRIMARY KEY (buildingName, tag),
    FOREIGN KEY (buildingName) REFERENCES Building (buildingName)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cs4400spring2020.OrderDetail (
	orderID INT NOT NULL,
    foodTruckName VARCHAR(55) NOT NULL,
    foodName VARCHAR(55) NOT NULL,
    purchaseQuantity INT NOT NULL,
    PRIMARY KEY (orderID, foodTruckName, foodName),
    FOREIGN KEY (orderID) REFERENCES Orders (orderID)
		ON UPDATE RESTRICT ON DELETE RESTRICT,
	FOREIGN KEY (foodTruckName, foodName) REFERENCES MenuItem (foodTruckName, foodName)
		ON UPDATE RESTRICT ON DELETE RESTRICT
);

INSERT INTO cs4400spring2020.Building(buildingName,description) VALUES ("Clough","Has starbucks; located near to transit hub"),("College of Computing","Famously called as CoC"),("CrossLand Tower","Library"),("KLAUS Adv Computing","Connected to CoC through binary bridge"),("Molecular Engineering","Hosts classes for molecular engineering"),("Skiles","Host classes for media and literature students"),("Students_Center","Host for student activities"),("TechTower","Most Iconic building"),("Weber Building","Classes mostly related to space technology");

INSERT INTO cs4400spring2020.Station(stationName,buildingName,capacity) VALUES ("Clough Commons","Clough",20.0),("CoC Court Yard","College of Computing",15.0),("Bio Quad","Molecular Engineering",20.0),("Skiles Walkway","Skiles",11.0),("Campanile","Students_Center",7.0);

INSERT INTO cs4400spring2020.Food(foodName) VALUES ("CeasarSalad"),("Waffles"),("TrailMix"),("ChickenSandwich"),("Nachos"),("ChickenWings"),("HamBurger"),("VegetarianGumbo"),("CheeseBurger"),("Shawarma"),("Noodles"),("ChocolateShake"),("MargheritaPizza"),("Bagels"),("ElkBurger"),("SalmonTacos"),("ChickenTacos"),("SouthWestChickenSalad"),("VegetarianTacos"),("VegSpringRolls"),("VegPizza"),("HotDog"),("Pie"),("ShrimpGumbo");

INSERT INTO cs4400spring2020.BuildingTag(buildingName,tag) VALUES ("College of Computing","Computing"),("Clough","LEED"),("KLAUS Adv Computing","Computing"),("CrossLand Tower","LEED"),("TechTower","ADA"),("Students_Center","LEED"),("TechTower","Registrar"),("Weber Building","ADA"),("Clough","ADA"),("Clough","Labs"),("Weber Building","Sciences"),("Molecular Engineering","Engineering"),("CrossLand Tower","Library"),("Skiles","Liberal Arts");

INSERT INTO cs4400spring2020.`User`(username,`password`,firstname,lastname) VALUES ("2Cool_not_todoschool","4242424242","Smarty","Pants"),("4400_thebestclass","4400440044","Seriously","Itis"),("Aturning_Machine12","3333333333","Alan","Turing"),("beBatman!","5555555555","Bruce","Wayne"),("bestfriends4ever1","44444444433","C3P0","Droid"),("bestfriends4ever2","44444444443","R2D2","Droid"),("BuzzyAsAYellowJacket","1010101010","Buzz","Buzz"),("coxRaycox","4242424242","Ray","Cox"),("customer1","1111111111","One","One"),("customer2","1011111111","Two","Two"),("deer.john","22222022222","John","Deer"),("doe.jane","22222222200","Jane","Doe"),("doe.john","20000000002","John","Doe"),("EmmsBest","1000000011","Emma","Williams"),("employee1","1000111111","Employee","Won"),("Employeeofthemonth","1000011111","Beast","Boy"),("FatherofInfoTheory","2222222222","Claude","Shannon"),("ILikeFlowers","1000000001","Lily","Rose"),("JHallPride","2222222222","James","Hall"),("JNash28TheoryofGaming","1111111111","John","Nash"),("LadyVader1977","54545454545","Leia","Organa"),("LifeIsLikeABoxOfChoco.","4444444444","Forrest","Gump"),("LifeUniverseEverything","4242424242","Forty","Two"),("Manager1","1000001111","First","Manager"),("Manager2","1000000111","Second","Manager"),("Manager3","1000000011","Third","Manager"),("Manager4","1000000001","Fourth","Manager"),("mKJerrY","22222022222","Mike","Jerry"),("Nekonsh","8888888888","Nelsh","Kong"),("RPosince","2222222222","Prince","Ross"),("RRanskans","44444444433","Ruby","Rans"),("scoRa","7000000000","Dhey","Scott"),("sffrgerge","1000000000","Blah","BlahBlah"),("SShen","4444444444","Soms","Shen"),("Staff1","3333333333","One","Staff"),("Staff2","2222222222","Two","Staff"),("notmybusiness","7000000000","Kermit","TheFrog"),("theCustomersAlwaysRight","1001111111","Always","Everytime"),("thereal_GPBurdell","9999999999","George","Burdell"),("TingTong","1000000000","Eva","Bell"),("tkingTom","2222222222","Tom","King"),("TooCuteNottoMention","8888888888","Baby","Yoda"),("toongNonyLongy","20000000002","Tony","Long"),("Violax","4400440044","Violet","Lax"),("WomanWhoSmashedCode","4444444444","Elizabeth","Friedman"),("YayVish","6666666666","Vishy","Yay"),("YouBetterBeNiceToMe","6666666666","Talking","Tina");

-- The following command hashes all of the plaintext passwords that we entered above into a more secure form using MySQL's built-in md5() function
-- Ideally, you would hash the plaintext passwords immediately as they are entered to avoid potential exposure
UPDATE cs4400spring2020.`User` SET `password` = md5(`password`);

INSERT INTO cs4400spring2020.Customer(username,balance,stationName) VALUES ("4400_thebestclass",44.0,"Clough Commons"),("beBatman!",89.99,"Skiles Walkway"),("BuzzyAsAYellowJacket",0.5,"Skiles Walkway"),("coxRaycox",4.5,"CoC Court Yard"),("customer1",46.99,"Clough Commons"),("customer2",47.0,"CoC Court Yard"),("JHallPride",30.9,"Clough Commons"),("LifeUniverseEverything",42.42,"Campanile"),("mKJerrY",44.2,"Bio Quad"),("RPosince",67.89,"Campanile"),("RRanskans",7.78,"Bio Quad"),("sffrgerge",4.09,"Clough Commons"),("notmybusiness",19.55,"Bio Quad"),("theCustomersAlwaysRight",2.99,"CoC Court Yard"),("TingTong",50.25,"Bio Quad"),("tkingTom",70.14,"Skiles Walkway"),("toongNonyLongy",17.9,"Clough Commons"),("Violax",15.2,"Skiles Walkway"),("YouBetterBeNiceToMe",52.63,"Bio Quad");

INSERT INTO cs4400spring2020.Employee(username,email) VALUES ("2Cool_not_todoschool","school@gmail.com"),("4400_thebestclass","4400_thebestclass@gatech.edu"),("Aturning_Machine12","machine12@outlook.com"),("beBatman!","beBatman!@gatech.edu"),("bestfriends4ever1","bff@hotmail.com"),("bestfriends4ever2","bff2@gmail.com"),("BuzzyAsAYellowJacket","BuzzyAsAYellowJacket@gatech.edu"),("deer.john","dj3@outlook.com"),("doe.jane","dj1@outlook.com"),("doe.john","dj2@outlook.com"),("EmmsBest","emmsbest@gatech.edu"),("employee1","employee1@gatech.edu"),("Employeeofthemonth","Employeeofthemonth@gatech.edu"),("FatherofInfoTheory","fot@gmail.com"),("ILikeFlowers","flora@gatech.edu"),("JNash28TheoryofGaming","jg@hotmail.com"),("LadyVader1977","lv1977@gatech.edu"),("LifeIsLikeABoxOfChoco.","chocolate@gmail.com"),("Manager1","manager1@gatech.edu"),("Manager2","manager2@gatech.edu"),("Manager3","manager3@gatech.edu"),("Manager4","manager4@gatech.edu"),("Nekonsh","nekonsh@gatech.edu"),("RRanskans","rranskans@gatech.edu"),("scoRa","scoRa@gatech.edu"),("sffrgerge","sff@outlook.com"),("SShen","sshen@gatech.edu"),("Staff1","staff1@gatech.edu"),("Staff2","staff2@gatech.edu"),("thereal_GPBurdell","gpb@gatech.edu"),("TingTong","tingtong@gatech.edu"),("TooCuteNottoMention","mention@gmail.com"),("Violax","violax@gatech.edu"),("WomanWhoSmashedCode","smashedcode@gmail.com"),("YayVish","yayvish@gatech.edu");

INSERT INTO cs4400spring2020.`Admin`(username) VALUES ("4400_thebestclass"),("Nekonsh"),("scoRa");

INSERT INTO cs4400spring2020.Manager(username) VALUES ("doe.jane"),("FatherofInfoTheory"),("LadyVader1977"),("LifeIsLikeABoxOfChoco."),("Manager1"),("Manager2"),("Manager3"),("Manager4"),("SShen"),("thereal_GPBurdell"),("YayVish");

INSERT INTO cs4400spring2020.FoodTruck(foodTruckName,managerUsername,stationName) VALUES ("JohnJaneAndVenison","doe.jane","Campanile"),("FourAnalystInATacoTruck","FatherofInfoTheory","Clough Commons"),("GoodFoodTruck","FatherofInfoTheory","CoC Court Yard"),("BurgerBird","LadyVader1977","Clough Commons"),("FoodTrolley","LadyVader1977","Skiles Walkway"),("FoodTruckYoureLookingFor","LadyVader1977","Campanile"),("BubbaGumps","LifeIsLikeABoxOfChoco.","Campanile"),("CrazyPies","Manager1","Campanile"),("NachoBizness","Manager2","Campanile"),("TruckOfFood","Manager2","Campanile"),("ShawarmaExpress","Manager3","Bio Quad"),("WaffleTruffle","SShen","CoC Court Yard"),("GoodOnAStudentBudget","thereal_GPBurdell","Bio Quad"),("FusionFoodTruck","YayVish","Campanile");

INSERT INTO cs4400spring2020.Staff(username,foodTruckName) VALUES ("2Cool_not_todoschool","WaffleTruffle"),("Aturning_Machine12","FourAnalystInATacoTruck"),("beBatman!","WaffleTruffle"),("bestfriends4ever1","FoodTruckYoureLookingFor"),("bestfriends4ever2","BurgerBird"),("BuzzyAsAYellowJacket","ShawarmaExpress"),("deer.john","JohnJaneAndVenison"),("doe.john","TruckOfFood"),("EmmsBest","CrazyPies"),("employee1","BurgerBird"),("Employeeofthemonth","ShawarmaExpress"),("ILikeFlowers","CrazyPies"),("JNash28TheoryofGaming","GoodFoodTruck"),("RRanskans","FoodTrolley"),("sffrgerge","GoodOnAStudentBudget"),("Staff1","BubbaGumps"),("Staff2","BubbaGumps"),("TingTong","FusionFoodTruck"),("TooCuteNottoMention","NachoBizness"),("Violax","FoodTrolley"),("WomanWhoSmashedCode","FourAnalystInATacoTruck");

INSERT INTO cs4400spring2020.MenuItem(price,foodTruckName,foodName) VALUES (3.21,"FoodTruckYoureLookingFor","Nachos"),(9.06,"GoodFoodTruck","SouthWestChickenSalad"),(4.51,"FoodTrolley","Pie"),(4.28,"CrazyPies","MargheritaPizza"),(4.51,"GoodOnAStudentBudget","CheeseBurger"),(4.36,"JohnJaneAndVenison","TrailMix"),(6.22,"BubbaGumps","ShrimpGumbo"),(4.4,"GoodFoodTruck","Noodles"),(5.48,"GoodOnAStudentBudget","ChocolateShake"),(2.23,"GoodOnAStudentBudget","HotDog"),(6.65,"WaffleTruffle","Waffles"),(6.58,"NachoBizness","ChickenTacos"),(8.03,"FourAnalystInATacoTruck","SalmonTacos"),(4.7,"NachoBizness","VegetarianTacos"),(7.88,"FoodTruckYoureLookingFor","VegPizza"),(6.3,"ShawarmaExpress","Shawarma"),(3.82,"GoodOnAStudentBudget","HamBurger"),(5.95,"FusionFoodTruck","VegetarianTacos"),(3.53,"TruckOfFood","VegSpringRolls"),(5.21,"BubbaGumps","ChickenTacos"),(5.28,"FourAnalystInATacoTruck","ChickenWings"),(9.57,"FoodTruckYoureLookingFor","SouthWestChickenSalad"),(3.48,"CrazyPies","VegPizza"),(7.59,"NachoBizness","SalmonTacos"),(3.46,"GoodOnAStudentBudget","CeasarSalad"),(7.16,"FusionFoodTruck","SalmonTacos"),(5.82,"FoodTrolley","Waffles"),(6.22,"FourAnalystInATacoTruck","ChickenTacos"),(6.01,"FoodTrolley","ChickenWings"),(4.85,"ShawarmaExpress","ChocolateShake"),(3.11,"GoodFoodTruck","VegSpringRolls"),(6.68,"BurgerBird","ElkBurger"),(4.53,"BurgerBird","Pie"),(3.82,"BubbaGumps","VegetarianGumbo"),(4.19,"CrazyPies","Pie"),(7.54,"FoodTrolley","ChocolateShake"),(5.13,"NachoBizness","Nachos"),(7.05,"BurgerBird","HamBurger"),(4.77,"TruckOfFood","Noodles"),(3.44,"GoodOnAStudentBudget","Waffles"),(5.84,"FourAnalystInATacoTruck","VegetarianTacos"),(4.76,"BurgerBird","CheeseBurger"),(7.58,"FoodTruckYoureLookingFor","MargheritaPizza"),(10.17,"JohnJaneAndVenison","ElkBurger");

INSERT INTO cs4400spring2020.Orders(customerUsername,date) VALUES ("customer1","2020-01-01"),("customer1","2020-01-01"),("customer2","2020-01-01"),("customer2","2020-02-01"),("customer1","2020-02-02"),("customer2","2020-02-03"),("theCustomersAlwaysRight","2020-02-04"),("theCustomersAlwaysRight","2020-02-04"),("notmybusiness","2020-02-04"),("customer1","2020-02-04"),("customer2","2020-02-05"),("theCustomersAlwaysRight","2020-02-05"),("notmybusiness","2020-02-05"),("notmybusiness","2020-02-05"),("notmybusiness","2020-02-06"),("theCustomersAlwaysRight","2020-02-06"),("notmybusiness","2020-02-06"),("customer1","2020-02-10"),("customer2","2020-02-10"),("customer2","2020-02-10"),("customer2","2020-02-10"),("BuzzyAsAYellowJacket","2020-02-10"),("BuzzyAsAYellowJacket","2020-02-10"),("customer1","2020-02-10"),("customer2","2020-02-10"),("BuzzyAsAYellowJacket","2020-02-11"),("customer2","2020-02-11"),("customer2","2020-02-22"),("customer2","2020-02-29"),("customer1","2020-02-29"),("customer1","2020-03-01"),("customer2","2020-03-01"),("customer2","2020-03-01"),("sffrgerge","2020-03-01"),("sffrgerge","2020-03-01"),("customer1","2020-03-01"),("LifeUniverseEverything","2020-03-01"),("beBatman!","2020-03-01"),("beBatman!","2020-03-01"),("YouBetterBeNiceToMe","2020-03-01"),("YouBetterBeNiceToMe","2020-03-01");

INSERT INTO cs4400spring2020.OrderDetail(orderID,foodTruckName,foodName,purchaseQuantity) VALUES (35,"GoodOnAStudentBudget","Waffles",1),(31,"FourAnalystInATacoTruck","ChickenTacos",3),(26,"FoodTrolley","Pie",1),(26,"FoodTrolley","ChickenWings",6),(7,"BurgerBird","HamBurger",2),(24,"TruckOfFood","VegSpringRolls",5),(6,"FourAnalystInATacoTruck","SalmonTacos",1),(7,"BurgerBird","ElkBurger",2),(36,"GoodOnAStudentBudget","HamBurger",1),(36,"GoodOnAStudentBudget","ChocolateShake",1),(40,"CrazyPies","VegPizza",1),(31,"FourAnalystInATacoTruck","ChickenWings",5),(17,"ShawarmaExpress","Shawarma",6),(27,"FoodTruckYoureLookingFor","VegPizza",1),(11,"NachoBizness","ChickenTacos",1),(15,"FoodTrolley","ChickenWings",1),(22,"GoodOnAStudentBudget","Waffles",3),(6,"FourAnalystInATacoTruck","ChickenTacos",3),(11,"NachoBizness","SalmonTacos",3),(8,"ShawarmaExpress","Shawarma",2),(3,"GoodOnAStudentBudget","Waffles",2),(16,"FoodTrolley","ChickenWings",2),(1,"CrazyPies","Pie",2),(32,"BurgerBird","Pie",1),(22,"GoodOnAStudentBudget","CheeseBurger",1),(31,"FourAnalystInATacoTruck","SalmonTacos",3),(23,"GoodOnAStudentBudget","ChocolateShake",2),(10,"TruckOfFood","VegSpringRolls",3),(34,"FourAnalystInATacoTruck","ChickenWings",5),(38,"BubbaGumps","ChickenTacos",7),(32,"BurgerBird","CheeseBurger",3),(41,"BubbaGumps","VegetarianGumbo",1),(37,"BurgerBird","CheeseBurger",1),(19,"FourAnalystInATacoTruck","VegetarianTacos",3),(22,"GoodOnAStudentBudget","CeasarSalad",5),(13,"FoodTrolley","ChocolateShake",1),(20,"FourAnalystInATacoTruck","VegetarianTacos",2),(28,"BurgerBird","CheeseBurger",1),(14,"GoodOnAStudentBudget","HamBurger",4),(2,"GoodOnAStudentBudget","HotDog",1),(29,"FourAnalystInATacoTruck","ChickenWings",6),(33,"FoodTrolley","Pie",1),(41,"BubbaGumps","ShrimpGumbo",1),(24,"TruckOfFood","Noodles",1),(33,"FoodTrolley","Waffles",2),(40,"CrazyPies","MargheritaPizza",1),(35,"GoodOnAStudentBudget","CeasarSalad",2),(23,"GoodOnAStudentBudget","HamBurger",1),(25,"BurgerBird","Pie",1),(31,"FourAnalystInATacoTruck","VegetarianTacos",1),(21,"GoodOnAStudentBudget","ChocolateShake",1),(6,"FourAnalystInATacoTruck","ChickenWings",4),(33,"FoodTrolley","ChickenWings",5),(5,"NachoBizness","SalmonTacos",3),(18,"WaffleTruffle","Waffles",4),(12,"FoodTruckYoureLookingFor","MargheritaPizza",2),(34,"FourAnalystInATacoTruck","SalmonTacos",3),(21,"GoodOnAStudentBudget","CheeseBurger",1),(4,"FoodTrolley","ChickenWings",4),(3,"GoodOnAStudentBudget","CheeseBurger",1),(9,"JohnJaneAndVenison","TrailMix",2),(41,"BubbaGumps","ChickenTacos",1),(22,"GoodOnAStudentBudget","HotDog",1),(26,"FoodTrolley","Waffles",2),(39,"NachoBizness","Nachos",2),(11,"NachoBizness","Nachos",4),(30,"BubbaGumps","VegetarianGumbo",1),(1,"CrazyPies","VegPizza",1),(1,"CrazyPies","MargheritaPizza",1),(3,"GoodOnAStudentBudget","HamBurger",1),(11,"NachoBizness","VegetarianTacos",3),(10,"TruckOfFood","Noodles",1),(20,"FourAnalystInATacoTruck","ChickenWings",1),(12,"FoodTruckYoureLookingFor","VegPizza",2),(21,"GoodOnAStudentBudget","HamBurger",3),(26,"FoodTrolley","ChocolateShake",2),(2,"GoodOnAStudentBudget","CeasarSalad",1),(34,"FourAnalystInATacoTruck","ChickenTacos",3);

DROP VIEW IF EXISTS login_classifier;
CREATE VIEW login_classifier AS
SELECT username, 'Admin' AS userType FROM `Admin`
WHERE username NOT IN (SELECT username FROM Customer)
UNION
SELECT username, 'Manager' AS userType FROM Manager
WHERE username NOT IN (SELECT username FROM Customer)
UNION
SELECT username, 'Staff' AS userType FROM Staff
WHERE username NOT IN (SELECT username FROM Customer)
UNION
SELECT username, 'Admin-Customer' AS userType FROM `Admin`
WHERE username in (SELECT username FROM Customer)
UNION
SELECT username, 'Manager-Customer' AS userType FROM Manager
WHERE username in (SELECT username FROM Customer)
UNION
SELECT username, 'Staff-Customer' AS userType FROM Staff
WHERE username in (SELECT username FROM Customer)
UNION
SELECT username, 'Customer' AS userType FROM Customer
WHERE username NOT IN (SELECT username FROM Employee);

-- Query #1: login [Screen #1 Login]
DROP PROCEDURE IF EXISTS login;
DELIMITER //
CREATE PROCEDURE login(
				IN i_username VARCHAR(50),
				IN i_password VARCHAR(50))
sp_main: BEGIN
	DROP TABLE IF EXISTS login_result;
    CREATE TABLE login_result (
		username VARCHAR(50),
		userType ENUM('Customer', 'Admin', 'Staff', 'Manager', 'Admin-Customer', 'Staff-Customer', 'Manager-Customer')
    );

	IF NOT EXISTS (SELECT username, `password` FROM `User`
		WHERE username = i_username AND `password` = md5(i_password)) THEN SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'An error occurred'; LEAVE sp_main; END IF;

    INSERT INTO login_result
    SELECT username, userType FROM login_classifier WHERE username = i_username;

END //
DELIMITER ;

-- Query #2: register  [Screen #2 Register]
-- Don't need to check email format (XXX@XXX.XXX)
-- Make sure you check balance > 0 for customer
-- Make sure you check password length >= 8
DROP PROCEDURE IF EXISTS register;
DELIMITER //
CREATE PROCEDURE register(
				IN i_username VARCHAR(50),
				IN i_email VARCHAR(50),
                IN i_firstname VARCHAR(50),
                IN i_lastname VARCHAR(50),
                IN i_password VARCHAR(50),
                IN i_balance DECIMAL(6,2),
                IN i_type ENUM('Admin', 'Manager', 'Staff'))
register_main:BEGIN

    if (length(i_password) < 8) THEN
		leave register_main;
	end if;
    
    if (i_balance is not NULL) THEN
		if (i_balance <= 0) then
			leave register_main;
        end if;
	end if;
    
    insert into user
    values (i_username, md5(i_password), i_firstname, i_lastname);
    if (i_email is not null and i_email != "" and i_type in ('Admin', 'Manager', 'Staff')) then
		insert into employee
        values (i_username, i_email);
        if (i_type = 'Admin') then
			insert into `admin`
            values (i_username);
		end if;
        if (i_type = 'Staff') then
			insert into staff
            values (i_username, NULL);
		end if;
        if (i_type = 'Manager') then
			insert into manager
            values (i_username);
		end if;
	end if;
    if (i_balance is not null) then
		insert into customer
        values (i_username, i_balance, NULL);
	end if;

END //
DELIMITER ;

-- Query #3: ad_filter_building_station [Screen #4 Admin Manage Building & Station]
DROP PROCEDURE IF EXISTS ad_filter_building_station;
DELIMITER //
CREATE PROCEDURE ad_filter_building_station(
				IN i_buildingName VARCHAR(50),
				IN i_buildingTag VARCHAR(50),
                IN i_stationName VARCHAR(50),
                IN i_minCapacity INT,
                IN i_maxCapacity INT)
BEGIN
	DROP TABLE IF EXISTS ad_filter_building_station_result;
	CREATE TABLE ad_filter_building_station_result(
		buildingName varchar(100), tags text,
        stationName varchar(100), capacity int, foodTruckNames text
	);
    
	INSERT INTO ad_filter_building_station_result
    SELECT innerTable.buildingName, GROUP_CONCAT(BT2.tag) as "tags", innerTable.stationName, innerTable.capacity, foodTruckNames FROM 
		(SELECT buildingInfo.buildingName, stationInfo.stationName, stationInfo.capacity, foodTruckNames FROM
			(SELECT DISTINCT B.buildingName FROM Building as B LEFT JOIN BuildingTag as BT on B.buildingName = BT.buildingName WHERE (i_buildingTag is NULL OR i_buildingTag = "" OR BT.tag LIKE CONCAT('%', i_buildingTag, '%'))) as buildingInfo LEFT JOIN
			(SELECT S.stationName, S.capacity, S.buildingName, GROUP_CONCAT(F.foodTruckName) as "foodTruckNames" FROM Station as S LEFT JOIN FoodTruck as F on S.stationName = F.stationName GROUP BY S.stationName) as stationInfo
		ON buildingInfo.buildingName = stationInfo.buildingName
		GROUP BY buildingInfo.buildingName) as innerTable
	LEFT JOIN BuildingTag as BT2 on innerTable.buildingName = BT2.buildingName
	WHERE (i_buildingName is NULL OR i_buildingName = "" OR innerTable.buildingName = i_buildingName)
    AND (i_stationName is NULL OR i_stationName = "" OR innerTable.stationName = i_stationName)
    AND (i_minCapacity is NULL OR innerTable.capacity >= i_minCapacity)
    AND (i_maxCapacity is NULL OR innerTable.capacity <= i_maxCapacity)
	GROUP BY innerTable.buildingName;
END //
DELIMITER ;

-- Query #4: ad_delete_building [Screen #4 Admin Manage Building & Station]
DROP PROCEDURE IF EXISTS ad_delete_building;
DELIMITER //
CREATE PROCEDURE ad_delete_building(
				IN i_buildingName VARCHAR(50))
BEGIN

	DELETE FROM Building WHERE buildingName = i_buildingName;

END //
DELIMITER ;

-- Query #5: ad_delete_station [Screen #4 Admin Manage Building & Station]
DROP PROCEDURE IF EXISTS ad_delete_station;
DELIMITER //
CREATE PROCEDURE ad_delete_station(
                IN i_stationName VARCHAR(50))
BEGIN

	DELETE FROM Station WHERE stationName = i_stationName;

END //
DELIMITER ;

-- Query #6a: ad_add_building_tag [Screen #5 Admin Add Building Tag]
DROP PROCEDURE IF EXISTS ad_add_building_tag;
DELIMITER //
CREATE PROCEDURE ad_add_building_tag(IN i_buildingName VARCHAR(55), IN i_tag VARCHAR(55))
BEGIN

    INSERT INTO BuildingTag VALUES (i_buildingName, i_tag);

END //
DELIMITER ;

-- Query #6b: ad_remove_building_tag [Screen #5 Admin Remove Building Tag]
DROP PROCEDURE IF EXISTS ad_remove_building_tag;
DELIMITER //
CREATE PROCEDURE ad_remove_building_tag(IN i_buildingName VARCHAR(55), IN i_tag VARCHAR(55))
BEGIN

    DELETE FROM BuildingTag WHERE buildingName = i_buildingName AND tag = i_tag;

END //
DELIMITER ;

-- Query #7: ad_create_building [Screen #5 Admin Create Building]
DROP PROCEDURE IF EXISTS ad_create_building;
DELIMITER //
CREATE PROCEDURE ad_create_building(IN i_buildingName VARCHAR(55), IN i_description TEXT)
BEGIN

	INSERT INTO Building VALUES (i_buildingName, i_description);

END //
DELIMITER ;

-- Query #8a: ad_view_building_general [Screen #6 Admin Update Building]
DROP PROCEDURE IF EXISTS ad_view_building;
DELIMITER //
CREATE PROCEDURE ad_view_building_general(IN i_buildingName VARCHAR(55))
BEGIN
    DROP TABLE IF EXISTS ad_view_building_general_result;
    CREATE TABLE ad_view_building_general_result(buildingName varchar(55), `description` text);

    INSERT INTO ad_view_building_general_result
    SELECT buildingName, description
    FROM Building
    WHERE buildingName = i_buildingName;

END //
DELIMITER ;

-- Query #8b: ad_view_building_tags [Screen #6 Admin Update Building]
DROP PROCEDURE IF EXISTS ad_view_building_tags;
DELIMITER //
CREATE PROCEDURE ad_view_building_tags(IN i_buildingName VARCHAR(55))
BEGIN
    DROP TABLE IF EXISTS ad_view_building_tags_result;
    CREATE TABLE ad_view_building_tags_result(tag VARCHAR(55));

    INSERT INTO ad_view_building_tags_result
    SELECT tag
    FROM BuildingTag
    WHERE buildingName = i_buildingName;

END //
DELIMITER ;

-- Query #9: ad_update_building [Screen #6 Admin Update Building]
DROP PROCEDURE IF EXISTS ad_update_building;
DELIMITER //
CREATE PROCEDURE ad_update_building(IN i_oldBuildingName VARCHAR(55), IN i_newBuildingName VARCHAR(55), IN i_description TEXT)
BEGIN
    UPDATE Building
    SET buildingName = i_newBuildingName, `description` = i_description
    WHERE buildingName = i_oldBuildingName;

END //
DELIMITER ;

-- Query #10: ad_get_available_building [Screen #7 Admin Create Station]
DROP PROCEDURE IF EXISTS ad_get_available_building;
DELIMITER //
CREATE PROCEDURE ad_get_available_building()
BEGIN
    DROP TABLE IF EXISTS ad_get_available_building_result;
    CREATE TABLE ad_get_available_building_result(buildingName varchar(100));

    INSERT INTO ad_get_available_building_result
    SELECT buildingName
    FROM Building
    WHERE buildingName NOT IN (SELECT buildingName FROM Station);

END //
DELIMITER ;

-- Query #11: ad_create_station [Screen #7 Admin Create Station]
DROP PROCEDURE IF EXISTS ad_create_station;
DELIMITER //
CREATE PROCEDURE ad_create_station(IN i_stationName VARCHAR(100), IN  i_buildingName VARCHAR(100), IN i_capacity INT)
BEGIN

    IF i_buildingName in (
        SELECT buildingName
        FROM ad_get_available_building_result) THEN
        INSERT INTO Station (stationName, buildingName, capacity)
        VALUES (i_stationName,  i_buildingName, i_capacity);
    END IF;

END //
DELIMITER ;

-- Query #12: ad_view_station [Screen #8 Admin Update Station]
DROP PROCEDURE IF EXISTS ad_view_station;
DELIMITER //
CREATE PROCEDURE ad_view_station(IN i_stationName VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS ad_view_station_result;
    CREATE TABLE ad_view_station_result(stationName varchar(100), capacity int, buildingName varchar(100));

	INSERT INTO ad_view_station_result
    SELECT stationName, capacity, buildingName
    FROM Station
    WHERE stationName = i_stationName;

END //
DELIMITER ;

-- Query #13: ad_update_station [Screen #8 Admin Update Station]
DROP PROCEDURE IF EXISTS ad_update_station;
DELIMITER //
CREATE PROCEDURE ad_update_station(IN i_stationName VARCHAR(100), IN i_capacity INT, IN i_buildingName VARCHAR(100))
BEGIN

    UPDATE Station
    SET capacity = i_capacity, buildingName = i_buildingName
    WHERE stationName = i_stationName;

END //
DELIMITER ;

-- Query #14: ad_filter_food [Screen #9 Admin Manage Food]
DROP PROCEDURE IF EXISTS ad_filter_food;
DELIMITER //
CREATE PROCEDURE ad_filter_food(IN i_foodName VARCHAR(100), IN i_sortedBy ENUM('name', 'menuCount', 'purchaseCount'), IN i_sortDirection ENUM('ASC', 'DESC'))
BEGIN
    DROP TABLE IF EXISTS ad_filter_food_result;
    CREATE TABLE ad_filter_food_result(foodName varchar(100), menuCount int, purchaseCount int);

	INSERT INTO ad_filter_food_result
	SELECT * FROM
		(SELECT MenuCounts.foodName, MenuCounts.menuCount, COALESCE(SUM(OrderDetail.purchaseQuantity), 0) AS purchaseCount FROM 
			(SELECT Food.foodName, count(MenuItem.foodTruckName) AS menuCount FROM Food LEFT JOIN MenuItem ON Food.foodName = MenuItem.foodName GROUP BY foodName) AS MenuCounts
		LEFT JOIN OrderDetail 
		ON MenuCounts.foodName = OrderDetail.foodName
		GROUP BY MenuCounts.foodName) as innerTable
    WHERE (i_foodName = '' OR i_foodName is NULL OR foodName = i_foodName)
    ORDER BY
        CASE WHEN (i_sortedBy = "name" AND (i_sortDirection = "ASC" OR i_sortDirection = NULL)) THEN foodName END ASC,
        CASE WHEN i_sortedBy = "name" AND i_sortDirection = "DESC" THEN foodName END DESC,
		CASE WHEN i_sortedBy = "menuCount" AND (i_sortDirection = "ASC" OR i_sortDirection = NULL) THEN menuCount END ASC,
		CASE WHEN i_sortedBy = "menuCount" AND i_sortDirection = "DESC" THEN menuCount END DESC,
		CASE WHEN i_sortedBy = "purchaseCount" AND (i_sortDirection = "ASC" OR i_sortDirection = NULL) THEN purchaseCount END ASC,
		CASE WHEN i_sortedBy = "purchaseCount" AND i_sortDirection = "DESC" THEN purchaseCount END DESC;
        
END //
DELIMITER ;

-- Query #15: ad_delete_food [Screen #9 Admin Manage Food]
DROP PROCEDURE IF EXISTS ad_delete_food;
DELIMITER //
CREATE PROCEDURE ad_delete_food(IN i_foodName VARCHAR(100))
BEGIN

    DELETE FROM Food
    WHERE foodName = i_foodName;

END //
DELIMITER ;

-- Query #16: ad_create_food [Screen #10 Admin Create Food]
DROP PROCEDURE IF EXISTS ad_create_food;
DELIMITER //
CREATE PROCEDURE ad_create_food(IN i_foodName VARCHAR(100))
BEGIN

    INSERT INTO Food(foodName)
    VALUES (i_foodName);

END //
DELIMITER ;

-- Query #17: mn_filter_foodTruck [Screen #11 Manager Manage Food Truck]
DROP PROCEDURE IF EXISTS mn_filter_foodTruck;
DELIMITER //
CREATE PROCEDURE mn_filter_foodTruck(
    IN i_managerUsername VARCHAR(50),
    IN i_foodTruckName VARCHAR(50),
    IN i_stationName VARCHAR(50),
    IN i_minStaffCount INT,
    IN i_maxStaffCount INT,
    IN i_hasRemainingCapacity BOOLEAN)
BEGIN

	DROP TABLE IF EXISTS mn_filter_foodTruck_result;
     CREATE TABLE mn_filter_foodTruck_result(foodTruckName varchar(100), stationName varchar(100),
		remainingCapacity int, staffCount int, menuItemCount int);
	insert into mn_filter_foodTruck_result
	select staffCounter.foodTruckName, staffCounter.stationName, remainingCapacity, staffCount, menuCount  from 
	(select foodtruck.foodTruckName, managerUsername, foodtruck.stationName, count(username) as staffCount from foodtruck left join staff on foodtruck.foodTruckName = staff.foodTruckName group by foodtruck.foodTruckName) as staffCounter left join
	(select foodtruck.foodTruckName, count(foodName) as menuCount from foodtruck left join menuitem on foodtruck.foodTruckName = menuitem.foodTruckName group by foodtruck.foodTruckName) as menuCounter on staffCounter.foodTruckName = menuCounter.foodTruckName left join
	(select capacity - count(foodTruckName) as remainingCapacity, station.stationName from foodtruck right join station on station.stationName = foodtruck.stationName group by station.stationName) as capacityCounter on staffCounter.stationName = capacityCounter.stationName
	where
		(staffCounter.foodTruckName like concat('%', i_foodTruckName, '%') OR i_foodTruckName is null OR i_foodTruckName = "") AND
		(i_stationName = staffCounter.stationName OR i_stationName = "" OR i_stationName is NULL) and
        ((i_minStaffCount IS NULL AND i_maxStaffCount IS NULL) OR (i_minStaffCount IS NULL AND staffCount <= i_maxStaffCount) OR (i_maxStaffCount IS NULL AND i_minStaffCount <= staffCount) OR (staffCount BETWEEN i_minStaffCount AND i_maxStaffCount)) and
		((i_hasRemainingCapacity is false) or (i_hasRemainingCapacity and remainingCapacity > 0) or i_hasRemainingCapacity is NULL) and
        (managerUsername = i_managerUsername);
END //
DELIMITER ;

-- Query #18: mn_delete_foodTruck [Screen #11 Manager Manage Food Truck]
DROP PROCEDURE IF EXISTS mn_delete_foodTruck;
DELIMITER //
CREATE PROCEDURE mn_delete_foodTruck(IN i_foodTruckName VARCHAR(50))
BEGIN

    DELETE FROM FoodTruck
    WHERE i_foodTruckName = foodTruckName;

END //
DELIMITER ;

-- Query #19a: mn_create_foodTruck_add_station [Screen #12 Manager Create Food Truck]
DROP PROCEDURE IF EXISTS mn_create_foodTruck_add_station;
DELIMITER //
CREATE PROCEDURE mn_create_foodTruck_add_station(IN i_foodTruckName VARCHAR(50), IN i_stationName VARCHAR(50), IN i_managerUsername VARCHAR(50))
sp_createfoodtruck:BEGIN

if ((select capacity - count(foodTruckName) as remainingCapacity from foodtruck right join station on station.stationName = foodtruck.stationName where station.stationName = i_stationName group by station.stationName) <= 0) then
	leave sp_createfoodtruck;
end if;

INSERT INTO FoodTruck(foodTruckName, stationName, managerUsername)
VALUES (i_foodTruckName, i_stationName, i_managerUsername);

END //
DELIMITER ;

-- Query #19b: mn_create_foodTruck_add_staff [Screen #12 Manager Create Food Truck]
-- i_staffName parameter is the Staff's username
DROP PROCEDURE IF EXISTS mn_create_foodTruck_add_staff;
DELIMITER //
CREATE PROCEDURE mn_create_foodTruck_add_staff(IN i_foodTruckName VARCHAR(50), IN i_staffName VARCHAR(50))
sp_createstaff:BEGIN

if ((select foodTruckName from staff where username = i_staffName) is not NULL) then
		leave sp_createstaff;
end if;

update staff
set foodTruckName = i_foodTruckName
where username = i_staffName;

END //
DELIMITER ;

-- Query #19c: mn_create_foodTruck_add_menu_item [Screen #12 Manager Create Food Truck]
DROP PROCEDURE IF EXISTS mn_create_foodTruck_add_menu_item;
DELIMITER //
CREATE PROCEDURE mn_create_foodTruck_add_menu_item(IN i_foodTruckName VARCHAR(50), IN i_price DECIMAL(6,2), IN i_foodName VARCHAR(50))
sp_addmenuitem:BEGIN

	 if (i_price <= 0) then
		leave sp_addmenuitem;
	end if;

    INSERT INTO MenuItem(price, foodTruckName, foodName)
    VALUES (i_price, i_foodTruckName, i_foodName);

END //
DELIMITER ;

-- Query #20a: mn_view_foodTruck_available_staff [Screen #13 Manager Update Food Truck]
-- Should show all staff available to be assigned (i.e. all unassigned staff)
-- Should be shown as FirstName LastName
DROP PROCEDURE IF EXISTS mn_view_foodTruck_available_staff;
DELIMITER //
CREATE PROCEDURE mn_view_foodTruck_available_staff(IN i_managerUsername VARCHAR(50), IN i_foodTruckName VARCHAR(50))
BEGIN

	DROP TABLE IF EXISTS mn_view_foodTruck_available_staff_result;
     CREATE TABLE mn_view_foodTruck_available_staff_result(availableStaff varchar(100));
     insert into mn_view_foodTruck_available_staff_result
	select CONCAT(firstName , ' ' , lastName) from
		(select * from staff) as firstCombo natural join
		(select * from `user`) as secondCombo
	where firstCombo.foodTruckName is null;

END //
DELIMITER ;

-- Query #20b: mn_view_foodTruck_staff [Screen #13 Manager Update Food Truck]
-- Should be shown as FirstName LastName
DROP PROCEDURE IF EXISTS mn_view_foodTruck_staff;
DELIMITER //
CREATE PROCEDURE mn_view_foodTruck_staff(i_foodTruckName VARCHAR(50))
BEGIN

    DROP TABLE IF EXISTS mn_view_foodTruck_staff_result;
    CREATE TABLE mn_view_foodTruck_staff_result(assignedStaff varchar(100));
    insert into mn_view_foodTruck_staff_result
    select concat(firstName, ' ', lastName) as staffName from
		(select * from foodtruck) as innerFirst inner join -- i think this is ok as an inner join because if a foodtruck doesn't have any staff then it shouldn't return anything anway (same thing as in 21)
		(select * from staff) as innerSecond on innerFirst.foodTruckName = innerSecond.foodTruckName left join
		(select * from `user`) as innerThird on innerThird.username = innerSecond.username
	where innerFirst.foodTruckName = i_foodTruckName;

END //
DELIMITER ;

-- Query #21: mn_view_foodTruck_menu [Screen #13 Manager Update Food Truck]
DROP PROCEDURE IF EXISTS mn_view_foodTruck_menu;
DELIMITER //
CREATE PROCEDURE mn_view_foodTruck_menu(i_foodTruckName VARCHAR(50))
BEGIN

	DROP TABLE IF EXISTS mn_view_foodTruck_menu_result;
     CREATE TABLE mn_view_foodTruck_menu_result(foodTruckName varchar(100), stationName varchar(100), foodName varchar(100), price DECIMAL(6,2));
     insert into mn_view_foodTruck_menu_result
     SELECT foodtruck.foodTruckName, stationName, foodName, price
     FROM foodtruck
     inner JOIN menuitem -- inner gives empty result set, left gives result set with nulls (assuming the food truck has no menu items)
     ON foodtruck.foodTruckName = menuitem.foodTruckName
     WHERE
	(foodtruck.foodTruckName = i_foodTruckName);

END //
DELIMITER ;

-- Query #22a: mn_update_foodTruck_station [Screen #13 Manager Update Food Truck]
DROP PROCEDURE IF EXISTS mn_update_foodTruck_station;
DELIMITER //
CREATE PROCEDURE mn_update_foodTruck_station(IN i_foodTruckName VARCHAR(50), IN i_stationName VARCHAR(50))
sp_updatefoodtruck:BEGIN

    if ((select capacity - count(foodTruckName) as remainingCapacity from foodtruck right join station on station.stationName = foodtruck.stationName where station.stationName = i_stationName group by station.stationName) <= 0) then
		leave sp_updatefoodtruck;
	end if;
	
    UPDATE FOODTRUCK
    SET stationName = i_stationName
    WHERE foodTruckName = i_foodTruckName;

END //
DELIMITER ;

-- Query #22b: mn_update_foodTruck_staff [Screen #13 Manager Update Food Truck]
-- i_staffName parameter is the Staff's username
DROP PROCEDURE IF EXISTS mn_update_foodTruck_staff;
DELIMITER //
CREATE PROCEDURE mn_update_foodTruck_staff(IN i_foodTruckName VARCHAR(50), IN i_staffName VARCHAR(50))
sp_updatestaff:BEGIN

    if ((select foodTruckName from staff where username = i_staffName) is not NULL) then
		leave sp_updatestaff;
	end if;

    UPDATE STAFF
    SET foodTruckName = i_foodTruckName
    WHERE username = i_staffName;

END //
DELIMITER ;

-- Query #22c: mn_update_foodTruck_menu_item [Screen #13 Manager Update Food Truck]
-- This is meant to add a MenuItem to the FoodTruck upon update.
DROP PROCEDURE IF EXISTS mn_update_foodTruck_menu_item;
DELIMITER //
CREATE PROCEDURE mn_update_foodTruck_menu_item(IN i_foodTruckName VARCHAR(50), IN i_price DECIMAL(6,2), IN i_foodName VARCHAR(50))
sp_updatemenuitem:BEGIN

    if (i_price <= 0) then
		leave sp_updatemenuitem;
	end if;
	
    INSERT INTO MENUITEM(price, foodTruckName, foodName)
    VALUES (i_price, i_foodTruckName, i_foodName);

END //
DELIMITER ;

-- Query #23: mn_get_station [Screen #14 Manager Food Truck Summary]
-- Get list of stations that have foodTrucks managed by the given manager
DROP PROCEDURE IF EXISTS mn_get_station;
DELIMITER //
CREATE PROCEDURE mn_get_station(IN i_managerUsername VARCHAR(50))
BEGIN
    DROP TABLE IF EXISTS mn_get_station_result;
    CREATE TABLE mn_get_station_result(stationName varchar(100));

    INSERT INTO mn_get_station_result
    select distinct stationName from foodtruck
    where managerUsername = i_managerUsername;

END //
DELIMITER ;

-- Query #24: mn_filter_summary [Screen #14 Manager Food Truck Summary]
DROP PROCEDURE IF EXISTS mn_filter_summary;
DELIMITER //
CREATE PROCEDURE mn_filter_summary(
    IN i_managerUsername VARCHAR(50),
    IN i_foodTruckName VARCHAR(50),
    IN i_stationName VARCHAR(50),
    IN i_minDate DATE,
    IN i_maxDate DATE,
    IN i_sortedBy ENUM('foodTruckName', 'totalOrder', 'totalRevenue', 'totalCustomer'),
    IN i_sortedDirection ENUM('ASC', 'DESC'))
BEGIN
    DROP TABLE IF EXISTS mn_filter_summary_result;
    CREATE TABLE mn_filter_summary_result(foodTruckName varchar(100), totalOrder int, totalRevenue DECIMAL(6,2), totalCustomer int);

    insert into mn_filter_summary_result
    select outerFirst.foodTruckName, orderCount, totalRevenue, customerCount from
	(select innerFirst.foodTruckName as foodTruckName, count(distinct orderID) as orderCount, sum(price * purchaseQuantity) as totalRevenue, managerUsername, stationName from
	(select foodtruck.foodTruckName, stationName, foodName, purchaseQuantity, orderID, managerUsername from foodtruck left join orderdetail on foodtruck.foodTruckName = orderdetail.foodTruckName) as innerFirst left join
	(select * from menuitem) as innerSecond on innerFirst.foodTruckName = innerSecond.foodTruckName and innerFirst.foodName = innerSecond.foodName
	group by foodTruckName) as outerFirst left join
	(select foodtruck.foodTruckName as foodTruckName, count(distinct customerUsername) as customerCount, `date` from foodtruck left join orderdetail on foodTruck.foodTruckName = orderdetail.foodTruckName right join orders on orders.orderID = orderdetail.orderID group by foodtruck.foodTruckName) as outerSecond on outerFirst.foodTruckName = outerSecond.foodTruckName
	where (managerUsername = i_managerUsername) and
		(i_foodTruckName IS NULL OR outerFirst.foodTruckName LIKE CONCAT('%', i_foodTruckName, '%') or i_foodTruckName ="") AND
		(i_stationName IS NULL OR stationName = i_stationName or i_stationName ="") AND
		(i_minDate IS NULL OR `date` >= i_minDate) AND (i_maxDate IS NULL OR `date` <= i_maxDate)
	ORDER BY
        CASE WHEN (i_sortedBy is NULL AND (i_sortedDirection = "ASC" OR i_sortedDirection is NULL)) THEN outerFirst.foodTruckName END ASC,
        CASE WHEN (i_sortedBy is NULL AND i_sortedDirection = "DESC") THEN outerFirst.foodTruckName END DESC,
        CASE WHEN i_sortedBy = "foodTruckName" AND (i_sortedDirection = "ASC" OR i_sortedDirection is NULL) THEN outerFirst.foodTruckName END ASC,
        CASE WHEN i_sortedBy = "foodTruckName" AND i_sortedDirection = "DESC" THEN outerFirst.foodTruckName END DESC,
        CASE WHEN i_sortedBy = "totalOrder" AND (i_sortedDirection = "ASC" OR i_sortedDirection is NULL) THEN orderCount END ASC,
        CASE WHEN i_sortedBy = "totalOrder" AND i_sortedDirection = "DESC" THEN orderCount END DESC,
        CASE WHEN i_sortedBy = "totalRevenue" AND (i_sortedDirection = "ASC" OR i_sortedDirection is NULL) THEN totalRevenue END ASC,
        CASE WHEN i_sortedBy = "totalRevenue" AND i_sortedDirection = "DESC" THEN totalRevenue END DESC,
        CASE WHEN i_sortedBy = "totalCustomer" AND (i_sortedDirection = "ASC" OR i_sortedDirection is NULL) THEN customerCount END ASC,
        CASE WHEN i_sortedBy = "totalCustomer" AND i_sortedDirection = "DESC" THEN customerCount END DESC;

END //
DELIMITER ;

-- Query #25: mn_summary_detail [Screen #15 Manager Summary Detail]
DROP PROCEDURE IF EXISTS mn_summary_detail;
DELIMITER //
CREATE PROCEDURE mn_summary_detail(IN i_managerUsername VARCHAR(50), IN i_foodTruckName VARCHAR(50))
BEGIN
    DROP TABLE IF EXISTS mn_summary_detail_result;
    CREATE TABLE mn_summary_detail_result(`date` date, customerName varchar(100), totalPurchase DECIMAL(6, 2),
        orderCount int, foodNames text);

    INSERT INTO mn_summary_detail_result
    select `date`, concat(firstName, ' ', lastName), sum(price * purchaseQuantity) as totalPurchase, count(distinct orderID) as numOrders, group_concat(distinct secondResult.foodName) from
	(select * from foodtruck where foodTruckName = i_foodTruckName) as firstResult natural join
	(select * from orderdetail) as secondResult natural join
	(select * from orders) as thirdResult inner join 
	(select * from menuitem) as fourthResult on secondResult.foodTruckName = fourthResult.foodTruckName and secondResult.foodName = fourthResult.foodName inner join 
	(select * from `user`) as fifthResult on fifthResult.username = customerUsername
    WHERE
        (firstResult.foodTruckName = i_foodTruckName) AND
        (managerUsername =  i_managerUsername)
	group by `date`, customerUsername
	ORDER BY `date` desc;

END //
DELIMITER ;

-- Query #26: cus_filter_explore [Screen #16 Customer Explore]
DROP PROCEDURE IF EXISTS cus_filter_explore;
DELIMITER //
CREATE PROCEDURE cus_filter_explore(IN i_buildingName VARCHAR(50), IN i_stationName VARCHAR(50), IN i_buildingTag VARCHAR(50), IN i_foodTruckName VARCHAR(50), IN i_foodName VARCHAR(50))
BEGIN
    DROP TABLE IF EXISTS cus_filter_explore_result;
    CREATE TABLE cus_filter_explore_result(stationName varchar(100), buildingName varchar(100),
        foodTruckNames text, foodNames text);

    INSERT INTO cus_filter_explore_result
    select stationName, buildingName, foodtrucks, foods from 
	(select firstResult.stationName as stationName, firstResult.buildingName as buildingName, group_concat(distinct secondResult.foodTruckName) as foodtrucks, group_concat(distinct foodName) as foods, group_concat(distinct tag) as tags from
	(select * from station) as firstResult left join 
	(select * from foodtruck) as secondResult on firstResult.stationName = secondResult.stationName left join
	(select * from menuitem) as thirdResult on secondResult.foodTruckName = thirdResult.foodTruckName left join
	(select * from buildingTag) as fourthResult on fourthResult.buildingName = firstResult.buildingName
	WHERE
        (i_buildingName is NULL OR i_buildingName = firstResult.buildingName or i_buildingName = "") AND
        (i_stationName is NULL OR i_stationName = firstResult.stationName or i_stationName="") AND
        (i_foodTruckName is NULL OR secondResult.foodTruckName LIKE CONCAT('%', i_foodTruckName, '%') or i_foodTruckName ="") and 
        (secondResult.foodTruckName in (select foodtruck.foodTruckName from foodtruck left join menuitem on foodtruck.foodTruckName = menuitem.foodTruckName where foodName like concat("%", i_foodName, "%")) or i_foodName = "" or i_foodName is NULL)
	group by firstResult.stationName
	having 
		(i_buildingTag is NULL OR tags LIKE CONCAT('%', i_buildingTag, '%') or i_buildingTag="")) as outerResult;

END //
DELIMITER ;

-- Query #27: cus_select_location [Screen #16 Customer Explore]
DROP PROCEDURE IF EXISTS cus_select_location;
DELIMITER //
CREATE PROCEDURE cus_select_location( IN i_customerUsername VARCHAR(50), IN i_stationName VARCHAR(50))
BEGIN
    IF i_stationName in (SELECT stationName FROM station)
    THEN
    UPDATE customer 
    SET stationName = i_stationName 
    WHERE username = i_customerUsername;
    END IF;

END //
DELIMITER ;

-- Query #28: cus_current_information_basic [Screen #17 Customer Current Information]
DROP PROCEDURE IF EXISTS cus_current_information_basic;
DELIMITER //
CREATE PROCEDURE cus_current_information_basic(IN i_customerUsername VARCHAR(55))
BEGIN
    DROP TABLE IF EXISTS cus_current_information_basic_result;
    CREATE TABLE cus_current_information_basic_result(stationName varchar(100), buildingName varchar(100), tags text, `description` text,
		balance DECIMAL(6, 2));

    insert into cus_current_information_basic_result
    select customer.stationName, station.buildingName, group_concat(Distinct tag), `description`, balance from 
	customer left join 
	station on (customer.stationName = station.stationName) left join 
	building on (building.buildingName = station.buildingName) left join 
	buildingtag on (building.buildingName = buildingtag.buildingName)
	group by username
	having username = i_customerUsername;

END //
DELIMITER ;

-- Query #29: cus_current_information_foodTruck [Screen #17 Customer Current Information]
DROP PROCEDURE IF EXISTS cus_current_information_foodTruck;
DELIMITER //
CREATE PROCEDURE cus_current_information_foodTruck(IN i_customerUsername VARCHAR(55))
BEGIN
    DROP TABLE IF EXISTS cus_current_information_foodTruck_result;
    CREATE TABLE cus_current_information_foodTruck_result(foodTruckName varchar(100), managerName varchar(100), foodNames text);

    insert into cus_current_information_foodtruck_result
    select foodtruck.foodtruckName, concat(firstName, " ", lastName), group_concat(foodName) from 
	customer inner join 
	foodtruck on customer.stationName = foodtruck.stationName left join
	menuitem on menuitem.foodTruckName = foodtruck.foodTruckName left join 
    `user` on managerUsername = `user`.username
    where customer.username = i_customerUsername
	group by foodtruck.foodTruckName;

END //
DELIMITER ;

-- Query #30: cus_order [Screen #18 Customer Order]
DROP PROCEDURE IF EXISTS cus_order;
DELIMITER //
CREATE PROCEDURE cus_order(IN i_date DATE, i_customerUsername VARCHAR(55))
BEGIN
	
	-- shouldn't need to check if i_customerUsername is actually a customer because we have an fk orders(username) to customer(username)

    insert into orders (`date`, customerUsername)
    values (i_date, i_customerUsername);
    
    SELECT LAST_INSERT_ID() as val;

END //
DELIMITER ;

-- Query #31: cus_add_item_to_order [Screen #18 Customer Order]
-- Adds a quantity of food to an order if and only if a customer's balance can
-- afford the food price x quantity. If successful, make sure to deduct
-- from their balance too.
DROP PROCEDURE IF EXISTS cus_add_item_to_order;
DELIMITER //
CREATE PROCEDURE cus_add_item_to_order(IN i_foodTruckName VARCHAR(55), IN i_foodName VARCHAR(55), IN i_purchaseQuantity INT, IN i_orderId INT)
sp_orderdetail:BEGIN

    if (i_purchaseQuantity <= 0) then
		leave sp_orderdetail;
	end if;
    
    -- check if foodtruck in customer station
	if (i_foodTruckName not in (select foodTruckName from orders inner join customer on orders.customerUsername = customer.username left join foodtruck on foodtruck.stationName = customer.stationName where orderID = i_orderID)) then
		leave sp_orderdetail;
	end if;
    
    -- place your code/solution here
    if ((select balance from customer inner join orders on orders.customerUsername = customer.username where orderID = i_orderId) >= i_purchaseQuantity * (select price from menuitem where foodTruckName=i_foodTruckName and foodName=i_foodName)) then
		insert into orderdetail
		values (i_orderId, i_foodTruckName, i_foodName, i_purchaseQuantity);
        update customer
        set balance = balance - (i_purchaseQuantity * (select price from menuitem where foodTruckName=i_foodTruckName and foodName=i_foodName))
        where username = (select username from (select * from customer) as customerCopy inner join orders on orders.customerUsername = customerCopy.username where orderID = i_orderId);
	end if;

END //
DELIMITER ;

-- Query #32: cus_order_history [Screen #19 Customer Order History]
DROP PROCEDURE IF EXISTS cus_order_history;
DELIMITER //
CREATE PROCEDURE cus_order_history(IN i_customerUsername VARCHAR(55))
BEGIN
	DROP TABLE IF EXISTS cus_order_history_result;
    CREATE TABLE cus_order_history_result(`date` date, orderID char(10), orderTotal DECIMAL(6, 2),
		foodNames varchar(100), foodQuantity int);

    insert cus_order_history_result
    select `date`, orders.orderID, sum(price * purchaseQuantity), group_concat(distinct orderdetail.foodName), sum(purchaseQuantity) from 
	customer inner join orders on username = customerUsername left join -- i think the inner join is good here because if customer has no order matches then the results should be blank anyway 
	orderdetail on orders.orderID = orderdetail.orderID left join
	menuitem on (menuitem.foodTruckName = orderdetail.foodTruckName and menuitem.foodName = orderdetail.foodName)
	where username= i_customerUsername
	group by orderID;

END //
DELIMITER ;



DROP PROCEDURE IF EXISTS mn_view_foodTruck_available_staff_username;
DELIMITER //
CREATE PROCEDURE mn_view_foodTruck_available_staff_username(IN i_managerUsername VARCHAR(50), IN i_foodTruckName VARCHAR(50))
BEGIN

	DROP TABLE IF EXISTS mn_view_foodTruck_available_staff_username_result;
	CREATE TABLE mn_view_foodTruck_available_staff_username_result(availableStaff varchar(100), username varchar(100));
    insert into mn_view_foodTruck_available_staff_username_result
	select CONCAT(firstName , ' ' , lastName), username from
		(select * from staff) as firstCombo natural join
		(select * from `user`) as secondCombo
	where isnull(firstCombo.foodTruckName);

END //
DELIMITER ;
