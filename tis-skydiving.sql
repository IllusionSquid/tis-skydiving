CREATE TABLE IF NOT EXISTS `skydive_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(50) NOT NULL,
  `veh_pos` text NOT NULL,
  `veh_heading` float NOT NULL,
  `land_pos` text NOT NULL,
  `flares` longtext NOT NULL,
  `radius` float NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;