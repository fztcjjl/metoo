-- --------------------------------------------------------
-- 主机:                           127.0.0.1
-- 服务器版本:                        5.0.18-nt - MySQL Community Edition (GPL)
-- 服务器操作系统:                      Win32
-- HeidiSQL 版本:                  8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 导出 metoo 的数据库结构
DROP DATABASE IF EXISTS `metoo`;
CREATE DATABASE IF NOT EXISTS `metoo` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `metoo`;


-- 导出  表 metoo.d_account 结构
CREATE TABLE IF NOT EXISTS `d_account` (
  `id` int(11) unsigned NOT NULL COMMENT '系统编号，对应d_user表的uid',
  `pid` varchar(50) NOT NULL COMMENT '平台下发的id',
  `sdkid` int(11) unsigned NOT NULL COMMENT 'sdkid',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `pid_sdkid` (`pid`,`sdkid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帐号表';

-- 正在导出表  metoo.d_account 的数据：~3 rows (大约)
DELETE FROM `d_account`;
/*!40000 ALTER TABLE `d_account` DISABLE KEYS */;
INSERT INTO `d_account` (`id`, `pid`, `sdkid`) VALUES
	(3, '1001', 1),
	(1, '1008', 1),
	(2, '1088', 1);
/*!40000 ALTER TABLE `d_account` ENABLE KEYS */;


-- 导出  表 metoo.d_item 结构
CREATE TABLE IF NOT EXISTS `d_item` (
  `id` int(11) unsigned NOT NULL COMMENT '系统编号',
  `uid` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `itemid` int(11) unsigned NOT NULL COMMENT '物品ID，对应s_itemtype表的id',
  `superposition` int(11) unsigned NOT NULL COMMENT '物品叠加数',
  PRIMARY KEY  (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品表';

-- 正在导出表  metoo.d_item 的数据：~6 rows (大约)
DELETE FROM `d_item`;
/*!40000 ALTER TABLE `d_item` DISABLE KEYS */;
INSERT INTO `d_item` (`id`, `uid`, `itemid`, `superposition`) VALUES
	(1, 1, 110001, 3),
	(2, 1, 111002, 3),
	(3, 2, 110001, 5),
	(4, 1, 210001, 2),
	(5, 2, 210001, 3),
	(6, 3, 110001, 3);
/*!40000 ALTER TABLE `d_item` ENABLE KEYS */;


-- 导出  表 metoo.d_ranking 结构
CREATE TABLE IF NOT EXISTS `d_ranking` (
  `uid` int(10) unsigned NOT NULL COMMENT '玩家ID',
  `attack_win` int(10) unsigned NOT NULL default '0' COMMENT '攻击胜利次数',
  `defend_win` int(10) unsigned NOT NULL default '0' COMMENT '防守胜利次数',
  PRIMARY KEY  (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='排行榜';

-- 正在导出表  metoo.d_ranking 的数据：~3 rows (大约)
DELETE FROM `d_ranking`;
/*!40000 ALTER TABLE `d_ranking` DISABLE KEYS */;
INSERT INTO `d_ranking` (`uid`, `attack_win`, `defend_win`) VALUES
	(1, 6, 9),
	(2, 5, 8),
	(3, 10, 12);
/*!40000 ALTER TABLE `d_ranking` ENABLE KEYS */;


-- 导出  表 metoo.d_user 结构
CREATE TABLE IF NOT EXISTS `d_user` (
  `uid` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `name` varchar(50) NOT NULL COMMENT '角色名称',
  `level` int(11) unsigned NOT NULL default '0' COMMENT '等级',
  `exp` int(11) unsigned NOT NULL default '0' COMMENT '经验',
  `rtime` int(10) unsigned NOT NULL default '0' COMMENT '注册时间',
  `ltime` int(10) unsigned NOT NULL default '0' COMMENT '最后一次登出时间',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家角色表';

-- 正在导出表  metoo.d_user 的数据：~3 rows (大约)
DELETE FROM `d_user`;
/*!40000 ALTER TABLE `d_user` DISABLE KEYS */;
INSERT INTO `d_user` (`uid`, `name`, `level`, `exp`, `rtime`, `ltime`) VALUES
	(1, 'user1', 5, 20, 0, 0),
	(2, 'user2', 3, 16, 0, 0),
	(3, 'user3', 7, 30, 0, 0);
/*!40000 ALTER TABLE `d_user` ENABLE KEYS */;


-- 导出  表 metoo.s_config 结构
CREATE TABLE IF NOT EXISTS `s_config` (
  `id` int(11) unsigned NOT NULL,
  `data1` int(11) unsigned NOT NULL default '0',
  `data2` int(11) unsigned NOT NULL default '0',
  `data3` int(11) unsigned NOT NULL default '0',
  `data4` int(11) unsigned NOT NULL default '0',
  `data5` int(11) unsigned NOT NULL default '0',
  `str1` varchar(255) NOT NULL default '',
  `str2` varchar(255) NOT NULL default '',
  `str3` varchar(255) NOT NULL default '',
  `str4` varchar(255) NOT NULL default '',
  `str5` varchar(255) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='配置表';

-- 正在导出表  metoo.s_config 的数据：~3 rows (大约)
DELETE FROM `s_config`;
/*!40000 ALTER TABLE `s_config` DISABLE KEYS */;
INSERT INTO `s_config` (`id`, `data1`, `data2`, `data3`, `data4`, `data5`, `str1`, `str2`, `str3`, `str4`, `str5`, `description`) VALUES
	(1, 10, 0, 0, 0, 0, '', '', '', '', '', ''),
	(2, 20, 30, 0, 0, 0, '', '', '', '', '', ''),
	(3, 0, 0, 0, 0, 0, '10,20,30', '', '', '', '', '');
/*!40000 ALTER TABLE `s_config` ENABLE KEYS */;


-- 导出  表 metoo.s_itemtype 结构
CREATE TABLE IF NOT EXISTS `s_itemtype` (
  `id` int(11) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 正在导出表  metoo.s_itemtype 的数据：~3 rows (大约)
DELETE FROM `s_itemtype`;
/*!40000 ALTER TABLE `s_itemtype` DISABLE KEYS */;
INSERT INTO `s_itemtype` (`id`, `name`) VALUES
	(110001, '翠罗宝玉'),
	(111002, '青岚宝玉'),
	(210001, '天蚕猎装');
/*!40000 ALTER TABLE `s_itemtype` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
