-- Users 테이블 생성
CREATE TABLE Users (
    userId VARCHAR(36) PRIMARY KEY,
    userEmail VARCHAR(255) NOT NULL,
    userPassword VARCHAR(255) NOT NULL,
    userName VARCHAR(100) NOT NULL,
    userGender ENUM('Male', 'Female') NOT NULL,
    userAge INT NOT NULL,
    userImgURL VARCHAR(255),
    userMoney INT NOT NULL,
    userSpend INT NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Locations 테이블 생성
CREATE TABLE Locations (
    locationId VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    locationTitle VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(10, 8) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- Ips 테이블 생성
CREATE TABLE Ips (
    currentIp VARCHAR(36) PRIMARY KEY,
    modifiedIp VARCHAR(36) NULL,
    userId VARCHAR(36) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- Instas 테이블 생성
CREATE TABLE Instas (
    instaId VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    instaContents VARCHAR(1000),
    instaImgURL VARCHAR(255) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- Tweets 테이블 생성
CREATE TABLE Tweets (
    tweetId VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    tweetContents VARCHAR(1000) NOT NULL,
    tweetImgURL VARCHAR(255),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- Items 테이블 생성
CREATE TABLE Items (
    itemId VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    itemTitle VARCHAR(255) NOT NULL,
    itemContents VARCHAR(1000) NOT NULL,
    itemPrice INT NOT NULL,
    itemImgURL VARCHAR(255) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- Purchases 테이블 생성
CREATE TABLE Purchases (
    purchaseId VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    itemId VARCHAR(36) NOT NULL,
    purchaseStatus ENUM('Purchased', 'Refunded') NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId),
    FOREIGN KEY (itemId) REFERENCES Items(itemId)
);