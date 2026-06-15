-- Tables are also auto-created on first start, so importing this manually is optional.

CREATE TABLE IF NOT EXISTS `characters` (
    `state_id` INT UNSIGNED NOT NULL,
    `license` VARCHAR(60) NOT NULL,
    `display_name` VARCHAR(60) DEFAULT NULL,
    `identity` LONGTEXT DEFAULT NULL,
    `accounts` LONGTEXT DEFAULT NULL,
    `occupation` LONGTEXT DEFAULT NULL,
    `affiliation` LONGTEXT DEFAULT NULL,
    `metadata` LONGTEXT DEFAULT NULL,
    `last_position` LONGTEXT DEFAULT NULL,
    PRIMARY KEY (`state_id`),
    UNIQUE KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `core_sequences` (
    `id` VARCHAR(50) NOT NULL,
    `value` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
