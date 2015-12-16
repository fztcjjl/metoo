-- --------------------------------------------------------
-- 主机:                           192.168.159.188
-- 服务器版本:                        5.5.43-0ubuntu0.14.04.1 - (Ubuntu)
-- 服务器操作系统:                      debian-linux-gnu
-- HeidiSQL 版本:                  8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 导出  表 metoo.d_account 结构
CREATE TABLE IF NOT EXISTS `d_account` (
  `id` int(11) unsigned NOT NULL COMMENT '系统编号，对应d_user表的uid',
  `pid` varchar(50) NOT NULL COMMENT '平台下发的id',
  `sdkid` int(11) unsigned NOT NULL COMMENT 'sdkid',
  PRIMARY KEY (`id`),
  UNIQUE KEY `pid_sdkid` (`pid`,`sdkid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帐号表';

-- 正在导出表  metoo.d_account 的数据：~12 rows (大约)
DELETE FROM `d_account`;
/*!40000 ALTER TABLE `d_account` DISABLE KEYS */;
INSERT INTO `d_account` (`id`, `pid`, `sdkid`) VALUES
	(1, '188', 1),
	(2, '189', 1),
	(3, '190', 1),
	(4, '191', 1),
	(5, '192', 1),
	(6, '193', 1),
	(7, '194', 1),
	(8, '195', 1),
	(9, '196', 1),
	(10, '197', 1),
	(11, '198', 1),
	(12, '199', 1);
/*!40000 ALTER TABLE `d_account` ENABLE KEYS */;


-- 导出  表 metoo.d_building 结构
CREATE TABLE IF NOT EXISTS `d_building` (
  `id` int(11) unsigned NOT NULL COMMENT '系统编号',
  `uid` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `type` tinyint(3) unsigned NOT NULL COMMENT '建筑类型',
  `level` tinyint(3) unsigned NOT NULL COMMENT '建筑等级',
  `storage` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '当前库存量',
  `end_increase_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '提速结束时间',
  `output_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '产出时间',
  `state_end_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '状态结束时间',
  `state` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '状态(0:空闲 1:建造 2:升级 3:拆除)',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 正在导出表  metoo.d_building 的数据：~216 rows (大约)
DELETE FROM `d_building`;
/*!40000 ALTER TABLE `d_building` DISABLE KEYS */;
INSERT INTO `d_building` (`id`, `uid`, `type`, `level`, `storage`, `end_increase_time`, `output_time`, `state_end_time`, `state`) VALUES
	(1, 1, 1, 1, 0, 0, 0, 0, 0),
	(2, 1, 2, 1, 0, 0, 0, 0, 0),
	(3, 1, 3, 1, 0, 0, 0, 0, 0),
	(4, 1, 4, 1, 0, 0, 0, 0, 0),
	(5, 1, 5, 1, 0, 0, 0, 0, 0),
	(6, 1, 6, 1, 0, 0, 0, 0, 0),
	(7, 1, 7, 1, 0, 0, 0, 0, 0),
	(8, 1, 8, 1, 0, 0, 0, 0, 0),
	(9, 1, 12, 1, 0, 0, 0, 0, 0),
	(10, 1, 13, 1, 0, 0, 0, 0, 0),
	(11, 1, 28, 1, 0, 0, 0, 0, 0),
	(12, 1, 29, 1, 0, 0, 0, 0, 0),
	(13, 1, 30, 1, 0, 0, 0, 0, 0),
	(14, 1, 31, 1, 0, 0, 0, 0, 0),
	(15, 1, 54, 1, 0, 0, 0, 0, 0),
	(16, 1, 55, 1, 0, 0, 0, 0, 0),
	(17, 1, 56, 1, 0, 0, 0, 0, 0),
	(18, 1, 62, 1, 0, 0, 0, 0, 0),
	(19, 2, 1, 1, 0, 0, 0, 0, 0),
	(20, 2, 2, 1, 0, 0, 0, 0, 0),
	(21, 2, 3, 1, 0, 0, 0, 0, 0),
	(22, 2, 4, 1, 0, 0, 0, 0, 0),
	(23, 2, 5, 1, 0, 0, 0, 0, 0),
	(24, 2, 6, 1, 0, 0, 0, 0, 0),
	(25, 2, 7, 1, 0, 0, 0, 0, 0),
	(26, 2, 8, 1, 0, 0, 0, 0, 0),
	(27, 2, 12, 1, 0, 0, 0, 0, 0),
	(28, 2, 13, 1, 0, 0, 0, 0, 0),
	(29, 2, 28, 1, 0, 0, 0, 0, 0),
	(30, 2, 29, 1, 0, 0, 0, 0, 0),
	(31, 2, 30, 1, 0, 0, 0, 0, 0),
	(32, 2, 31, 1, 0, 0, 0, 0, 0),
	(33, 2, 54, 1, 0, 0, 0, 0, 0),
	(34, 2, 55, 1, 0, 0, 0, 0, 0),
	(35, 2, 56, 1, 0, 0, 0, 0, 0),
	(36, 2, 62, 1, 0, 0, 0, 0, 0),
	(37, 3, 1, 1, 0, 0, 0, 0, 0),
	(38, 3, 2, 1, 0, 0, 0, 0, 0),
	(39, 3, 3, 1, 0, 0, 0, 0, 0),
	(40, 3, 4, 1, 0, 0, 0, 0, 0),
	(41, 3, 5, 1, 0, 0, 0, 0, 0),
	(42, 3, 6, 1, 0, 0, 0, 0, 0),
	(43, 3, 7, 1, 0, 0, 0, 0, 0),
	(44, 3, 8, 1, 0, 0, 0, 0, 0),
	(45, 3, 12, 1, 0, 0, 0, 0, 0),
	(46, 3, 13, 1, 0, 0, 0, 0, 0),
	(47, 3, 28, 1, 0, 0, 0, 0, 0),
	(48, 3, 29, 1, 0, 0, 0, 0, 0),
	(49, 3, 30, 1, 0, 0, 0, 0, 0),
	(50, 3, 31, 1, 0, 0, 0, 0, 0),
	(51, 3, 54, 1, 0, 0, 0, 0, 0),
	(52, 3, 55, 1, 0, 0, 0, 0, 0),
	(53, 3, 56, 1, 0, 0, 0, 0, 0),
	(54, 3, 62, 1, 0, 0, 0, 0, 0),
	(55, 4, 1, 1, 0, 0, 0, 0, 0),
	(56, 4, 2, 1, 0, 0, 0, 0, 0),
	(57, 4, 3, 1, 0, 0, 0, 0, 0),
	(58, 4, 4, 1, 0, 0, 0, 0, 0),
	(59, 4, 5, 1, 0, 0, 0, 0, 0),
	(60, 4, 6, 1, 0, 0, 0, 0, 0),
	(61, 4, 7, 1, 0, 0, 0, 0, 0),
	(62, 4, 8, 1, 0, 0, 0, 0, 0),
	(63, 4, 12, 1, 0, 0, 0, 0, 0),
	(64, 4, 13, 1, 0, 0, 0, 0, 0),
	(65, 4, 28, 1, 0, 0, 0, 0, 0),
	(66, 4, 29, 1, 0, 0, 0, 0, 0),
	(67, 4, 30, 1, 0, 0, 0, 0, 0),
	(68, 4, 31, 1, 0, 0, 0, 0, 0),
	(69, 4, 54, 1, 0, 0, 0, 0, 0),
	(70, 4, 55, 1, 0, 0, 0, 0, 0),
	(71, 4, 56, 1, 0, 0, 0, 0, 0),
	(72, 4, 62, 1, 0, 0, 0, 0, 0),
	(73, 5, 1, 1, 0, 0, 0, 0, 0),
	(74, 5, 2, 1, 0, 0, 0, 0, 0),
	(75, 5, 3, 1, 0, 0, 0, 0, 0),
	(76, 5, 4, 1, 0, 0, 0, 0, 0),
	(77, 5, 5, 1, 0, 0, 0, 0, 0),
	(78, 5, 6, 1, 0, 0, 0, 0, 0),
	(79, 5, 7, 1, 0, 0, 0, 0, 0),
	(80, 5, 8, 1, 0, 0, 0, 0, 0),
	(81, 5, 12, 1, 0, 0, 0, 0, 0),
	(82, 5, 13, 1, 0, 0, 0, 0, 0),
	(83, 5, 28, 1, 0, 0, 0, 0, 0),
	(84, 5, 29, 1, 0, 0, 0, 0, 0),
	(85, 5, 30, 1, 0, 0, 0, 0, 0),
	(86, 5, 31, 1, 0, 0, 0, 0, 0),
	(87, 5, 54, 1, 0, 0, 0, 0, 0),
	(88, 5, 55, 1, 0, 0, 0, 0, 0),
	(89, 5, 56, 1, 0, 0, 0, 0, 0),
	(90, 5, 62, 1, 0, 0, 0, 0, 0),
	(91, 6, 1, 1, 0, 0, 0, 0, 0),
	(92, 6, 2, 1, 0, 0, 0, 0, 0),
	(93, 6, 3, 1, 0, 0, 0, 0, 0),
	(94, 6, 4, 1, 0, 0, 0, 0, 0),
	(95, 6, 5, 1, 0, 0, 0, 0, 0),
	(96, 6, 6, 1, 0, 0, 0, 0, 0),
	(97, 6, 7, 1, 0, 0, 0, 0, 0),
	(98, 6, 8, 1, 0, 0, 0, 0, 0),
	(99, 6, 12, 1, 0, 0, 0, 0, 0),
	(100, 6, 13, 1, 0, 0, 0, 0, 0),
	(101, 6, 28, 1, 0, 0, 0, 0, 0),
	(102, 6, 29, 1, 0, 0, 0, 0, 0),
	(103, 6, 30, 1, 0, 0, 0, 0, 0),
	(104, 6, 31, 1, 0, 0, 0, 0, 0),
	(105, 6, 54, 1, 0, 0, 0, 0, 0),
	(106, 6, 55, 1, 0, 0, 0, 0, 0),
	(107, 6, 56, 1, 0, 0, 0, 0, 0),
	(108, 6, 62, 1, 0, 0, 0, 0, 0),
	(109, 7, 1, 1, 0, 0, 0, 0, 0),
	(110, 7, 2, 1, 0, 0, 0, 0, 0),
	(111, 7, 3, 1, 0, 0, 0, 0, 0),
	(112, 7, 4, 1, 0, 0, 0, 0, 0),
	(113, 7, 5, 1, 0, 0, 0, 0, 0),
	(114, 7, 6, 1, 0, 0, 0, 0, 0),
	(115, 7, 7, 1, 0, 0, 0, 0, 0),
	(116, 7, 8, 1, 0, 0, 0, 0, 0),
	(117, 7, 12, 1, 0, 0, 0, 0, 0),
	(118, 7, 13, 1, 0, 0, 0, 0, 0),
	(119, 7, 28, 1, 0, 0, 0, 0, 0),
	(120, 7, 29, 1, 0, 0, 0, 0, 0),
	(121, 7, 30, 1, 0, 0, 0, 0, 0),
	(122, 7, 31, 1, 0, 0, 0, 0, 0),
	(123, 7, 54, 1, 0, 0, 0, 0, 0),
	(124, 7, 55, 1, 0, 0, 0, 0, 0),
	(125, 7, 56, 1, 0, 0, 0, 0, 0),
	(126, 7, 62, 1, 0, 0, 0, 0, 0),
	(127, 8, 1, 1, 0, 0, 0, 0, 0),
	(128, 8, 2, 1, 0, 0, 0, 0, 0),
	(129, 8, 3, 1, 0, 0, 0, 0, 0),
	(130, 8, 4, 1, 0, 0, 0, 0, 0),
	(131, 8, 5, 1, 0, 0, 0, 0, 0),
	(132, 8, 6, 1, 0, 0, 0, 0, 0),
	(133, 8, 7, 1, 0, 0, 0, 0, 0),
	(134, 8, 8, 1, 0, 0, 0, 0, 0),
	(135, 8, 12, 1, 0, 0, 0, 0, 0),
	(136, 8, 13, 1, 0, 0, 0, 0, 0),
	(137, 8, 28, 1, 0, 0, 0, 0, 0),
	(138, 8, 29, 1, 0, 0, 0, 0, 0),
	(139, 8, 30, 1, 0, 0, 0, 0, 0),
	(140, 8, 31, 1, 0, 0, 0, 0, 0),
	(141, 8, 54, 1, 0, 0, 0, 0, 0),
	(142, 8, 55, 1, 0, 0, 0, 0, 0),
	(143, 8, 56, 1, 0, 0, 0, 0, 0),
	(144, 8, 62, 1, 0, 0, 0, 0, 0),
	(145, 9, 1, 1, 0, 0, 0, 0, 0),
	(146, 9, 2, 1, 0, 0, 0, 0, 0),
	(147, 9, 3, 1, 0, 0, 0, 0, 0),
	(148, 9, 4, 1, 0, 0, 0, 0, 0),
	(149, 9, 5, 1, 0, 0, 0, 0, 0),
	(150, 9, 6, 1, 0, 0, 0, 0, 0),
	(151, 9, 7, 1, 0, 0, 0, 0, 0),
	(152, 9, 8, 1, 0, 0, 0, 0, 0),
	(153, 9, 12, 1, 0, 0, 0, 0, 0),
	(154, 9, 13, 1, 0, 0, 0, 0, 0),
	(155, 9, 28, 1, 0, 0, 0, 0, 0),
	(156, 9, 29, 1, 0, 0, 0, 0, 0),
	(157, 9, 30, 1, 0, 0, 0, 0, 0),
	(158, 9, 31, 1, 0, 0, 0, 0, 0),
	(159, 9, 54, 1, 0, 0, 0, 0, 0),
	(160, 9, 55, 1, 0, 0, 0, 0, 0),
	(161, 9, 56, 1, 0, 0, 0, 0, 0),
	(162, 9, 62, 1, 0, 0, 0, 0, 0),
	(163, 10, 1, 1, 0, 0, 0, 0, 0),
	(164, 10, 2, 1, 0, 0, 0, 0, 0),
	(165, 10, 3, 1, 0, 0, 0, 0, 0),
	(166, 10, 4, 1, 0, 0, 0, 0, 0),
	(167, 10, 5, 1, 0, 0, 0, 0, 0),
	(168, 10, 6, 1, 0, 0, 0, 0, 0),
	(169, 10, 7, 1, 0, 0, 0, 0, 0),
	(170, 10, 8, 1, 0, 0, 0, 0, 0),
	(171, 10, 12, 1, 0, 0, 0, 0, 0),
	(172, 10, 13, 1, 0, 0, 0, 0, 0),
	(173, 10, 28, 1, 0, 0, 0, 0, 0),
	(174, 10, 29, 1, 0, 0, 0, 0, 0),
	(175, 10, 30, 1, 0, 0, 0, 0, 0),
	(176, 10, 31, 1, 0, 0, 0, 0, 0),
	(177, 10, 54, 1, 0, 0, 0, 0, 0),
	(178, 10, 55, 1, 0, 0, 0, 0, 0),
	(179, 10, 56, 1, 0, 0, 0, 0, 0),
	(180, 10, 62, 1, 0, 0, 0, 0, 0),
	(181, 11, 1, 1, 0, 0, 0, 0, 0),
	(182, 11, 2, 1, 0, 0, 0, 0, 0),
	(183, 11, 3, 1, 0, 0, 0, 0, 0),
	(184, 11, 4, 1, 0, 0, 0, 0, 0),
	(185, 11, 5, 1, 0, 0, 0, 0, 0),
	(186, 11, 6, 1, 0, 0, 0, 0, 0),
	(187, 11, 7, 1, 0, 0, 0, 0, 0),
	(188, 11, 8, 1, 0, 0, 0, 0, 0),
	(189, 11, 12, 1, 0, 0, 0, 0, 0),
	(190, 11, 13, 1, 0, 0, 0, 0, 0),
	(191, 11, 28, 1, 0, 0, 0, 0, 0),
	(192, 11, 29, 1, 0, 0, 0, 0, 0),
	(193, 11, 30, 1, 0, 0, 0, 0, 0),
	(194, 11, 31, 1, 0, 0, 0, 0, 0),
	(195, 11, 54, 1, 0, 0, 0, 0, 0),
	(196, 11, 55, 1, 0, 0, 0, 0, 0),
	(197, 11, 56, 1, 0, 0, 0, 0, 0),
	(198, 11, 62, 1, 0, 0, 0, 0, 0),
	(199, 12, 1, 1, 0, 0, 0, 0, 0),
	(200, 12, 2, 1, 0, 0, 0, 0, 0),
	(201, 12, 3, 1, 0, 0, 0, 0, 0),
	(202, 12, 4, 1, 0, 0, 0, 0, 0),
	(203, 12, 5, 1, 0, 0, 0, 0, 0),
	(204, 12, 6, 1, 0, 0, 0, 0, 0),
	(205, 12, 7, 1, 0, 0, 0, 0, 0),
	(206, 12, 8, 1, 0, 0, 0, 0, 0),
	(207, 12, 12, 1, 0, 0, 0, 0, 0),
	(208, 12, 13, 1, 0, 0, 0, 0, 0),
	(209, 12, 28, 1, 0, 0, 0, 0, 0),
	(210, 12, 29, 1, 0, 0, 0, 0, 0),
	(211, 12, 30, 1, 0, 0, 0, 0, 0),
	(212, 12, 31, 1, 0, 0, 0, 0, 0),
	(213, 12, 54, 1, 0, 0, 0, 0, 0),
	(214, 12, 55, 1, 0, 0, 0, 0, 0),
	(215, 12, 56, 1, 0, 0, 0, 0, 0),
	(216, 12, 62, 1, 0, 0, 0, 0, 0);
/*!40000 ALTER TABLE `d_building` ENABLE KEYS */;


-- 导出  表 metoo.d_item 结构
CREATE TABLE IF NOT EXISTS `d_item` (
  `id` int(11) unsigned NOT NULL COMMENT '系统编号',
  `uid` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `itemid` int(11) unsigned NOT NULL COMMENT '物品ID，对应s_itemtype表的id',
  `superposition` int(11) unsigned NOT NULL COMMENT '物品叠加数',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品表';

-- 正在导出表  metoo.d_item 的数据：~0 rows (大约)
DELETE FROM `d_item`;
/*!40000 ALTER TABLE `d_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `d_item` ENABLE KEYS */;


-- 导出  表 metoo.d_ranking 结构
CREATE TABLE IF NOT EXISTS `d_ranking` (
  `uid` int(10) unsigned NOT NULL COMMENT '玩家ID',
  `attack_win` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '攻击胜利次数',
  `defend_win` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '防守胜利次数',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='排行榜';

-- 正在导出表  metoo.d_ranking 的数据：~0 rows (大约)
DELETE FROM `d_ranking`;
/*!40000 ALTER TABLE `d_ranking` DISABLE KEYS */;
/*!40000 ALTER TABLE `d_ranking` ENABLE KEYS */;


-- 导出  表 metoo.d_user 结构
CREATE TABLE IF NOT EXISTS `d_user` (
  `uid` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `name` varchar(50) NOT NULL COMMENT '角色名称',
  `level` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `exp` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '经验',
  `rtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '注册时间',
  `ltime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后一次登出时间',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家角色表';

-- 正在导出表  metoo.d_user 的数据：~12 rows (大约)
DELETE FROM `d_user`;
/*!40000 ALTER TABLE `d_user` DISABLE KEYS */;
INSERT INTO `d_user` (`uid`, `name`, `level`, `exp`, `rtime`, `ltime`) VALUES
	(1, '1', 1, 0, 1450150355, 1450150355),
	(2, '2', 1, 0, 1450163069, 1450163069),
	(3, '3', 1, 0, 1450163127, 1450163127),
	(4, '4', 1, 0, 1450163325, 1450163325),
	(5, '5', 1, 0, 1450163397, 1450163397),
	(6, '6', 1, 0, 1450163540, 1450163540),
	(7, '7', 1, 0, 1450164698, 1450164698),
	(8, '8', 1, 0, 1450164804, 1450164804),
	(9, '9', 1, 0, 1450164961, 1450164961),
	(10, '10', 1, 0, 1450165258, 1450165258),
	(11, '11', 1, 0, 1450165267, 1450165267),
	(12, '12', 1, 0, 1450165369, 1450165369);
/*!40000 ALTER TABLE `d_user` ENABLE KEYS */;


-- 导出  表 metoo.s_config 结构
CREATE TABLE IF NOT EXISTS `s_config` (
  `id` int(11) unsigned NOT NULL,
  `data1` int(11) unsigned NOT NULL DEFAULT '0',
  `data2` int(11) unsigned NOT NULL DEFAULT '0',
  `data3` int(11) unsigned NOT NULL DEFAULT '0',
  `data4` int(11) unsigned NOT NULL DEFAULT '0',
  `data5` int(11) unsigned NOT NULL DEFAULT '0',
  `str1` text NOT NULL,
  `str2` text NOT NULL,
  `str3` text NOT NULL,
  `str4` text NOT NULL,
  `str5` text NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='配置表';

-- 正在导出表  metoo.s_config 的数据：~3 rows (大约)
DELETE FROM `s_config`;
/*!40000 ALTER TABLE `s_config` DISABLE KEYS */;
INSERT INTO `s_config` (`id`, `data1`, `data2`, `data3`, `data4`, `data5`, `str1`, `str2`, `str3`, `str4`, `str5`, `description`) VALUES
	(1, 10, 0, 0, 0, 0, '', '', '', '', '', ''),
	(2, 20, 30, 0, 0, 0, '', '', '', '', '', ''),
	(3, 0, 0, 0, 0, 0, '10,20,30', '', '', '', '', '');
/*!40000 ALTER TABLE `s_config` ENABLE KEYS */;


-- 导出  表 metoo.s_c_building 结构
CREATE TABLE IF NOT EXISTS `s_c_building` (
  `id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `csb_path` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 正在导出表  metoo.s_c_building 的数据：~30 rows (大约)
DELETE FROM `s_c_building`;
/*!40000 ALTER TABLE `s_c_building` DISABLE KEYS */;
INSERT INTO `s_c_building` (`id`, `type`, `level`, `csb_path`) VALUES
	(1001, 1, 1, 'building/csb/b_01_lv10.csb'),
	(2001, 2, 1, 'building/csb/b_r_01_1.csb'),
	(3001, 3, 1, 'building/csb/b_03_lv10.csb'),
	(4001, 4, 1, 'building/csb/b_04_lv10.csb'),
	(5001, 5, 1, 'building/csb/b_05_lv1.csb'),
	(6001, 6, 1, 'building/csb/b_06_lv10.csb'),
	(7001, 7, 1, 'building/csb/b_07_lv10.csb'),
	(8001, 8, 1, 'building/csb/b_29_lv10.csb'),
	(9001, 9, 1, 'building/csb/b_05_lv10.csb'),
	(10001, 10, 1, 'building/csb/b_r_01_1.csb'),
	(11001, 11, 1, 'building/csb/b_r_01_1.csb'),
	(12001, 12, 1, ''),
	(13001, 13, 1, ''),
	(21001, 21, 1, 'building/csb/b_21_lv10.csb'),
	(22001, 22, 1, 'building/csb/b_22_lv1.csb'),
	(23001, 23, 1, 'building/csb/b_23_lv10.csb'),
	(24001, 24, 1, 'building/csb/b_24_lv1.csb'),
	(25001, 25, 1, 'building/csb/b_25_lv10.csb'),
	(26001, 26, 1, 'building/csb/b_26_lv1.csb'),
	(27001, 27, 1, 'building/csb/b_27_lv1.csb'),
	(28001, 28, 1, 'building/csb/b_28_lv10.csb'),
	(29001, 29, 1, 'building/csb/b_29_lv1.csb'),
	(30001, 30, 1, 'building/csb/b_30_lv10.csb'),
	(31001, 31, 1, 'building/csb/b_22_lv1.csb'),
	(32001, 32, 1, 'building/csb/b_51_lv1.csb'),
	(52001, 52, 1, 'building/csb/b_52_lv1.csb'),
	(53001, 53, 1, 'building/csb/b_53_lv1.csb'),
	(54001, 54, 1, 'building/csb/b_54_lv1.csb'),
	(55001, 55, 1, 'building/csb/b_55_lv1.csb'),
	(56001, 56, 1, 'building/csb/b_56_lv10.csb');
/*!40000 ALTER TABLE `s_c_building` ENABLE KEYS */;


-- 导出  表 metoo.s_c_operation 结构
CREATE TABLE IF NOT EXISTS `s_c_operation` (
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='操作';

-- 正在导出表  metoo.s_c_operation 的数据：~0 rows (大约)
DELETE FROM `s_c_operation`;
/*!40000 ALTER TABLE `s_c_operation` DISABLE KEYS */;
/*!40000 ALTER TABLE `s_c_operation` ENABLE KEYS */;


-- 导出  表 metoo.s_itemtype 结构
CREATE TABLE IF NOT EXISTS `s_itemtype` (
  `id` int(11) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 正在导出表  metoo.s_itemtype 的数据：~3 rows (大约)
DELETE FROM `s_itemtype`;
/*!40000 ALTER TABLE `s_itemtype` DISABLE KEYS */;
INSERT INTO `s_itemtype` (`id`, `name`) VALUES
	(110001, '翠罗宝玉'),
	(111002, '青岚宝玉'),
	(210001, '天蚕猎装');
/*!40000 ALTER TABLE `s_itemtype` ENABLE KEYS */;


-- 导出  表 metoo.s_roleinit 结构
CREATE TABLE IF NOT EXISTS `s_roleinit` (
  `id` int(11) unsigned NOT NULL,
  `data1` int(11) unsigned NOT NULL,
  `data2` int(11) unsigned NOT NULL,
  `str1` text NOT NULL,
  `str2` text NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 正在导出表  metoo.s_roleinit 的数据：~1 rows (大约)
DELETE FROM `s_roleinit`;
/*!40000 ALTER TABLE `s_roleinit` DISABLE KEYS */;
INSERT INTO `s_roleinit` (`id`, `data1`, `data2`, `str1`, `str2`, `description`) VALUES
	(1, 0, 0, '1,1;2,1;3,1;4,1;5,1;6,1;7,1;8,1;12,1;13,1;28,1;29,1;30,1;31,1;54,1;55,1;56,1;62,1', '', '初始建筑');
/*!40000 ALTER TABLE `s_roleinit` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
