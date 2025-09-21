-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 21, 2025 at 07:53 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `e-commerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateNewOrder` (IN `p_user_id` INT, IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
    DECLARE product_price DECIMAL(10,2);

    SELECT price INTO product_price
    FROM Products
    WHERE product_id = p_product_id;

    INSERT INTO Orders (user_id, status)
    VALUES (p_user_id, 'Pending');

    INSERT INTO OrderItems (order_id, product_id, quantity, price)
    VALUES (LAST_INSERT_ID(), p_product_id, p_quantity, product_price);

    UPDATE Products
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `name`, `description`) VALUES
(1, 'Electronics', 'Devices like phones, laptops, and accessories'),
(2, 'Clothing', 'Men and women clothing'),
(3, 'Books', 'Educational and entertainment books');

-- --------------------------------------------------------

--
-- Stand-in structure for view `orderdetailsview`
-- (See below for the actual view)
--
CREATE TABLE `orderdetailsview` (
`order_id` int(11)
,`user_name` varchar(100)
,`products` mediumtext
,`total_price` decimal(42,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `orderitems`
--

CREATE TABLE `orderitems` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderitems`
--

INSERT INTO `orderitems` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`) VALUES
(1, 1, 1, 1, 1200.00),
(2, 1, 4, 2, 20.00),
(3, 1, 7, 1, 25.00),
(4, 2, 2, 1, 900.00),
(5, 2, 5, 1, 40.00),
(6, 2, 8, 1, 35.00),
(7, 3, 3, 2, 150.00),
(8, 3, 6, 1, 60.00);

--
-- Triggers `orderitems`
--
DELIMITER $$
CREATE TRIGGER `check_stock_before_insert` BEFORE INSERT ON `orderitems` FOR EACH ROW BEGIN
    DECLARE available_stock INT;

    SELECT stock INTO available_stock
    FROM Products
    WHERE product_id = NEW.product_id;

    IF NEW.quantity > available_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available for this product';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('Pending','Shipped','Delivered') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `order_date`, `status`) VALUES
(1, 1, '2025-09-21 16:15:56', 'Shipped'),
(2, 2, '2025-09-21 16:15:56', 'Shipped'),
(3, 3, '2025-09-21 16:15:56', 'Delivered');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `category_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `description`, `price`, `stock`, `category_id`, `created_at`) VALUES
(1, 'iPhone 17', 'Apple smartphone', 1200.00, 8, 1, '2025-09-21 16:14:08'),
(2, 'Dell Laptop', 'Core i7 laptop', 900.00, 8, 1, '2025-09-21 16:14:08'),
(3, 'Wireless Headphones', 'Bluetooth headphones', 150.00, 20, 1, '2025-09-21 16:14:08'),
(4, 'Men T-Shirt', 'Cotton T-shirt', 20.00, 50, 2, '2025-09-21 16:14:08'),
(5, 'Jeans Pants', 'Blue denim jeans', 40.00, 30, 2, '2025-09-21 16:14:08'),
(6, 'Jacket', 'Winter jacket', 60.00, 15, 2, '2025-09-21 16:14:08'),
(7, 'Python Programming', 'Learn Python basics', 25.00, 40, 3, '2025-09-21 16:14:08'),
(8, 'Data Science Guide', 'Book about Data Science', 35.00, 25, 3, '2025-09-21 16:14:08'),
(10, 'Database Systems', 'Book about SQL and DBMS', 45.00, 18, 3, '2025-09-21 16:14:08');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password`, `created_at`) VALUES
(1, 'rabie Ahmad', 'rabie@example.com', 'pass123', '2025-09-21 16:10:03'),
(2, 'Sara Khaled', 'sara@example.com', 'pass456', '2025-09-21 16:10:03'),
(3, 'Omar Youssef', 'omar@example.com', 'pass789', '2025-09-21 16:10:03'),
(4, 'noor Hassan', 'noor@example.com', 'pass321', '2025-09-21 16:10:03'),
(5, 'Mohammad Adel', 'mohammad@example.com', 'pass654', '2025-09-21 16:10:03');

-- --------------------------------------------------------

--
-- Structure for view `orderdetailsview`
--
DROP TABLE IF EXISTS `orderdetailsview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `orderdetailsview`  AS SELECT `o`.`order_id` AS `order_id`, `u`.`name` AS `user_name`, group_concat(`p`.`name` separator ', ') AS `products`, sum(`oi`.`quantity` * `oi`.`price`) AS `total_price` FROM (((`orders` `o` join `users` `u` on(`o`.`user_id` = `u`.`user_id`)) join `orderitems` `oi` on(`o`.`order_id` = `oi`.`order_id`)) join `products` `p` on(`oi`.`product_id` = `p`.`product_id`)) GROUP BY `o`.`order_id`, `u`.`name` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `orderitems_ibfk_2` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
