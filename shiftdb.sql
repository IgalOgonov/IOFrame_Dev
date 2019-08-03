-- phpMyAdmin SQL Dump
-- version 4.5.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: May 26, 2019 at 11:28 PM
-- Server version: 5.7.11
-- PHP Version: 7.0.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shiftdb`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `commitEventIP` (`IP` VARCHAR(45), `Event_Type` BIGINT(20) UNSIGNED, `Is_Reliable` BOOLEAN, `Full_IP` VARCHAR(10000)) RETURNS INT(20) BEGIN
                DECLARE eventCount INT;
                DECLARE Add_TTL INT;
                DECLARE Blacklist_For INT;
                                SELECT Sequence_Count INTO eventCount FROM
                           IP_EVENTS WHERE(
                               IP_EVENTS.IP = IP AND
                               IP_EVENTS.Event_Type = Event_Type AND
                               IP_EVENTS.Sequence_Expires > UNIX_TIMESTAMP()
                           )
                            LIMIT 1;

                                IF ISNULL(eventCount) THEN
                    SELECT 0 INTO eventCount;
                END IF;

                                SELECT EVENTS_RULEBOOK.Add_TTL,EVENTS_RULEBOOK.Blacklist_For INTO Add_TTL,Blacklist_For FROM EVENTS_RULEBOOK WHERE
                                        Event_Category = 0 AND
                                        EVENTS_RULEBOOK.Event_Type = Event_Type AND
                                        Sequence_Number<=eventCount ORDER BY Sequence_Number DESC LIMIT 1;

                IF eventCount>0 THEN
                    BEGIN
                        UPDATE IP_EVENTS SET
                                Sequence_Expires = Sequence_Expires + Add_TTL,
                                Sequence_Count = eventCount + 1,
                                Meta = Full_IP
                                WHERE
                                   IP_EVENTS.IP = IP AND
                                   IP_EVENTS.Event_Type = Event_Type AND
                                   IP_EVENTS.Sequence_Expires > UNIX_TIMESTAMP();
                    END;
                ELSE
                    BEGIN
                    INSERT INTO IP_EVENTS (
                        IP,
                        Event_Type,
                        Sequence_Expires,
                        Sequence_Start_Time,
                        Sequence_Count,
                        Meta
                    )
                    VALUES (
                        IP,
                        Event_Type,
                        UNIX_TIMESTAMP()+Add_TTL,
                        UNIX_TIMESTAMP(),
                        1,
                        Full_IP
                    )
                     ON DUPLICATE KEY UPDATE Sequence_Count = Sequence_Count+1;
                    END;
                END IF;

                                IF Blacklist_For > 0 THEN
                    INSERT INTO IP_LIST (IP_Type,Is_Reliable,IP,Expires) VALUES (0,Is_Reliable,IP,UNIX_TIMESTAMP()+Blacklist_For)
                    ON DUPLICATE KEY UPDATE Expires = GREATEST(Expires,UNIX_TIMESTAMP()+Blacklist_For);
                END IF;

                RETURN eventCount+1;
            END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `commitEventUser` (`ID` INT(11), `Event_Type` BIGINT(20) UNSIGNED) RETURNS INT(20) BEGIN
                DECLARE eventCount INT;
                DECLARE Add_TTL INT;
                DECLARE Blacklist_For INT;
                                SELECT Sequence_Count INTO eventCount FROM
                           USER_EVENTS WHERE(
                               USER_EVENTS.ID = ID AND
                               USER_EVENTS.Event_Type = Event_Type AND
                               USER_EVENTS.Sequence_Expires > UNIX_TIMESTAMP()
                           )
                            LIMIT 1;

                                IF ISNULL(eventCount) THEN
                    SELECT 0 INTO eventCount;
                END IF;

                                SELECT EVENTS_RULEBOOK.Add_TTL,EVENTS_RULEBOOK.Blacklist_For INTO Add_TTL,Blacklist_For FROM ACTIONS_RULEBOOK WHERE
                                        Event_Category = 1 AND
                                        EVENTS_RULEBOOK.Event_Type = Event_Type AND
                                        Sequence_Number<=eventCount ORDER BY Sequence_Number DESC LIMIT 1;

                IF eventCount>0 THEN
                    BEGIN
                        UPDATE USER_EVENTS SET
                                Sequence_Expires = Sequence_Expires + Add_TTL,
                                Sequence_Count = eventCount + 1
                                WHERE
                                    USER_EVENTS.ID = ID AND
                                    USER_EVENTS.Event_Type = Event_Type AND
                                    USER_EVENTS.Sequence_Expires > UNIX_TIMESTAMP();

                    END;
                ELSE
                    BEGIN
                    INSERT INTO USER_EVENTS (
                        ID,
                        Event_Type,
                        Sequence_Expires,
                        Sequence_Start_Time,
                        Sequence_Count
                    )
                    VALUES (
                        ID,
                        Event_Type,
                        UNIX_TIMESTAMP()+Add_TTL,
                        UNIX_TIMESTAMP(),
                        1
                    );
                    END;
                END IF;

                                IF Blacklist_For > 0 THEN
                    UPDATE USERS_EXTRA SET
                            Suspicious_Until = GREATEST(Suspicious_Until,UNIX_TIMESTAMP()+Blacklist_For)
                            WHERE
                                USERS_EXTRA.ID = ID;
                END IF;

                RETURN eventCount+1;
            END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `actions_auth`
--

CREATE TABLE `actions_auth` (
  `Auth_Action` varchar(256) NOT NULL,
  `Description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `actions_auth`
--

INSERT INTO `actions_auth` (`Auth_Action`, `Description`) VALUES
('ADMIN_ACCESS_AUTH', 'Required to access administrator pages'),
('ASSIGN_OBJECT_AUTH', 'Action required to assign objects in the object map'),
('BAN_USERS_AUTH', 'Required to ban users'),
('PLUGIN_GET_AVAILABLE_AUTH', 'Required to get available plugins'),
('PLUGIN_GET_INFO_AUTH', 'Required to get plugin info'),
('PLUGIN_GET_ORDER_AUTH', 'Required to get plugin order'),
('PLUGIN_IGNORE_VALIDATION', 'Required to ignore plugin validation during installation'),
('PLUGIN_INSTALL_AUTH', 'Required to install a plugin'),
('PLUGIN_MOVE_ORDER_AUTH', 'Required to move plugin order'),
('PLUGIN_PUSH_TO_ORDER_AUTH', 'Required to push to plugin order'),
('PLUGIN_REMOVE_FROM_ORDER_AUTH', 'Required to remove from plugin order'),
('PLUGIN_SWAP_ORDER_AUTH', 'Required to swap plugin order'),
('PLUGIN_UNINSTALL_AUTH', 'Required to uninstall a plugin'),
('REGISTER_USER_AUTH', 'Required to register a user when self-registration is not allowed'),
('TREE_C_AUTH', 'Required to create all trees'),
('TREE_D_AUTH', 'Required to delete all trees'),
('TREE_MODIFY_ALL', 'Required to modify all trees'),
('TREE_R_AUTH', 'Required to read all trees'),
('TREE_U_AUTH', 'Required to update all trees');

-- --------------------------------------------------------

--
-- Table structure for table `core_values`
--

CREATE TABLE `core_values` (
  `tableKey` varchar(255) CHARACTER SET utf8 NOT NULL,
  `tableValue` text CHARACTER SET utf8 NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `core_values`
--

INSERT INTO `core_values` (`tableKey`, `tableValue`) VALUES
('privateKey', 'b4d1603e7f18641b8bac6184debe93c591be61cd94c21e9e6320260d470942e3'),
('secure_file_priv', 'E:/wamp64/tmp/'),
('plugin_order', 'testPlugin,testPlugin2');

-- --------------------------------------------------------

--
-- Table structure for table `db_backup_meta`
--

CREATE TABLE `db_backup_meta` (
  `ID` int(11) NOT NULL,
  `Backup_Date` varchar(14) NOT NULL,
  `Table_Name` varchar(64) NOT NULL,
  `Full_Name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `db_backup_meta`
--

INSERT INTO `db_backup_meta` (`ID`, `Backup_Date`, `Table_Name`, `Full_Name`) VALUES
(1, '1541177560', 'db_backup_meta', 'E:/wamp64/tmp/db_backup_meta_backup_timeLimit_17837.txt'),
(2, '1541177560', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_timeLimit_17837.txt'),
(3, '1541177560', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_timeLimit_17837.txt'),
(4, '1541177561', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_timeLimit_17837.txt'),
(5, '1541968978', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541968978.txt'),
(6, '1541968978', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541968978.txt'),
(7, '1541968978', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541968978.txt'),
(8, '1541969082', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541969082.txt'),
(9, '1541969082', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541969082.txt'),
(10, '1541969082', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541969082.txt'),
(11, '1541969893', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541969893.txt'),
(12, '1541969893', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541969893.txt'),
(13, '1541969893', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541969893.txt'),
(14, '1541970058', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541970058.txt'),
(15, '1541970058', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541970058.txt'),
(16, '1541970058', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541970058.txt'),
(17, '1541970232', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541970232.txt'),
(18, '1541970232', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541970232.txt'),
(19, '1541970232', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541970232.txt'),
(20, '1541970411', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1541970411.txt'),
(21, '1541970411', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1541970411.txt'),
(22, '1541970411', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1541970411.txt'),
(23, '1542035361', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1542035361.txt'),
(24, '1542035361', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1542035361.txt'),
(25, '1542035362', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1542035362.txt'),
(26, '1543105436', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1543105436.txt'),
(27, '1543105436', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1543105436.txt'),
(28, '1543105436', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1543105436.txt'),
(29, '1543105827', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1543105827.txt'),
(30, '1543105827', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1543105827.txt'),
(31, '1543105827', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1543105827.txt'),
(32, '1543677022', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1543677022.txt'),
(33, '1543677022', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1543677022.txt'),
(34, '1543677022', 'OBJECT_PAGE_MAP', 'E:/wamp64/tmp/OBJECT_PAGE_MAP_backup_1543677022.txt'),
(35, '1543677392', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1543677392.txt'),
(36, '1543677392', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1543677392.txt'),
(37, '1543677392', 'OBJECT_MAP', 'E:/wamp64/tmp/OBJECT_MAP_backup_1543677392.txt'),
(38, '1543888266', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1543888266.txt'),
(39, '1543888266', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1543888266.txt'),
(40, '1543888266', 'OBJECT_MAP', 'E:/wamp64/tmp/OBJECT_MAP_backup_1543888266.txt'),
(41, '1544202303', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_timeLimit_17872.txt'),
(42, '1544202303', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_timeLimit_17872.txt'),
(43, '1544202303', 'OBJECT_MAP', 'E:/wamp64/tmp/OBJECT_MAP_backup_timeLimit_17872.txt'),
(44, '1544485561', 'OBJECT_CACHE_META', 'E:/wamp64/tmp/OBJECT_CACHE_META_backup_1544485561.txt'),
(45, '1544485562', 'OBJECT_CACHE', 'E:/wamp64/tmp/OBJECT_CACHE_backup_1544485562.txt'),
(46, '1544485562', 'OBJECT_MAP', 'E:/wamp64/tmp/OBJECT_MAP_backup_1544485562.txt');

-- --------------------------------------------------------

--
-- Table structure for table `events_rulebook`
--

CREATE TABLE `events_rulebook` (
  `Event_Category` int(32) NOT NULL,
  `Event_Type` bigint(20) UNSIGNED NOT NULL,
  `Sequence_Number` int(10) UNSIGNED NOT NULL,
  `Blacklist_For` int(10) UNSIGNED DEFAULT NULL,
  `Add_TTL` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `events_rulebook`
--

INSERT INTO `events_rulebook` (`Event_Category`, `Event_Type`, `Sequence_Number`, `Blacklist_For`, `Add_TTL`) VALUES
(0, 0, 0, 0, 8640),
(0, 0, 1, 0, 0),
(0, 0, 5, 60, 0),
(0, 0, 7, 300, 3600),
(0, 0, 8, 1200, 43200),
(0, 0, 9, 3600, 86400),
(0, 0, 10, 86400, 604800),
(0, 0, 11, 31557600, 31557600),
(1, 0, 0, 0, 17280),
(1, 0, 1, 0, 0),
(1, 0, 5, 0, 86400),
(1, 0, 6, 0, 0),
(1, 0, 10, 0, 2678400),
(1, 0, 11, 0, 0),
(1, 0, 100, 2678400, 31557600);

-- --------------------------------------------------------

--
-- Table structure for table `groups_actions_auth`
--

CREATE TABLE `groups_actions_auth` (
  `Auth_Group` varchar(256) NOT NULL,
  `Auth_Action` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `groups_actions_auth`
--

INSERT INTO `groups_actions_auth` (`Auth_Group`, `Auth_Action`) VALUES
('Another Test Group', 'ADMIN_ACCESS_AUTH'),
('Another Test Group', 'BAN_USERS_AUTH'),
('Test Group', 'TREE_C_AUTH'),
('Test Group', 'TREE_D_AUTH'),
('Test Group', 'TREE_R_AUTH'),
('Test Group', 'TREE_U_AUTH');

-- --------------------------------------------------------

--
-- Table structure for table `groups_auth`
--

CREATE TABLE `groups_auth` (
  `Auth_Group` varchar(256) NOT NULL,
  `Last_Changed` varchar(11) NOT NULL DEFAULT '0',
  `Description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `groups_auth`
--

INSERT INTO `groups_auth` (`Auth_Group`, `Last_Changed`, `Description`) VALUES
('Another Test Group', '1551655447', NULL),
('Test Group', '1554494758', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ipv4_range`
--

CREATE TABLE `ipv4_range` (
  `IP_Type` tinyint(1) NOT NULL,
  `Prefix` varchar(11) NOT NULL,
  `IP_From` tinyint(3) UNSIGNED NOT NULL,
  `IP_To` tinyint(3) UNSIGNED NOT NULL,
  `Expires` varchar(14) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ipv4_range`
--

INSERT INTO `ipv4_range` (`IP_Type`, `Prefix`, `IP_From`, `IP_To`, `Expires`) VALUES
(1, '10.10', 0, 21, '15535524720'),
(0, '10.10.21', 0, 255, '15535524720'),
(1, '10.10.21', 25, 50, '15535524720'),
(0, '10.213', 200, 255, '15535524720'),
(1, '10.213.234', 0, 255, '1');

-- --------------------------------------------------------

--
-- Table structure for table `ip_events`
--

CREATE TABLE `ip_events` (
  `IP` varchar(45) NOT NULL,
  `Event_Type` bigint(20) UNSIGNED NOT NULL,
  `Sequence_Expires` varchar(14) NOT NULL,
  `Sequence_Start_Time` varchar(14) NOT NULL,
  `Sequence_Count` bigint(20) UNSIGNED NOT NULL,
  `Meta` varchar(10000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ip_events`
--

INSERT INTO `ip_events` (`IP`, `Event_Type`, `Sequence_Expires`, `Sequence_Start_Time`, `Sequence_Count`, `Meta`) VALUES
('1.2.3.4', 0, '1553991111', '1553982471', 6, ''),
('127.0.0.1', 0, '1557154784', '1557146144', 1, '127.0.0.1'),
('127.0.0.1', 0, '1557459815', '1557451175', 1, '127.0.0.1'),
('127.0.0.1', 0, '1558294073', '1558285433', 1, '127.0.0.1'),
('127.0.0.1', 0, '1558669183', '1558660543', 1, '127.0.0.1'),
('::1', 0, '1557459821', '1557451181', 1, '::1');

-- --------------------------------------------------------

--
-- Table structure for table `ip_list`
--

CREATE TABLE `ip_list` (
  `IP` varchar(45) NOT NULL,
  `Is_Reliable` tinyint(1) NOT NULL,
  `IP_Type` tinyint(1) NOT NULL,
  `Expires` varchar(14) NOT NULL,
  `Meta` varchar(10000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ip_list`
--

INSERT INTO `ip_list` (`IP`, `Is_Reliable`, `IP_Type`, `Expires`, `Meta`) VALUES
('0.1.2.3', 1, 1, '16535524720', NULL),
('1.2.3.4', 1, 0, '1553982783', '');

-- --------------------------------------------------------

--
-- Table structure for table `login_history`
--

CREATE TABLE `login_history` (
  `Username` varchar(16) NOT NULL,
  `IP` varchar(45) NOT NULL,
  `Country` varchar(20) NOT NULL,
  `Login_History` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `login_history`
--

INSERT INTO `login_history` (`Username`, `IP`, `Country`, `Login_History`) VALUES
('lowAuthTest', '::1', 'Unkonwn', '1544049652#'),
('test123', '127.0.0.1', 'Unkonwn', '1547233543#1547665027#1550160321#1550250948#1550324661#1551111209#1551128400#1551137467#1551148967#1553542247#1553545066#1553548996#1553552031#1553565818#1553602465#1553605947#1553609132#1553626880#1553651622#1553689342#1553691878#1553692067#1553710801#1553715887#1553735875#1553880715#1553886306#1553890936#1553908068#1553953728#1553960740#1553979728#1553983641#1554046243#1554048034#1554052158#1554055584#1554062185#1554064941#1554075699#1554077526#1554121084#1554135731#1554144336#1554155881#1554157376#1554158855#1554161774#1554214676#1554216490#1554219952#1554230638#1554234135#1554236661#1554241554#1554243154#1554245536#1554307913#1554473112#1554572821#1554578495#1554580719#1554592165#1554595281#1554597292#1554654673#1554661020#1554742461#1554751841#1554753640#1554758354#1554927979#1554933567#1554939895#1554991137#1555034906#1555072426#1555099838#1555117358#1555166522#1555169191#1555171338#1555177988#1555183291#1555187043#1555190795#1555196333#1555198085#1555201581#1555204948#1555245869#1555245927#1555250544#1555267797#1555273333#1555285488#1555338420#1555340668#1555343483#1555369576#1555371517#1555374380#1555376968#1555422185#1555425611#1555452541#1555486982#1555487180#1555518073#1555550669#1555598038#1555605532#1555607091#1555608723#1555618039#1555626231#1555637374#1555677275#1555708214#1555711534#1555717946#1555720900#1555724943#1555793614#1555804742#1555853567#1555863223#1555867218#1555897652#1555967196#1555967477#1556064436#1556070296#1556070789#1556071358#1556071405#1556108109#1556110634#1556134571#1556140382#1556146449#1556197416#1556199869#1556204302#1556209008#1556215434#1556218951#1556221498#1556228172#1556237452#1556241454#1556280918#1556284837#1556379130#1556450881#1556459010#1556461432#1556476987#1556481317#1556485406#1556489976#1556495119#1556497649#1556552705#1556574138#1556583239#1556586475#1556816200#1556833486#1556936682#1556984009#1556984023#1556991492#1557013195#1557016765#1557100774#1557146177#1557184750#1557268672#1557445255#1557447964#1557451178#1557520667#1557523233#1557526862#1557530141#1557539048#1557590653#1557613816#1557675200#1557688805#1557701953#1557756884#1557761365#1557764024#1557787404#1557798818#1557879098#1557929938#1558096748#1558098851#1558102366#1558104319#1558124008#1558130528#1558141329#1558144775#1558187834#1558194500#1558196607#1558201373#1558215724#1558225793#1558285433#1558286076#1558401368#1558459708#1558482016#1558522459#1558540762#1558559837#1558653301#1558660384#1558660386#1558660388#1558660391#1558660394#1558660396#1558660397#1558660400#1558660649#1558660650#1558660651#1558660652#1558660653#1558660654#1558660695#1558660698#1558661275#1558661276#1558661277#1558661277#1558661301#1558661302#1558661302#1558661303#1558661304#1558661305#1558661306#1558711766#1558826456#'),
('test123', '::1', 'Unkonwn', '1543675794#1543686500#1543698667#1543702621#1543708609#1543717424#1543761847#1543775944#1543846831#1543853145#1543853424#1543853625#1543853638#1543853975#1543858875#1543865101#1543870401#1543876536#1543887332#1543928667#1543943702#1543951217#1543955141#1543968896#1544022460#1544037134#1544047792#1544049694#1544052044#1544052172#1544058713#1544106310#1544147769#1544190816#1544202301#1544207678#1544220099#1544233171#1544282358#1544286664#1544292880#1544309994#1544316471#1544369250#1544377204#1544385905#1544401336#1544479396#1544485408#1544489163#1544495027#1544536827#1544552212#1544563742#1544571781#1544628018#1544639926#1544650165#1544658197#1544662097#1544669504#1544669533#1544669545#1544669874#1544669985#1544707254#1544738333#1544794178#1544798545#1544802688#1544812721#1544840633#1544886258#1544910971#1544921708#1544969684#1544975140#1544991754#1544991832#1544991838#1544991844#1544991846#1544991861#1544991913#1544991920#1544991922#1544991940#1544991955#1544991977#1544992001#1544992437#1544992458#1544996177#1545065673#1545074617#1545082383#1545086172#1545158281#1545223866#1545232519#1545240899#1545245763#1545256547#1545326241#1545489977#1545508208#1545512460#1545596616#1545601463#1545652299#1545666363#1545671564#1545680347#1545691391#1545772218#1545777354#1545833418#1545838119#1545850534#1545857256#1546200967#1546858423#1547064968#1547555228#1548068577#1548080048#1548101802#1548154042#1548333379#1548506894#1548514447#1548545910#1548685425#1548716626#1548789766#1548802617#1548805145#1548805206#1548805925#1548871435#1548890478#1549036546#1549058217#1549069176#1549069176#1549130851#1549147627#1549151100#1549151789#1549157283#1549195435#1549209017#1549231769#1549242386#1549292298#1549378160#1549379037#1549379595#1549379802#1549397674#1549443496#1549542353#1549647670#1549649069#1549649097#1549651816#1549651830#1549652828#1549653225#1549659191#1549680275#1549726687#1549745433#1549762914#1549799938#1549894467#1549918977#1549934960#1549934969#1549980108#1549980274#1549980275#1549980345#1549980346#1549980431#1549980590#1549980734#1549980736#1549980772#1549980774#1549980823#1549980824#1549980917#1549980918#1549980977#1549980979#1549981504#1549981505#1549981780#1549982001#1549982009#1549987708#1550016293#1550016301#1550415152#1550493699#1550501032#1550502490#1550503510#1550509781#1550511704#1550511750#1550615145#1550668152#1550678758#1550707180#1550751208#1550848136#1550882792#1550887670#1550925885#1550941570#1550954347#1550961031#1550967546#1550999423#1551010095#1551019919#1551020158#1551023380#1551023394#1551045209#1551182316#1551196266#1551200653#1551212650#1551225018#1551225033#1551316048#1551316114#1551316225#1551316261#1551355099#1551448209#1551458780#1551466801#1551470904#1551480353#1551493603#1551531479#1551547360#1551576258#1551620773#1551655440#1551655445#1551719298#1551870394#1551905519#1551909640#1551913117#1551918676#1552056781#1552061015#1552063456#1552075780#1552079359#1552084908#1552098253#1552140500#1552144618#1552148314#1552153903#1552159709#1552165196#1552169485#1552173166#1552174622#1552176092#1552178482#1552219242#1552244034#1552246447#1552250319#1552266064#1552318432#1552330882#1552336466#1552339281#1552346269#1552386200#1552390814#1552392568#1552395452#1552414620#1552417924#1552430962#1552432880#1552481541#1552522381#1552571988#1552576963#1552578775#1552581376#1552584703#1552590961#1552615233#1552617382#1552655464#1552662596#1552675763#1552819289#1552827782#1552844408#1552932562#1552945670#1552946563#1552947488#1552949045#1552952000#1552952946#1552954810#1552956730#1552956950#1552957023#1552957656#1552990486#1552993901#1552996500#1553027528#1553035417#1553181010#1553201578#1553207773#1553214292#1553221342#1553222139#1553222236#1553222274#1553222324#1553222361#1553222862#1553272504#1553272504#1553352471#1553352478#1553352551#1553352703#1553352715#1553352726#1553352746#1553352892#1553390981#1553391068#1553474959#1553518917#1553537571#1553542084#1553691084#1555897629#1557451077#1557451161#');

-- --------------------------------------------------------

--
-- Table structure for table `logs_active`
--

CREATE TABLE `logs_active` (
  `ID` int(10) UNSIGNED NOT NULL,
  `channel` varchar(255) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `message` longtext,
  `time` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `mail_auth`
--

CREATE TABLE `mail_auth` (
  `Name` varchar(255) NOT NULL,
  `Value` longtext NOT NULL,
  `expires` varchar(14) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mail_auth`
--

INSERT INTO `mail_auth` (`Name`, `Value`, `expires`) VALUES
('1@15', 'Hj82G0uIAgM5mGLttnDITV6b6opH3p', '1543016471'),
('igal1333@hotmail.com', 'J3GMGF8SCnILK0s6OVLV0XDQ3pxYbb', '1549150765');

-- --------------------------------------------------------

--
-- Table structure for table `mail_templates`
--

CREATE TABLE `mail_templates` (
  `ID` int(11) NOT NULL,
  `Title` varchar(255) NOT NULL,
  `Content` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mail_templates`
--

INSERT INTO `mail_templates` (`ID`, `Title`, `Content`) VALUES
(1, 'Account Activation Default Template', 'Hello%33%%60%br%62%%32%To%32%activate%32%your%32%account%32%on%32%IOFrame%32%Localhost%44%%32%click%32%%60%a%32%href%61%%34%http%58%%x2x47%localhost%47%Shiftmaker%46%com%47%api%47%regConfirm%46%php%63%id%61%%x2x37%uId%x2x37%&code%61%%x2x37%Code%x2x37%"%62%this%32%link%60%%47%a%62%%60%br%62%The%32%link%32%will%32%expire%32%in%32%72%32%hours%46%'),
(2, 'Password Reset Default Template', 'Hello%33%%60%br%62%You%32%have%32%requested%32%to%32%reset%32%the%32%password%32%associated%32%with%32%this%32%account%46%%32%To%32%do%32%so%44%%32%click%32%%60%a%32%href%61%%34%http%58%%x2x47%localhost%47%Shiftmaker%46%com%47%api%47%pwdReset%46%php%63%id%61%%x2x37%uId%x2x37%&code%61%%x2x37%Code%x2x37%"%62%this%32%link%60%%47%a%62%%60%br%62%The%32%link%32%will%32%expire%32%in%32%72%32%hours%46%'),
(3, 'Mail Reset Default Template', 'Hello%33%%60%br%62%%32%To%32%change%32%your%32%mail%32%on%32%IOFrame%32%Localhost%44%%32%click%32%%60%a%32%href%61%%34%http%58%%x2x47%localhost%47%Shiftmaker%46%com%47%api%47%users%63%action%61%mailReset%38%id%61%%x2x37%uId%x2x37%&code%61%%x2x37%Code%x2x37%"%62%this%32%link%60%%47%a%62%%60%br%62%%32%The%32%link%32%will%32%expire%32%in%32%72%32%hours');

-- --------------------------------------------------------

--
-- Table structure for table `object_cache`
--

CREATE TABLE `object_cache` (
  `ID` int(11) NOT NULL,
  `Ob_Group` varchar(255) DEFAULT NULL,
  `Last_Updated` varchar(14) NOT NULL,
  `Owner` int(11) DEFAULT NULL,
  `Owner_Group` varchar(10000) DEFAULT NULL,
  `Min_Modify_Rank` int(11) NOT NULL DEFAULT '0',
  `Min_View_Rank` int(11) DEFAULT '-1',
  `Object` mediumtext NOT NULL,
  `Meta` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `object_cache`
--

INSERT INTO `object_cache` (`ID`, `Ob_Group`, `Last_Updated`, `Owner`, `Owner_Group`, `Min_Modify_Rank`, `Min_View_Rank`, `Object`, `Meta`) VALUES
(8, 'g1', '1523129839', 1, NULL, 5, 6, 'test02', NULL),
(9, 'g3', '1523129839', 1, NULL, 10, -1, 'Final%32%Obj%32%Update%32%Test', NULL),
(10, 'g2', '1523129839', 1, NULL, 12, -1, 'test04', NULL),
(11, 'g1', '1558464822', 1, NULL, 10, 15, 'testX5', NULL),
(12, 'g2', '1523129839', 1, NULL, 3, 7, 'test06', NULL),
(14, 'g3', '1523129839', 1, NULL, 0, -1, 'test07', NULL),
(15, 'courses', '1523379253', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%core%32%comm%34%%44%%32%%34%title%34%%58%%34%Communication%32%Networks%34%%44%%32%%34%content%34%%58%%34%Network%32%Layers%44%%32%Error%32%Detection%32%schemes%44%%32%Network%32%structures%32%%40%like%32%Aloha%44%%32%Ethernet%44%%32%etc%46%%41%%44%%32%Wireless%32%Communications%44%%32%and%32%TCP%47%IP%32%protocols%32%and%32%packet%32%structure%46%%34%%32%%125%', NULL),
(16, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%core%32%img%34%%44%%32%%34%title%34%%58%%34%Final%32%Project%32%%45%%32%Obstacle%32%Recognition%34%%44%%32%%34%content%34%%58%%34%Design%32%and%32%testing%32%of%32%Obstacle%32%Detection%32%models%32%%45%%32%implementation%32%using%32%OpenCV%32%and%32%Python%46%%34%%32%%125%', NULL),
(17, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%core%32%img%34%%44%%32%%34%title%34%%58%%34%Multispectral%32%Images%32%%45%%32%Seminar%34%%44%%32%%34%content%34%%58%%34%Presentation%32%of%32%topics%32%related%32%to%32%Multispectral%32%Images%44%%32%and%32%their%32%applications%46%%34%%32%%125%', NULL),
(18, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%adv%32%img%34%%44%%32%%34%title%34%%58%%34%Image%32%Processing%34%%44%%32%%34%content%34%%58%%34%Basic%32%Image%32%Proccessing%32%%45%%32%Transofrms%44%%32%detections%44%%32%compression%44%%32%and%32%more%46%%32%Familiarity%32%with%32%Matlab%46%%34%%32%%125%', NULL),
(19, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%adv%32%img%34%%44%%32%%34%title%34%%58%%34%Image%44%%32%Sound%32%%38%%32%Video%32%Compression%34%%44%%32%%34%content%34%%58%%34%Various%32%image%44%%32%sound%32%and%32%video%32%compression%32%techniques%32%%45%%32%includes%32%some%32%classic%44%%32%and%32%some%32%more%32%compression%32%formats%32%for%32%each%32%of%32%the%32%topics%44%%32%such%32%as%32%JPEG%44%%32%H%45%264%47%MPEG4%44%%32%and%32%more%46%%34%%32%%125%', NULL),
(20, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%adv%32%default%34%%44%%32%%34%title%34%%58%%34%Database%32%Design%34%%44%%32%%34%content%34%%58%%34%Relational%32%Algebra%44%%32%SQL%32%Database%32%scheme%32%design%44%%32%Internal%32%DB%32%design%32%and%32%optimization%44%%32%translating%32%client%32%requirements%32%to%32%design%44%%32%ERD%32%schemes%46%%34%%32%%125%', NULL),
(21, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%adv%32%finTech%34%%44%%32%%34%title%34%%58%%34%Algoritrading%34%%44%%32%%34%content%34%%58%%34%Various%32%basic%32%trading%32%strategies%44%%32%indicators%44%%32%etc%46%%32%Implementation%32%of%32%the%32%above%32%in%32%EasyLanguage%44%%32%using%32%TradeStation%46%%34%%32%%125%', NULL),
(22, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%sec%34%%44%%32%%34%title%34%%58%%34%Computer%32%%38%%32%Network%32%Security%34%%44%%32%%34%content%34%%58%%34%Basic%32%software%32%security%32%exploits%32%%40%Stack%32%Overflow%44%%32%etc%41%%44%%32%Symmetric%32%and%32%Asymmetric%32%Crpytography%44%%32%Signitures%44%%32%MACs%44%%32%Firewalls%44%%32%various%32%classic%32%and%32%current%32%security%32%protocols%32%and%32%techniques%32%%40%WEP%44%%32%Diffie%32%Helman%44%%32%RSA%44%%32%Entrence%32%Control%32%Techniques%44%%32%PKI%44%%32%SSL%44%%32%IPsec%44%%32%etc%46%%46%%41%%34%%32%%125%', NULL),
(23, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%sec%34%%44%%32%%34%title%34%%58%%34%Foundations%32%of%32%Cryptography%34%%44%%32%%34%content%34%%58%%34%Foundations%32%of%32%cryptographic%32%primitives%44%%32%with%32%focus%32%an%32%rigous%32%mathematical%32%proofs%46%%32%One%45%Way%32%Functions%44%%32%Pseudo%32%Random%32%Generators%32%%40%and%32%Functions%41%%44%%32%MACs%44%%32%and%32%many%32%more%32%well%32%defined%32%cryptographic%32%primitives%46%%34%%32%%125%', NULL),
(24, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%sec%32%comm%34%%44%%32%%34%title%34%%58%%34%Advanced%32%Topics%32%in%32%Internet%32%Communications%34%%44%%32%%34%content%34%%58%%34%Topics%32%from%32%basic%32%protocols%32%such%32%as%32%InServ%44%%32%DiffServ%44%%32%QoS%32%etc%46%%32%MPLS%46%%32%VPN%46%%32%SSL%32%and%32%IPSec%44%%32%IPV6%44%%32%Moobile%32%IP%44%%32%and%32%much%32%more%46%%34%%32%%125%', NULL),
(25, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%algo%34%%44%%32%%34%title%34%%58%%34%Algorithms%32%for%32%Planar%32%Graphs%34%%44%%32%%34%content%34%%58%%34%The%32%latest%32%and%32%greatest%32%advancements%32%in%32%algorithms%32%in%32%Planar%32%Graphs%46%%32%Includes%32%things%32%such%32%as%32%MSSP%44%%32%FR%45%Dijkstra%44%%32%Cycle%32%Seperators%32%in%32%Planar%32%Graphs%44%%32%Vertex%45%Cover%32%and%32%TSM%32%%40%PTAS%32%using%32%Baker%39%s%32%Technique%41%%44%%32%and%32%more%46%%34%%32%%125%', NULL),
(26, 'courses', '1523379254', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%algo%34%%44%%32%%34%title%34%%58%%34%Approximation%32%Algorithms%34%%44%%32%%34%content%34%%58%%34%%32%Various%32%approximation%32%algorithms%32%%45%%32%no%32%specific%32%topics%44%%32%most%32%algorithms%32%can%32%be%32%found%32%in%32%the%32%advanced%32%chapters%32%of%32%%92%%34%Algorithm%32%Design%32%by%32%Jon%32%Kleinberg%44%%32%Eva%32%Tardos%92%%34%%44%%32%and%32%%92%%34%Design%32%of%32%Approximation%32%Algorithms%32%by%32%David%32%P%46%Williamson%32%and%32%David%32%B%46%%32%Shmoys%92%%34%%34%%32%%125%', NULL),
(27, 'courses', '1558286167', 1, NULL, 0, -1, '%123%%34%type%34%%58%%34%filterTable%34%%44%%32%%34%filter%34%%58%%34%A%34%%44%%32%%34%filters%34%%58%%34%all%32%msc%32%default%34%%44%%32%%34%title%34%%58%%34%Massive%32%Data%32%Streams%32%%40%Distributed%32%Computing%41%%34%%44%%32%%34%content%34%%58%%34%%32%Various%32%topics%32%in%32%Distributed%32%Computing%44%%32%with%32%a%32%focus%32%on%32%massive%32%data%32%streams%46%%34%%125%', NULL),
(28, NULL, '1540643224', 1, NULL, 0, -1, '%215%%160%%215%%161%%215%%153%%215%%149%%215%%159%', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `object_cache_meta`
--

CREATE TABLE `object_cache_meta` (
  `Group_Name` varchar(255) NOT NULL,
  `Owner` int(11) DEFAULT NULL,
  `Last_Updated` varchar(14) NOT NULL,
  `Allow_Addition` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `object_cache_meta`
--

INSERT INTO `object_cache_meta` (`Group_Name`, `Owner`, `Last_Updated`, `Allow_Addition`) VALUES
('courses', 1, '1558286167', 0),
('g1', 1, '1558464822', 0),
('g2', 1, '1558463215', 1),
('g3', 1, '1558464822', 0),
('g4', 1, '1556383427', 0),
('testComments', 1, '1556553171', 0);

-- --------------------------------------------------------

--
-- Table structure for table `object_map`
--

CREATE TABLE `object_map` (
  `Map_Name` varchar(255) NOT NULL,
  `Objects` text,
  `Last_Changed` varchar(14) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `object_map`
--

INSERT INTO `object_map` (`Map_Name`, `Objects`, `Last_Changed`) VALUES
('@', '{"11":11,"14":14}', '1558463480'),
('cp/objects.php', '{"9":9,"14":14}', '1523133574'),
('CV/CV.php', '{"15":15,"16":16,"17":17,"18":18,"19":19,"20":20,"21":21,"22":22,"23":23,"24":24,"25":25,"26":26,"27":27}', '1558460811');

-- --------------------------------------------------------

--
-- Table structure for table `settings_mailsettings`
--

CREATE TABLE `settings_mailsettings` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings_mailsettings`
--

INSERT INTO `settings_mailsettings` (`settingKey`, `settingValue`) VALUES
('mailEncryption', 'ssl'),
('mailHost', 'hp235.hostpapa.com'),
('mailPassword', 'cYir7CcUGVT%'),
('mailPort', '465'),
('mailUsername', 'global@ioweb.co.il'),
('_Last_Changed', '1551655447');

-- --------------------------------------------------------

--
-- Table structure for table `settings_pagesettings`
--

CREATE TABLE `settings_pagesettings` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings_pagesettings`
--

INSERT INTO `settings_pagesettings` (`settingKey`, `settingValue`) VALUES
('loginPage', ''),
('mailConfirmedPage', ''),
('pwdReset', ''),
('_Last_Changed', '1551655447');

-- --------------------------------------------------------

--
-- Table structure for table `settings_sitesettings`
--

CREATE TABLE `settings_sitesettings` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings_sitesettings`
--

INSERT INTO `settings_sitesettings` (`settingKey`, `settingValue`) VALUES
('logStatus', 'low'),
('maxInacTime', '3600'),
('maxObjectSize', '4000000'),
('secStatus', 'low'),
('siteName', 'IOFrame Localhost'),
('sslOn', '1'),
('_Last_Changed', '1553352880');

-- --------------------------------------------------------

--
-- Table structure for table `settings_usersettings`
--

CREATE TABLE `settings_usersettings` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings_usersettings`
--

INSERT INTO `settings_usersettings` (`settingKey`, `settingValue`) VALUES
('allowRegularLogin', '1'),
('allowRegularReg', '1'),
('emailChangeTemplate', '3'),
('mailConfirmExpires', '72'),
('passwordResetTime', '5'),
('pwdResetExpires', '72'),
('pwdResetTemplate', '2'),
('regConfirmMail', '1'),
('regConfirmTemplate', '1'),
('rememberMe', '1'),
('selfReg', '1'),
('usernameChoice', '1'),
('userTokenExpiresIn', '0'),
('_Last_Changed', '1552999669');

-- --------------------------------------------------------

--
-- Table structure for table `test_euler_tree1_tree`
--

CREATE TABLE `test_euler_tree1_tree` (
  `ID` int(11) NOT NULL,
  `content` varchar(10000) NOT NULL,
  `smallestEdge` int(11) NOT NULL,
  `largestEdge` int(11) NOT NULL,
  `lastChanged` varchar(14) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `test_euler_tree1_tree`
--

INSERT INTO `test_euler_tree1_tree` (`ID`, `content`, `smallestEdge`, `largestEdge`, `lastChanged`) VALUES
(0, 'Root / Node 0', 1, 10, '0'),
(1, 'Node 1', 1, 2, '0'),
(2, 'Node 2', 3, 4, '0'),
(3, 'Node 3', 5, 10, '0'),
(4, 'Node 4', 6, 9, '0'),
(5, 'test', 7, 8, '0');

-- --------------------------------------------------------

--
-- Table structure for table `test_euler_tree1_tree_meta`
--

CREATE TABLE `test_euler_tree1_tree_meta` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `test_euler_tree1_tree_meta`
--

INSERT INTO `test_euler_tree1_tree_meta` (`settingKey`, `settingValue`) VALUES
('_Last_Changed', '1552222054'),
('_Private', '1');

-- --------------------------------------------------------

--
-- Table structure for table `test_euler_tree2_tree`
--

CREATE TABLE `test_euler_tree2_tree` (
  `ID` int(11) NOT NULL,
  `content` varchar(10000) NOT NULL,
  `smallestEdge` int(11) NOT NULL,
  `largestEdge` int(11) NOT NULL,
  `lastChanged` varchar(14) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `test_euler_tree2_tree`
--

INSERT INTO `test_euler_tree2_tree` (`ID`, `content`, `smallestEdge`, `largestEdge`, `lastChanged`) VALUES
(0, 'Root / Node 0', 1, 28, '0'),
(1, 'Node 1', 1, 26, '0'),
(2, 'Node 2', 2, 3, '0'),
(3, 'Horrible content!@#$%^&*()[]{}', 4, 13, '0'),
(4, 'Node 1', 5, 6, '0'),
(5, 'Node 2', 7, 8, '0'),
(6, 'Node 3', 9, 12, '0'),
(7, 'Node 4', 10, 11, '0'),
(8, 'Root / Node 0', 14, 23, '0'),
(9, 'Node 1', 15, 16, '0'),
(10, 'Node 2', 17, 18, '0'),
(11, 'Node 3', 19, 22, '0'),
(12, 'Node 4', 20, 21, '0'),
(13, 'Node 3', 24, 25, '0'),
(14, 'Node 4', 27, 28, '0');

-- --------------------------------------------------------

--
-- Table structure for table `test_euler_tree2_tree_meta`
--

CREATE TABLE `test_euler_tree2_tree_meta` (
  `settingKey` varchar(255) NOT NULL,
  `settingValue` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `test_euler_tree2_tree_meta`
--

INSERT INTO `test_euler_tree2_tree_meta` (`settingKey`, `settingValue`) VALUES
('_Last_Changed', '1552222524'),
('_Private', '0');

-- --------------------------------------------------------

--
-- Table structure for table `test_pactions_auth`
--

CREATE TABLE `test_pactions_auth` (
  `Auth_Action` varchar(256) NOT NULL,
  `Description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `test_pgroups_auth`
--

CREATE TABLE `test_pgroups_auth` (
  `Auth_Group` varchar(256) NOT NULL,
  `Last_Changed` varchar(11) NOT NULL DEFAULT '0',
  `Description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `test_pusers`
--

CREATE TABLE `test_pusers` (
  `ID` int(11) NOT NULL,
  `Username` varchar(16) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Active` tinyint(1) NOT NULL,
  `Auth_Rank` int(11) DEFAULT NULL,
  `SessionID` varchar(255) DEFAULT NULL,
  `authDetails` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `test_table`
--

CREATE TABLE `test_table` (
  `ID` int(11) NOT NULL,
  `testVarchar` varchar(255) DEFAULT NULL,
  `testLargeText` text,
  `testDateVarchar` varchar(14) DEFAULT NULL,
  `testInt` int(11) DEFAULT NULL,
  `testFloat` float DEFAULT NULL,
  `testDate` date DEFAULT NULL,
  `testDatetime` datetime DEFAULT NULL,
  `testTimestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `testBlob` mediumblob
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `test_table`
--

INSERT INTO `test_table` (`ID`, `testVarchar`, `testLargeText`, `testDateVarchar`, `testInt`, `testFloat`, `testDate`, `testDatetime`, `testTimestamp`, `testBlob`) VALUES
(1, 'tk7ilfEQQdMIhHCcwHKYVFgfjyJK2ShHXxuQl4sm8oLZC0wWFRkWCqfdiFUr46nUKCggIKDLOr88laOzcShOG3C3EFr2tcQWYAoy', 'tkc3RnR9rcs45LBx7ynLoxmtgaFUxqUJBL8chbY2V7urmxi9XWumvhEOq1THv8ML75re5RrOLUTG0cnC8cZP0Uk1WJtoQI3GZh78gpirZyFP1HPZGkRaSom5SlrWxbGuflbVOQwWA6PPp7DdDl6o6KM29PMoCvGaSiBzJ88lyvlGbnQkWdItH0zSOauH5I5HS7q62j7BUOfrkwpjDZIrH7JzQoATUOQ8fOBvHnsKCYw4QymaHB5i46h9fu3W7LZq0naMKicKI0ayJrGU97Q1OYcA2tTTGBuA8P6Wb6iEcVcX0envYuWBUHuVck6HEjnDD9oZZMLp2HBbDSs09Kr4oka8I3GnZUDyvk5TakD3gmnjFoUlITjpgPccDEEWGmgmLp9EHLSzRUwj4MIAETyCubC9V80nLGh2olzjC4sYPj3bP4XGYLbI7qpZztHGeUFzoanRXfrebBWXYduFEwbG6xzGBHOT4Zq0LSyfBiOmULeyuerxIaxwsw7g1OgWgWyiwq7wEewn0OT3n8LgaFifco2IOL6TRM4sES3G52DgsIUqEUtTZ3pQj8k3YCjGOuYvacmITH72jvjFiyxmbjUjOK0fumUn85dq2o3C3gYFwa5Oj4ZIJrLEEf2kpWSXQxReis6pBGcb8HeOHtPWGr1SUBshGqcnVSSUVpx4w0Oz67LFtJ140kDYvRf6lMVGn5frVelAQbMQrpFqCTA3G5DXuYpOo00Sda1SiVw0ve8ZazX38VxUKI0LRYWnO7tXp89a3u5hyaS0gBAx2ORDceKuAPSQz5jS0YEkbX1qZYYTJwCVizyf0BS5HzaaJXwGWFxnGfksLDrEAj1aWeCIcSmycbQmhE7nhgOiyr0mWcjiOYOiYK55L0eU3FSrbg5XZIr6Pv49vCxOpvWim9UkH0t7i3iosJpm43sLrsuOqX8cnVta8q6q1T6dUh5d858FwgQjrhikI67sIdnVgzFpHD6bTofVajdSmlBJPYuJpatB', '1557536286', -559, 0.4969, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303131313031303030313030303031303131),
(2, 'MACgLht1goMuzpGXyjJ2zx31s5cBxpj2FuW0dMdJ0gHWmowS99fcHZZaSTjv1kkpWgDB2akk600hveJF6R8fcjhcFzMgR7JEAUI6', 'eqQOABFt3Ykmqroa5uY7R8DU5MvMBqasMyH8s6HyWyiV8U2Ykz1ToySqFjEM0QZGIyWmGt8vf2Cmde2DYvsxkRtOEJbEL6bO3ryrjHVkUolFFrqbYkg4C2s5015pVfKMJcypiQ52XCqRvwbBl2rti5OdIbm2qhHDOPXgEPCBlITVHukU6A0Kl1xePd1wka2nfkFZoGx48GJRikQ4e2XVLPD7h83UAXIZ3IMzvqQohxWFf2I7ImfWzv7T8Vr9fAOsfYi2Z3vAPgxmzCZ2ByXRK3ZwmAdhg7fPO6anRxxFISuVh5BQRCZCitd2W7nhEv43K7pA6UYC1lQlmpCuuzpheMOqVxU9qMga401GH9KsFGyEPC13uoePwYMGgPOUyXQ9KK1EGgV9HVDREHLsS5pdc19QZZ5w5WM0Pnov3fsJ716VRFUKCEYvfWSR51I1ZR7JgT8dM7nbU0XRrvpXK6UEFKZJyXKofCPl5hgPURFv4RaEodiZfpdGtqsvpI9DTgTQgwKhotlHAzJlIMyU8BTAEZj9CoXLUMkbQECCfYnMvbHUqgcGnFWncpxEeX5LibaqLFSQukOJME3lvAdm1Cn28I93clBD4smw5xuX6zAzr0KEYOAV1rbyqU8jxCvodBXvMjtU5GKhteRQOTmko8mY6WtrgMM1JCTnRXRJrFiRTkjU0RuC9HXf9TdsmQrvCwc6hrAsbxdiFi9QAF0Oh9RozGjmQJsTTiUI6PI3ihvCQ9mExoTRLtaqnmM7FwS8xWYci5dwMUbQmTWlSY9LEFRkxVEKUcDgytqyRd5SEodUhtVUzrMyUJU76lThuJMgWSfMOdk5TKDRyWglELOexFlL1DtEt9j8I9rU76Wbu0qGdjYE7ZbMxu9ikPsXPqdTSi1TORX9u7Aofw4QW4XcVckH0TP4xAuvnjYJSujZR78YECwU915uFKTZ3Ox5DD90hdhtj03HAY3prBmQJRAFOdP9tBEY6xbnxZZ58nbiHIlJ', '1557536613', -399, 0.4222, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130313131303031303131303030303031),
(3, 'GztHiw8agi8JWkzCbC4yjDFLbk1W9bak19JDbIO5rQZnb0lKc9vVTLx73P313M8TIBnqqMSR0hdTLxvKAxkaPLMkhctZkgtkOWn6', '3JivVzPhJW2CmPwg8EppUqgO0BbDgaLD4y73dKOx5eXnvY6fPppoTxqv2QhP6fw4rfirUO9GOod02Z36T3LefxY5rXJTicFmcPRIWJTHUrRuVTnQkywWZpTxdVzPT2bxjgMTnxZAnlTScE4r9XDx69bSnKMDQK4zPz5Vadsme8h7Qj9Xlc80AKR4VunkakkvHLLPlLk0rO4fRQAiUk0lrfT9P5lTTMWiWQQBUcyv3ldffepwRkfzGCj67yGkW8YYzMgfPv9U1KJ71uBDadSEiR6VLVoDplmvAB4M7G8am3DSaDbCRYSChZgCO8tPfq7XYifcMJui5cVuFF8tVBetDYOcdfWTsnfeISOtQFdjbfzZzzsdm7ZbnQIE0dMP2dKoQjJCgtkdEaAmQlaPau6Muz1Z940CZXDrlD3E49OYuW0BtZeimKAfZcGbGMAjjvUmeQJyfHEBIBLJvvFEXTsARGIgAoyS2YxatUMlM8T8j9VJUUvTSTHO539dTSTj7jyQ6Qe0IruviysBEbH0bLkUGiX2xdBCywXn7E2w1BtMDRmmOkhZSwkSGp6JzrGOoBHOumdXGFPVm1CZkleQX9GH3oDjZxaSByQ6fVLdJAyXs3htdfxznErqMgyLLw0ObolgmnHmaoEPVYjRu1fbc3y1U0R6XndC87ejSG1oY58ALKH68FjFoi3unCwis6OjtGueKTGi9D0e0pue9cL1WqVQf7ynnGLSb9820WK5G4eJAWDexAAgTra3ttZkEa6jgu9HCUbJCmP8yma6jRMmdkM96IL9jwPCHHwfCIZgVxOoUE4Rs0mlU5M75QXRlKUOxMhF1pbFAAaxCPltY2jdYH9WrPtqKRnSKJqYKZJWDwTyIRZYSXCXpdUFbGoTxPdOkzX8TqE74k0rcL1l8HkydB1girGdHFqBhiPboJY9S1td3yqAMlp2pRvJM3mpeo1iCS56gXE32ykRgdcIOSRoYZo5Dxou90YSkkIUw0HPAZym', '1557537128', 198, 0.1912, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303031303031313031303031313030313030),
(4, 'cgFCV0CiTUPrqtjipFIz9W9tviaKQaSAYxSJeSfou9Bh5P2BRT779LW1Pt91bsLl6GrIVDfmtgLY737OGYSxws8puwu9UC3YCHoz', 'ZgCcQgjyw9zRUV0Qh2GGxsea0EHsvBIjqLmVz8e0j8qMtKw0ptCRYgk4tzIQMnpVf9tvGSwktZDBqtp3VOXTLXOPjm85q2uoqpZYbtcw0HeiL3FYM0CMXuFsx1UdrxXK0xRj2YeBVjbRtviL34FzuVUZ8y4dQWK0Xy6xhlEycMwiyRjrF06epeum7YA5BdW6fqHCTzroR8fB04HZFPVKHptCsguQKmw5WbHATGB6UmkMQ9sp3w6aosQLbqKsgotX1P5rfG9FjsMR36AHO5ErroyMhspWahOFrkPaZy475qCMCX6SXxAAScFFJnrkq4vhgHXK5imrfhQAADZVrRTCES9rAaQz5HzLsYrdzV2EM1qhVefQj3zwQq05PPCH6e1816jyro4IGBoRCGTDz7DjoReApmLHuCRmY6yLFLuFY5JhH2Ujc44Yj9QZnLizgU3thZbSi1hvDrrAaehRcTSuBkPfI4cko3CsYJaQh8rdFExMZk3hzz3UhoaoretWV4yj2nxGD7ZM5L0Qchbzk9BbkjUpxg8rPYT3tThonZUfSJQLL7GJsAxkK70i1b9P5JAEigpZuIcy1A3AJPzMYURmyOt3SYy4IoE8twUsYlSLyjDh4pQHQ6xhJlkG5CkcJU7u3ELOQQUQsVBQLStv6aA3hMydGatc8jXIZE115ckOKoWhRdtaI72Hd5aBEz04Uz8QixD7Gr7CpJEAjpSIIXQevg9S0SUP3IHPZiC5FyhkrYKL8vC86C1Dbjv0I2brzKEF3X0V2xPUR4dQlsLqRczVefe1P4QXsDYpurJDLpJmD33LVihBZDv5E3lUiZSjIpF1jPSeT92GMUgzT0aEuYP7sIPF8Lgyn4Jvv5mHnLHTkCRgdAqzmau1DhFjmr2GoAcR4de3egJYedPQV34mCeyMbHUQWYcGMZ161dtgtCaVwGag0o42faZr71vdXoIyygdck66m5SWJb3SzsAsAfZOZpcuthFCjHpMb1R5k4Z7r', '1557535829', -769, 0.804, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303130313030303131313131313130313130),
(5, 'hGd0CGZn5fQC0QUXdqJ35usarZE1CnqPuDlinfxF8bzD6Sxq7k4LwZdTbQztplgK4tStvHtPyZFwzMzOn6KoknkthASOzctz2bKw', '11LRmE9ipzY41JQSwCPWLcx06V4gmL1rTdsKwd0XDfKb2ghe6KGhDGz51w2P4eDe9hvx5DereLUbqF6s2LXvS302i0mg9zEULeWc0WQQccq3cXizlEyAuiMRWl5zBL3sL3KIj7P6xtkOl5Sy2pyytpWyZzaKqSOS9JX8ZbbfhDBqS7Pp62VpQpu8oFDPDPXaUjup26UfmFgXK099xxF8zhpAbEtKdErl2KqysU19QAhi2LRKmXMIG1HVlvGzbmknx4JAgAuUGnGyFqVeybhbaCn7SehfvWAjpgquq9lxU3sFGWmA7j9w27pcMQfPdpe6EkthZzz4vABF5lcP3koKguQ94jzfiKfLihUXUSbst08xRCoXnc1QTICYIEiyKWCji6Isc3aIPh2i0LYV4Y1OSQMFKTnKz3oJFMUST6vRxrjVvMUL8AnEeQkgaZROM0w2qms9X2fSDuYqpGevz68mYHfHWWGKmQ2dyOojmQlK7o0MFsX7ntfY5rx27OUykxVf38Hk9vPwYbo3j60BzJJqz4deExufE8bbXknfk4FabRbalCsY8SBLqyfjy8sOmAPYbor1TuUFLokaJ1hc5TRZFVFgQBMfrVPDPkSFOOv4KOR2uitjoKt5has6vYvyU8dbP9Fd6Zuk65KMDr3h5vt3ghCMxbAJJdYBcRSBL2RtPf2pas0999QTCganWh3OXb7UWpqTPYzuViFV3mjTAEABm85PIgUJw1C45Sl3fLGnocHhk81up2HctSn9T77ytIv7zbE53ra9eZ7xYM5YAicFYu3mqQHeOjL2snlZe01MsETEZjxkaq41QZ5qkrEOvLpQHroLLqfi3c2EnHmy6qje4lvnCV0eA6pvloQqHJRG1Byw9ZyFqjXkFAidhgIx3jO3ldDW0VQWnTshi88E74XiFHsVjuOJToytIUPmFYb663JUO95vbHj82G0uIAgM5mGLttnDITV6b6opH3pfBd3RLyVXvz6JFcdXBVjM9H10', '1557536720', 704, 0.2605, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303130313131313031313031313130313130),
(6, 'YP6RqAarTidgEpkxCU6Z6eCPWnuKvOP2CsblCRFVmVTtc9UeWumUZqiI8XloIsA9DZCGbZxgepVx6JSMEWZHeumvFmzVk0J92nrX', '8ZMtsLluoddeJh0nSrMaBEbjiph1OED2rSoz518k3zVxcunVSgBGUQazDHbLXOd18Cox48i25M1I2z9lfWM6zUwHmSrosPaTcgLnq8QBuUtMexhD0wlnCPfIsU6UlIuBDLv6aZK4hSjIPnMO8Yhw3CmBXP8gCubes9CGhJ3nqIwxL5FRCizyRjQnMBwwg9gHDp89LlIAYr7d6FXLvugs1RG10gjDhFH4dx0uCQKFT35MO8zzKykfziVwAOsDF4xi9xfISdbCawqdTsAfouKUuAwVzdZvrkJpsqROtrYrPS8wlFYMojyqOLvbVvTgAtjo9bRLsy89R6eIbKJdL1JQtPRkDFaT6vffdPeCPyFIgcGLnISvwzi7wKAlJHPo0pzZEjYlyqAb3bwIYynFD2ehWyGedCQKgbhAtH6XFaTvd2JwVggI9lxjKea03pf1VPl4FWAoaLyHJKkdfRwD2xedVM1Dh418XlOqe5sJ2gAMEmiLWjarhBhZtdf9SBa8kJCEb6HWgD1JXQDd2Da7UyIDowRxQ1G061PLuZk3SSOyAblwuRyEVnwbGHQOcjAKeaoKbJj1S0YgCprHkXj5i4HznKcXVtSnKblBfmGSeZvQ2vULwUsn3DgRqGVW0vwTE5ElGSqzYRqiPtJH7JYxa5c1Ru2RtqxfVRmWvgya4AICZkWw4rRAFov3DavBkdWvyvqrGv3DydnPv3xdo27vyAbWPImfxSICz2TOgDVZqHqUqEvL6uKjOEfJn9AL9pTCYqH2cEacE4QRH8RcbPKZqBFoisc97PpuJGU9vwMihjDFmtyvD29wrqtVACbqs7jfTQt7ciLggqOnpHDHt7UXP7FkgGwybhASpSqZgV96CplWOO7LF52fzGeBjBgzhjeniKKIHqTPmhgpAMWHgVypG8aKJpmsKegKyxrkwO1pt1yJKDavdCrscssMx6QeB1E0dbwOI4vTYDdXimKcxdGn5E9GIEGSPFr7eHYahcneP8g1', '1557535796', 613, 0.5609, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303130303131303130303131313030303131),
(7, 'fFkakIctg5VnqdA7C6ModdCr4uFYtr3ck0lQWED8cnwLoC70onZvx5fxFJtO9MLvMdIoWtrEuyv2JV1JxwyueQfvERDub1RGCiuO', 'lbC4aBSbs5im3xvlitBl1Qb5A7kKPgC65JbldxAcy7WSWrQ5JZm4KH6wn5aGp68hdc7vDlH522YfddwGxmtESroRwXnvmO1kIvqwr1bRSPnuRSBbJCY8m4334FYcGohfAH7rCz2u6t9BSn3wiKQsdy68YgXKoRV2RLada0g0G1iBgMSLfK5GsVv5gJgbtbXHtIAS6jSoEqPu235SyDHL4ajVV6ZuXojgtxpoouRE1IIebcERfoHJ3htBWj4GLt5FReAO4xcMJT0RHeAIj24Aqh1cmqxKYrdYBO957tXOQVEmA7VrKxPja8XD9onGyhI9Jf5fxh2HiQGJSUC3zVXUgTeYifAuvZBcfyohlWvs9C5ZvxGxKbqmKuTbQYbbQzS77K4bvvm6mhR6w48UkjiHCZXfJz8Jx2vUnP8W4XACYP16VsY8gjxXRmlc23tbCmvz0LyBZfc0XfxZGJafAca1tA92Gocu5zU80Am9iqbhhwrIQTJehWaZsHjJIChFVEExnhxxYtxp0GIllUG5lAwQPHRj8IJJ8COQ8R6Q1ogq6ImRfO0PL6hxyzLKVHAFHsj1gi2ZrcnjzDoevzHqAto9Fj455yOuEac3LCl1fTR5qqMt9dLUMJTB9VIiBhobZKsZDP2VprHID6zAbJeglSKW1pLmwSlJHd5LUT5HYSXefCIAz93uiS0agMbkOlGbLx6rwPwmTaxCd3ftkpfBBKCgS2Z9sHpueKuZwDkTblwTyk9dtyPAivCeR99RuXuF4QfpUlviSpS2huqQ0ALrm9Z4d8GqU2WJhOnHEU4zVkB3nw5lTt6bODJMW0BTG0MFRDUTMm0Il8HXRr6IafMMC2Rn4JUdRR0tOlMViFjK8PbHGevYOUShOhlRymypnzAa9X2RaSZEjm2lVUh5PqjDnpecpRBuibyIRoFDqX3rSOgRvqq5dP8SjqspEd1rzEUaXIGj3Tt6M6SfuRYYZ6kYCj5vgsPge0BtnX4R3HiC5hRv', '1557537062', 960, 0.7049, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030313131303130303030313131313131),
(8, '8fUWj45tfzZYgeHEd1Qhqot2KkdDyi8kDgRPnGsjBywxFkaIqZYzbY2jPgXEElMQxabyPcc2lqr0sj0E0PtJjpYte42y7fPdOXSa', 'DAjCsaJkCadtWwmMPIgu2JwjY2dsszWDQQP6WMowaTOai7CHGVWpdinWcH0zt6o0oYGrPhrB4uLI0zgvWZ1bKIBtMf9zSvdelZXE3DRylY7a5UhbzXrQG2dRKEFsDLqlESxJETEn1jPtw7EIzKfnZdb86XzcLV0klCxIE0P53xVEmcq9WrqLEgxgP6RPiWXbpfVy1ZmEsDnIzayrH1Z3HchhV9ukbQgVRKEhKRh7eBdE904BQsVd80nao3wHsBYwF8LSSBzrosqs6HWElMefXFRXfQXW6g21RohkldeDXc19ridzdZV97eHzsvH47Mtmqw9FdHhIQMZH9KRnt3YXEEX543R4vbjBmxoUr4GF7gk9e5R36ZpAAWxt2snWhsvHFp1Z4juuMC2sFifA6Od7T8wJnJhGqB5Gmb0W3qEcPQ8Dvn01tvowycTT6UyjXC2yqOnOpqcLeXAHIl9je4WOB7BUcWdPQwlhSj7v9i7e1VqDiaEtmwTW2VHMFRec6i3TGGf7g2pyaLDsgTxwSQcZQBcxvDDrKX7nTWJzKD4KHue9AsOrJ2ST0a3bJjpyLszJr5BVB87QB6cHiXqfZ6XFyAhHkRzyaRoYn5R8RvwMUzw9ngrVC3mktTT6jg6rX8A5HYtesJkCyVfsQtQsCSaRM4RmEy0b4ha4oIscrRujA9kDEyAT0ymgs7dunHgOAi7VsmQ2OR2U0fOHSwIbK8Vxv3WvtKVjucrEUSzKxIWlMeDDrlelTzQGXR3oXEWGKY8gHfHlEsfFX4Rrp48onT9IJwwaMslXoCdJUvcP95UStOr8JDnjg5QCU5nO1783p9E6sD4a1zWWoopGr617v9TpsvBkBEh3OxtkpDjnfXmUFSJ8wr2M96k4nPdHz4OXzPFrIwXtRbaJkesrZEpk9V8AG0cYVmHFIYfqphVrRikrmsxDOJbKwBj0m3y7DwZifZchtVihdhS1Ly1G1Gj3hbShpZh8JyDO8Tw1Vq30W9Ms', '1557536513', -257, 0.6927, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130303131313030313130303031303030),
(9, 'AwPdpCOrQMn1dtEboEdCJOaA4T5MIn4ryfHgUW7tCsSM4g4q3ii7V4E4xvJ0f6E8TPYbM9MnO1IqhVQx4PJtucwpp0M4aHCGAhBZ', '2dR9mrWXTsZxsdyHqcLCDmc1rbW8FCCEF9hOhKykRSvqeuLOK5oIgB0R6wFr8Q0cFY6lzXwAcapanDkMrQoGfIay8KKCWVLB3FhJfZTJVkGMTEhEvtKwBHH8xRdGaSUVOeQ1jUCK1mliMyBoXYvflzCzkQ4CJHp5XGLbIHIDuhnF3kj0KmCQsjVUuGhqHqi8q04dwocok4LVGZntWB7jWXz71pS720y3jcK7HW32yIx2HvPQvJZDOqCbX1PGJscQygPUfnhy9gH26UE4sKeS3M29dua7POcvcdfybFTW8FeVSaRbLDRWE2QYSQTqh1A4c235tRSdtY8E1jqasoRVD90FV4YC66ltzIeu9Velc8pixln1w1dL09xfjaqFj3uLkiMLcQWmia3MqfGKYwYuJ0sH68gBTT0WsJIVCD3fK55aH1omMV55RKK2gZuqRBT0W32Wqkx1BStplEsRYazxlmpeOH47bb9VQfIRBSoEQwgxmbVcxirTcRsjHj2FTDLH5jLD9jCaq4pwKzJrtjG6rdSgZMn7YZMnIgdi5BeyotXpwRXxMcjc3sF5E95qqcbXI51PnMcPJLQ9F0vwtWja3zQMGmbBfhXl6Lce3QyYsX7Mb1soxzF1pznm6sDFse4DRlKv6LiZyYLh5VM7Z5qI9riPSrtB24zPYMGFwzoS2TMElGtIOsxkfbA92iGp0MsSt70GkfSDTFcUZlyd0I2MJMflz1h6kmIMmjFBuOIh6kY21S0zyRU8BhiqtCfF2PmzBnJn3eWMHS71pgPOvS9lQEHnL6A67anfeja2YxybFhDUaw1VPJLrsTvcqripznKOf8YyhIxr1zxDjFAUvvLpr0FUsFoBoswdCQaYWLUAJJPhQHxKz89fO0dtSLREBpEvnoIf0HCAQLtLIASu1DTYxS8XEKGAcfaGuREpqvIujGv90ny6Q10yEBqgOAUp9Y3I0aWrebdf9tUoD1Dz1hv28e5slku6txjETmDloJ4T', '1557536153', 966, 0.5242, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303131303030303130303131303030303030),
(10, 'Ex5XApnn0I8xfVsEb0Wr8qG7WaipYFQw3XUawpCAf5xuxoO6glY7Kn8LSsUOW5moPd6hQieGRkljcKvpIylELcXjbDS4ing9YmFg', 'w3eEQrv1eYBAyD759T7HRHec1xxLtnC7AGBucq3AD54EKAfnUsF0UCYd7zbgnhWR2cldXiY3q3UAlqKy1UB9kq46zudDD3EsRzsO32gnAU7pi9DAwdVb77xSqhBThHIW3QYhxEVz7CH5CIUwppB5iEovEWo1jdajBYQCo9YE2eFEkbxjEtESR6C1ftx1HC0xxY5QDvnBjH15pwxZhq5wLoepdU4TtTcDSRGVfKbrY3IoSIXwhfU34zdFybYDB2LCyBGTeSl80hOAHPGWFX5sKCzPhlfg84IuCf4JBRTIpnhDULQfpvDJOyiQnnUK1W2e4KOslIOacm7AuBlpxWzTdmoIRiV8iJJQS8X3rs6umdkorjes3hTV12TuH5knXnOj4oqvX5KHTXV5LUunXtyPcAJ8VK6vWUgFCwiROzOLOwTDtm7bbxCBJ1YDwhfvli5Uzwx52XdI50d5yH8ROt3gFkz2uHMn7zh1TpaaEb1yJmXo1UwoOiRMYvxiQZG8gIR0za98DibgLA1zR0hPb02cDyUry9WKLJORDOwZ0iIQbGuD3Wp7XyAtGuDrEbBfFD7A5igGJ9DhYEkzDMVh41wD7iJl86DCXpPcUGoiRUXB8vxoAuOkzkQEVYd6YT2SA3UG5XTKkvAPEe84V54frwwz6w4JcyP0Bzl2E4K6c0DTzQ6DCxH3HAzlDWigM6Y00ZahA50jqn3QRjq4HTIIkx10zgUDLvuSLfmnVYCp3BRFwE9na56gkmPxSqTV7MoCUoXmBIBn2I1nyTez0bSGH30Xxuf3QWFfqqTeFlZdoIyWYZHCc80ZsCydApY4X0jJkjdW6RIX8AtpJYxzMYv9A4un1d4WpUl7A5UyVfRwfkLIUPKnJFoc6nOpPUyIfGKmeJZ37ul0JXqXrxl44gE7Yztj0spmtmwufgqpFCdlAqt1l9iCLIiVeDx6xTDS4UFuDEfDCDsyQOTYCCD4R4jARAYKsbfg2jcmpXrKXw5Er2GM', '1557535980', 625, 0.1995, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313130313031303130313131313030313031),
(11, 'jgG8RpMhLmdwnA67y51JCh5CqaRukcry9mrye6YGrpzF7KnJ56YAGUrsM9o4JiUCljARZFwYuljGcO2eY0ik8pcbw1jwwgKyX961', '77s7V9pzFH3BeL0XWMjLDKBRF7YnTRZ4CrK9IQTlwusRTp4p83Of8ng3dRy3drfZuDr3TnJZJaeZUXvLHbFA0Sj87rvCVUTMKHvQrOYulHoZill0DcVOeeI5pVR30fTsnDXum7zTj7VR4Bx7W4xUQtwU4hzmsrh0nsJ1Fiy9EoPBcK76EQxSQAGB6uEyix2qKaVqllVhny5eIM3WHsUHczebvB7BuuaIvItHohDitBJICFnG9YEqXr9DizWy5kGTDbpRP5JcWvL6Tr5iYlL13brYrqam22zX9uITBKeWOjalw69MaBgtwO6aZ9K3mCQR1GpMMj5A1YWtxCB9IJ8Poi9fTKIB45sEhKszlJj7Bv6tX1qnFJn3CEycbe439ptjUHUeg3VuAVClHiCtZC08fUm1QzLmBCSSUwHKyeTLXdw6RrcsFn06e1wISOSxrHChhdTafhfUEmOIns9kJ1mWA04ihUkBDFKA2MrridZVKpsdgms4bw7FkSZK4TaxevgKaenBH15OektAx8aF0UegrBh5eJnmbd9OFxGDvGyz47TQbLf9baIIXeXhKsY3vOpIxJmxGfpdiLEYciGvKiA4MIZmF3XBdg3vOOqjeFDITjOYAGvJGiQh25ojWwh2iA4bqKRYaYf7RIkQmYHR0bsnDkc8BTZlKOrJqzEvs9end1eAv7hQGXslCrmQD75xATd9OgRU8dzwXbvd18eGKzPcZrUq3dxBORlryQpcb8jx1daHV2yqc5zUIiPSQbnxnGRCGhklBXpqu8c5bOf21sGuQ37c02AlkoJFcBDnpCUclVAkPskwdIbYkELowKb2EZ0A4OkhAaKQyzmsRZLSLR4jc9Ptrm9AnrDnkSn48BZla7wsfnA7HRiwqweqIQu2rLE3WOPI4UAJ8w3k0EMd2JVC2K2gnbclUZ2BWCCfm5y0tPW59OmcIuVA2ScWppiwJ4M1kkOE28V8cZeHFPj4M8iqoSJxPvKAW2Xj5TmX54D9', '1557535995', 721, 0.7186, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130313130303131313131303031),
(12, 'yIDMeD298JEZBuAwwSrudli5vSK3LXUzQulo219JftWjLlOltzkxHEB7jxeOCIiPt8pTegEdI5Bwj4o2PaAsARh1u65rQn5WuERf', 'MpwyAzEAdFmAwCefQVlO2wjYqVeWT3GtJpLLPW4xu9G1BWeVtSLsWQVlpkKPEkTA3inSrcSnaupk3aCstGAZg1UCKCEzOtszJ3nQqj25cIuwTfnTRnLoX4fKtMXcjuoqOFKFMizEBPYA6dvbBWkFZ0ZLzPAGdoIafbuowau6nMOwF32mJogQpO5E3JB4taqL4zBZDUMqxD1kCKVoeHyRdtzqTw1j7PuffP7s8wrD5nB1Ylbk7UfLn2q47bMr9lWBPWZMZ1uHZYzzFOO7mZjxXsEzHIXrxJLQKYe1enUEhrU1K8PM0VJcRLgYF8sjj0YW5RR6QCHuXOCkcldk0JxJaXee2qm4r9xXLBQ4PJScY1Hv2qYKnqI8Q0AnKADGYbuMQedVbIpLn7bzfo6380hpTVjoQCibR5OwhJWDVAkea61vPeBegrdzjIqhjxky8Rv8575e2kCyjWekLXugKLwB6pU2akIOLuzChnzGwWhKRFP17wKcDYdvhYKGnZvXM12ZQvr2nrkQKhMzPZoZT2ghQoZcZwEXbpRdMwGgCOJM3K70UjpEwYHXKGAAWXbOWG3j6ojle3xBH6QjlwMcwMvt3SzRie5y6QCiMaijdaHjJkVvbByCUuGSJVVZ1ombBRzaRMFaA9fT9qnzozGVE4faMRE07q0FvKUUiipSk1alXpevYpc5MvbjdEKUAl23LwAv7FxtqLsF6frjV758hPul0lfEr8riqbFZiX2XVn7SCZ20gHl3a1afbT6iEMdqrH7lS4UhMSaWxzZyYaZRp5e2IjkPgkmqQ6XzO49u1ezUP3k03uZw32EGECXceJTiBm8G7WLADtnItp3jvHn43RtdWOUsz2M3JvHFPHKyCAxqvC8ukM8uqxECCRgBic4FgxEwTl8oZA50VJAyxKhMb7dUFMZCoeIaaqZgjRS7Is0sHHqu7AMWjy936A6vS9JxqdGS8e0HQciMSyEj5iF0OSr5UgzhHX9M4RKmkuubjOWZ', '1557536197', -745, 0.0813, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303031313030313130303030313131303131),
(13, 'pTXVG48Z5PqVXBVV5ncHTCmwbi04jTcy7lzIX9bLCfEqw84VtL2WQCBJqFp1Amx0cFzoy5CqyygPuyBMf3e39veQ2UdQfHfjETYX', 'zUqWRJf5RQvxocO2QgeO11nxhXlutYImWABmwMAez0LaVdJUUUADn1V7G2OyGXREHaaDzIkfF2qEO74Clplm7TQzt1DugLnPPB6O0wq88Ws24TLeaMsWeC8UDSRietgSkXpPOcVTZJRhIxQIl3WqIfM6aArZy4wMd86JZKLwcpDpJ3i5VbPLzJQb5cpxgw9Asc9vwb03OXMp8s7jRb4ZP6f8mFKZlRag58zastBrLmjhUIjqa4G5ql3Y11siO4xO6WoHKEzH7Dd22STpRPG3psdE4fytC9jetEz6qIXQQOuEyUQgVs3TMrKftl1xQ7rwee8ntDERXR99sM90mYOBvjFGfjRtpWWGlF4xUrLJpKawIzRBblVcC3Y1pa4inEQJRZnzH8fvgxzLmdV5nApE7FCdWTEZHf6EJb3tSF69tdlUnJnrXJh0ZaFiRuCxpHJsZf7gq7kF5KuUL8cFSJwedw5f8YYZu2K8BcxVlpX33a1LxpoMcC9jPLT5OjFiWf8FC1lrEAVjorVwGyYLTn9hPT3MQxLtLkU60HwRkDgs7Bc9dzVCW0v8bSAmfDexZi2oJh68nz0tdERD6tfmovgRVJvO2C4ty8xySI1hOn6mGyT1nfXYcUnr2tO8bthhwQqBn2kjB3A8wlhg1T1so9SUv6slIcSYRqGwge1dLBrLK13o2psPYhJfnAvpCOQwyTkkvj40k2FhlydoqPh3UiZsBWVmVhbYDdkZ8fvEflhFkYJgc5t9dbByecIczCTh6qIx84jbxwfXFfD1le38UXBwdjTUBRYsVvtWvKuAezB5opVDRg00YyZmzjqt1Wrw8tCfgk3Shvk5usy8K9kJp4I5jalVOVhsHj8qoLZ1HjrZWmAv1V1lerQFqVDfWLuhF11tU6i3uZVJO9ZKEz6PpHk9Vwisuv5Y0BhoLiYYFxLn2PLTG6xbZQduL1lwo63wH4Vb2m2JeY0UCmVT5umpVRsH1nKuGznYMoVREiso9hBi', '1557536587', 227, 0.2879, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303130303130313131313030313031303130),
(14, 'QLzwfI4OCCyjlX6hfBjpE7hVrrAyX3lvZV9vXu4LBJI1n9bs4G4P2Psk7vXGEdC8vX5m07rBYJgAMgEwhEc7Mo1BaqFHKghCoQp6', 'rCbkHBb3zeusRuIiVQWLAeLAeai0FB7Hf0iVPltnJ5HgPcBlq9fOoVgm5YHfjfbcrgOojW8zgOiW9MRgilXHzt70iCtnkLDx0oFJbrbEbpgwRfu3yp0t7UlvUaCnIbsMWoVWpPABsTAWXzvIbmq83cWUSz9furETghw313oq7ejgoMThbbeFlnVadS30DAeSW2w11ay89soseSEGySp41qhjX2kC9BbJ1FURna6HyySvqQMZjrYm4m0k24Z73vussbDz721alxHr1FiarTUvua7dvZ1ujhc4hyLaeLjuvoVgYnbdWcdxiRAZlLpJWXgysPgDHoYG27vWiWr8PoUrtorCzqbSZsIV2W8YzT1LWHsv0q5V5tWe1PF8aYlSnRx9YWncOfqIebOW5K6AHpoTW8hw9nSJ98JghQ0hquexTxwgxYt8HecpfjgMuFLuhhjfZAZfpBofVLBrn3fy5VnPVmBXdQ37Oig63em6LAXPkS4vz1nRQuX6YilXjSGBGcAQtJ6PvsRh7QVraQT2YXSfo6rQLMIZYYhri7epCc9BhG8f7yL4tgbhcLXACz7eBBmVunIS7POOPpIXr820lsRbmkMeReUmC8Oh3vAdYjRTI1Fv9BFMBwVYVK1KrL3m1wCv0vQqdFgQ0u1XeXFseslCQ4C9pbzeMOPCjoswPV4EFQJfG940eh999fApKttZXWoB09ruO2emH4PrwePqBZlyPiWxtDKBrYls4MPla1LX7ahuIbYImyUQSeFyzFp6lSFcviy3UTGoT97qj1tUu0P0i2Mr3AqtBDmOkFGE1CZI30kfgJmX0j816HgdUnQIgirivVb7vfDVAIVXAjCRSvPXgg7R72BRhPTE543smJG0ukTuiLfE8zSHPGlmIzKRFdHT14iFB66WMOeXn7gkKwjmJZWKGZiIruVZkWVLdlUMr9XfQkESKl7U2aX12hctzDuY1HVJds4ttn2qFppi82iiIehaKrs66EqQ5khzzsB4', '1557537164', -364, 0.3382, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130303031313030303030303031303030),
(15, 'SmxATBRzL91bRt7B0yKzwQ2ijjwvFrkqsc4K13MJcW74ko9Ygksble9Tp4PQPixepVWOwm6LZDBQabxeUYwExtDmUFt2m28VJucI', 'oyMFabstoQklVuY16BvHLaw7gC6urWQwEDQrICGZZntljTOf2CKV0xX4y6rVwiRchzg6DVinYM0d5a0mmvn1CLJUds9eZveJho5DX6gDj5UYejzl3gnZBTUBfFfqPA0aE5g3B9CL2fbAKkwc7TJPYTrbELHt1x8spEPkE5lM8hP6DeQXyouxHKmCrKxqBnDCx6Kt5TsGAcRsU0xxmMB8PuEWBBKey6wF2q3vTyXrrZgIyEB2y26Bi6ja8klVTFMAVCJp47M5FD2Qzb4n8aYWaAme3XjtA8qoaGOcBx1BgbbQYzTC4bdapYLbkpEVFtr4OCeRxRCZeAHHJQ5In3Qf1cz1ZKme8GPBOr2nQ2BgzTBsSZEH4PQd0kJI1ZspYLA2b9dMv5Woi3T5o1Bz8rc4mjhiq5VtaIIkXIL4y1Gpo5xAiVXizWWM6bcJd4KpKyeu4aHdZPMiS0yWyGCUok4ndVu4nUYeHh7xyt1fMug4IMYdckHozAyQHx9hUDyU2RnsrFH9Y38HXrJkdR9K9Iqby2clPewtJj1gGJKXvtmdxZUkBfYZ5IFpOoBj6HRUPE1XkGcArMWBvpqcnwa6pBiupDp8K4zdhSptkv07JWXSRGkWwFJ56misoKzQMiEp7WaUHcbwp1i1zRAz3GGXa0EjLJ7pco8sjUjcsLJOsX12FTf5XA1FBvp1vB2SZmYpUJPmAdFYTJ8V9OhrdmHhpTwCBlkc9dbdRsHp5wZZGqBGZAFHR1MKB9156YZoFXLUb2YkYIEURZskdgsPSwe7ahUqYs2tAxJsTuA8dOIFppGQOMBPgX3l7h8DcPrqS14UYQBORJ9kkHieMd8G2cgsqaKJP4ffwmMdq30lRyYSDThu8u2rblPr7VKHObpWzASog8KLef9gjXCCREj4GnLiby8xaaWwZGlss5T4ZPHxmSmDWGYzAg62C4SgU2SZKFbo3Voe7gDHMFsxpBZXR3ODrrZR1L9jVwod0DihBAXJAlXi', '1557535928', -518, 0.2322, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303030303131303131303130303131),
(16, 'uGS8CHukuoPvsfZTkdxcuMCDKUOXu4ajvdjucQmFmTSAmRWs3Fb0JRFqjk2s5AjjVB9I8QBTAfhxDkhT71cEnM75eDCQ31QbFTlP', 'rIdZdu4mjF0czezdnBVBwPB7oiJXP2VO9tdWcBf4lU5opjlCKj61dSYf7s1yl3SFd7AMyBMDK0xrCgtVvTEigOGgdvF4eWbpDCkvisH6xYooc6Z6DkArGBO9GpHqvIT1s0r6pdZqGPBc9PS98DUtthhVxc6G9nWuEgWzUPECexcTuo841QAnEQ8yKSSOaTpRdoPVKjHH899rcRLRgUDadgm4mp2Oyie5ao480G7EqCuThcMwTR4P8zYskPyFkyqcthGeBVUt5ZdcIoa5UFTlqKWIF6sqtH0ba2FcA25b7cinyuXuhm4K6OiSogJ3ZJW2eE32W2CKwiKrLr4M2XC29I2TujnyTChLFaMKGUxdjhBnlhzY9nybzx8LYdpV9pYnuyVlODPxs8PciZs1EGSdndBxO0ObM33SFOpOiguJ0RoTDzIXxTx8yLtb2FAiPzudfXh9aJxPUsmrl2mIMYBU6cHGCdJidYjsbWwno7WLcXHSqnmopU2y2ui5BCgaYfvyuQ9s0mJBRhpbSzKWqIQ5kFhlWUaV7o5xbA8q0tViTvvnHFvmOp2u0JDtF4rxDp2pfdvhmssTiBYrVCEEyZAL3EmuL763wjm8GIf06knk5AOnusaQFqvXtstoe17pO53Jv7nAd4EEfq1bra3TbKPYh9W95OwFrI8eHmS3GGkSLaBSMKjO4WvSsGOMjtiMsfzAguJoybnXGKzqudXAj1yD082jU1rMREoPcvZBMxMTYeVSzyWgXW0iXqDGSqYECVAXwnBHpMzICACb1KlOWLOQeBCWdISpL4aVd9AFoUKqEOImRR6ektZeUEY6WS92h67LhLYwKTi04Vbq4Oew53xwWAH72VOxbZrvIhHeuKdrRT1mDDJHcutFnoO0vPQVrK97wEQPBuuL1JebAlCJHOMHb4hLmCea6pdAIVki67aZxsPSXXTFA0sBlC9pzh0h7XEWi3cDWBd3s4MqDowsQ4woU3nVbPahvkube3rRcYC0', '1557536881', -233, 0.9701, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313031303131313130313131303031313031),
(17, 'IJx8s1W3PmYj9eGahBGixX4WOdpQoTQaaXVFsQLz8xWzuwAUpKgheG4VMkAxq7Xm02G6RwWZOAjIdGSwXLd8ikqK9j87QdoqdZPo', 'A6vgRw2JjIv2PFwSJQbtTb3zCcemMPkzIxrphk9CMDxp6retydi40XkTM3raKwdBeRJr50CnDqWEJ5iYJtMxux06kL2R57tw63qlfyt1R5ILKBKkjBETm23bem0pMz7km8u8OZHxrCSL91zyfBU6Aos8vQlRSV80Z4VMIhjXq2oEVhLEzuwccDfWbc3ak7vxZTIj1sicLkio4qlDgfwacKqEdq9l9dhYmzUIHwDkuuz1ArivkTT0yKYeCwBpmapg79s0KrnlAwewtlCfLoDIiCTGourlX0VqfAoabfte4rfUJ7jRzLKjpma1ylEaUHOtKVHbYXW0UeE9oLokL2fMTYQd64fRei4oC7o69uPD8TqgpiQGka77KsTi0FdpXKHcTbrSHV3aIqzgOGEVhamlZQifi9xQ15HSv7TwCdDxGQ79zYR2A3ZqB454Wug9ti6pvXG4VoCO381TH7q1hOZoAbgLZIllinRQTDSsArZWLihve8nSlrlfWbOloPPpvl08DdqJDnHYRkX182HBMW6YG3IObOEl5bviLEmU4bPRkfYooOodBkdyOM08kES93TolhYFXSRiCb2mD2rtHMAH1ipFkSnsQntEg9alQ3p9goG9K3YV3mIzm9UIpLZqo5Xh4pepBAQnL0eiKrmJiiIPAog8m4sKQagiJ2bQgw9ZaYDPDdDXoBBrF0vVbIOt9CtGh20DOPkYqjXInmMvnjmrDZC6TK2ykryrHpGQdunjz2600TOsfnZPulBDsa82oEwz0agouxj3A88EvLHMYOuyc5tyVW6Skem5aiHkDY79tB3FT3tuzCTFOcdQf6W59c4YdO1CFLMCesQ58G8y4P8agGQvrDGFQwEe8FdjzWluSFuRfHE0qng3BxkywyhCoe7SXXimmuLIog20f63QEkhiPMGYtQKYQjrTByeO1q5jMfrw8Sk2LDaUVoXKiu7G9LEg9y3BxIgi3AJqS1tBKkVUTn3X0wkLkAJ2zXKMWojEb', '1557536020', 489, 0.5516, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130303131313030303031313130313030),
(18, 'wuyBoxhIK2tAXreoOHaSGjlerencpXm0qoSlQ31ruUo2Ip5knxF2PKhnS2u5TRnnGazWEr82ADFmTgi8lfy5k5ApFIYRIDMCkODq', 'QGDv5glypZTPFQP0chhjQhPuWiyJlk6MpPvRWKoDkAQnnisOslk6oH30xQIJJIV1lQK4b7OAB4bPsCtt5iKKj0EovffCv078EHmaOmAqgpU8VQR156zhCbDESx9mE9G7ltm8MtL7iDZjJVBrsOKGifZOAHqZbaDYp6JY9tjHHJrnWTKJdnjYlaIPFJ4u44WHRBtGTke9uIhjwIgUlPf8LYPH9E6SlQEjFZBh05vtEyu8uq9WR8y9zEit0ru7ZuJOSf6KtGbGbi5PP1pSIke4Jca7d7he01baqnY6lbeK6T3nwt3FZoiQiDoCPDqeop0omndjAxDHnmoPBO3kBlIudXZ1M4W7aFcuGgQpcMqx2I6841rTBaw2w7Yh8lRRjPLtn1PnbUBf5WcjU6ciZRHqcakqRv8tPRIlrEcdxU9Pt3En64lAJqgHf63qWxMZIK35TaXXhL4gg1ujGURLSScSFUakqsOmZwJGGx4wovlAqSH7DBJPmbvUszD5hfdBCaPaTOyZT71OYAiOYc0JfncOD8uIuVZIEGgwsXqkJB4SScgmFECwusfAcyIf6r8I355KoXFyZZtP9FBOKZDc8oGf7SkD4SEBOmhSHPiDAdgEP1j7dc2K8duLp3jUp9ylWvRRozhBzlrmRfpi3hMavVFb56E28jQYtwOHsdEsWkZXglSmffVsgtes92o3elutmq8rUIobFcUo2kHiQ5qDoVaByQuXHgwRDcQ3I6wLMXbIcbV7MMjGTftDmvYHx3V6hRUxUm1ehyRVJUvO7nzBLr9xx4QlLIGdimlTtuTz93U0DvtmPQdo1vdk5u4RmgRdGLb8pu8MnpjWXZPOUae4EsDZ1MEfkFn6s2neJnKTZE6LAkw7mnBCEgsvjYDvGWhQBbWdq8KRZLhtCyCicsn22YDVZ20Ep7ys7dT5uL7HlKP32E5moqvkMxcc2WIFvacY16dOXhSp5CJvPCViZg1vVZ8lsKQyY4elhTVpJEZ0cm1Q', '1557537348', -352, 0.9769, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313030313131313031313031303031303131),
(19, 'XYUxpiqngrjkPRCAXwZUXVttFZG2vdIMgyatiu7ir0aY2wpHW3rgu3lPxtJ7pOGmY1Ogxyb4ZqotD4yHlrgur3A2LQ94Hh1M3lPX', 'bvBIVI0SBt5A7IsBKXd8o5XTmDJ6vyctbkpfdUZ8WKZkfS2ArGd6nc7AoRPilDWUy1AETWkgFVgWLTZrvkzXJbEaOWilxB6cjA9XXT4hLYVsEMibWPkEt3zCAX8h8rBnr256mGabfSXQXy0MLdrfAMRWKMl659upXlo8amDX6El5zd5gWsXI5pw9hvXMpJKlPx52kVuzjk7cAIwCwAO4XUzec7Ul7co84C8OTlI6VSgcZ8lRsB3hbgZbtAeMcwoOHyzsOEktThO5KoxYLuFnMvL08XW6EJMlHnn07QjKeyGPUx7WtfFlLCWHaa2huPxL55yoMTFTWIYsqz4OxS2b8CuhzgvlGMF4QD7GQPoU3LCWjsoxYnMUStpJmflhhCceY53QgCvMwFEkzf59MLUuZeG4w5y5ek5hspmS4iZymt3zeTaDZ1oYtQmg3P9LyVlclB2LeRQcA8QHfpB0x9gilkplYp7lgnY0AF6yMh4HbFZGDOqeuavwzHPifTrLlHZFdCwdHAF695vzp5CkO28BbXB8Ufa5OVnderkJ1LEmvnpjxecjuO8zb3MPXsfhD08DB8w9GP0vexGW4f9byquqx3kplzHkQYgXmH5qJJJwkzkrY9tV0Xf9hVfR8xygqOL6t90zaxQpMumPeVbwPjmJoEwbioL5nvE9ZsjBWejbDhL4Syf00zRcSgcnQ7mLH6V4SE0v8MaPSXxcT5GmzHJxJKfsJIjkpyyS7I3iGdokstGbhuwAvIYKY8Ep1cELuTzxJFuWBv0IqTd43KIHPAARAmrfGxn5W6W5KuitUGZZLb7OcUiGvlAPzuCWILsgMbIv8btTAJl7ulorIXexzZYFXtaw8SVkZ9ROTK2aDF48An3XBPyh1uHnFl5YURLgzZmY0cYk3tb24i4jTAgTQSPZM5mi4HZ4wGf1vwhlRaEMV5tywfkm28krhH2vBqyKRhvXoHWg2Hvq8JfGxLMIAgcM8c5zv1wkyJ9JDM12z9JW', '1557536862', -756, 0.2459, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030303030303030313131303031313130),
(20, 'XaBYwgr0nyuwMvSKD49pgIrGvrlkHGXyHrO4R936ZOhmsRz46hxWhxgeOCkB3ZQjRAn3xU34YVs4u5FgXminEfrCtFFJL96XmBkV', 'BxqUkU0DUb8j8krFpO0UwBpKSbKqgvDD33aC4LV5G9YgIaWQwfX4WpvDl6MOwhlfRqhdbvcpQ0b4FSQT2ze6K5ZpbTb3aVpJ3GMGF8SCnILK0s6OVLV0XDQ3pxYbbrS6CPE2wCVGhkJjHVJBaQZLt44y057bzQGkyPUfLZkEzO5KMfJhMMpqpnFWZuD3l7TrSHwlne7te9M4fs8PMBdYHyEdkMxOugsqysvjnlibgnTf5xTfbionnB1m3WPq1hphC6T9JkQKFtljiv1xVSWEqxJn9ZtVUbJ14BCStcKdssbfSkxH3jTORlRgBUuibWqCTZKszW2xBjo4P3qKyCcQE1k2sGUxPBv64ffX4yHJ92ZJ9CGFqPTJQzbFGlFFQ8WsDn7hX3KP4DWjS6jtGTXwn0pbhTPFewLGznmuapaLl7iJXqk9jQnbii1zfilx0OYOUgZzMEWA0s03oDHGjEbHBt0QAAfi9WxMA1YyLL8i2G6feIt7Glm7hxlYjKwVEYuDEElo8LFSrMyirGBprVVoks5ZpMbpySPn6957SCAkeKof1v7zzmRxKgbTTHdMPDvZUxdHZnSEoBB3Ye0C5GazyWEDJuB2shAt6MHatZxRVlcJjOgxWSQtIuvhW9nauO2QEVzvktAXQXai1hUldWUghXJOyGxaTcS4BXPJzR0T7pvJ6BV0QTkVcelbw642Dt4aVPrPb5MHLLd3xPiyQH8rvpksSoYMMCD9BzqMacYpOZjenU4YdpkRbsGAAyfpjDz1FcODwcvZd6LiARcgYYT8eopBGATUcxUJ7Hxlg4qr04BeaGHr6pPiEcwuavVhtjBmX6FWnOHLaVP37pAuBJ7jrS0g0ijw7YFQ7lapSqnYGDpIsZRptXOeCqRUeW6E8u8cGt2KIUq3BfniarucJ0R0bR5pPufEwTWqCuhYYhQ0TIHIfMuSmWiE6aGOOULwia9xXmU4zwCPx4q2G0TqmL6colF49cFhriIwD8U2yDOw', '1557536564', -722, 0.3587, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030313131303030313131313131),
(21, 'w5DQJshA5o1dSmWUWkFnHKgSXCl6ZoZhJ2M8u2QS8kKeYoBoReZ78g1AFugyLnPejSijCtL2x8R7qjCL70GIWD8bLexTXe22gAbm', '8M54lOkSh621LDKc9UCEgRd5tWCIBarh0ZLYwmbwvLO9MadyH2u08lganxAhjC54g3PK4Mp26iW9by2OE3JdmHF7E1VIoY5JT0fp061q4It1WQeUYVmjZWsWknD2QbtiTP4Xig0Gp0nL5ZOTEFmhY4DDmBIdFgeHgvflYkmP8aEoB0KKIjI7k3beLHchTdm015OC1f5QecjTuU5taPtQ4V6FxF2ds3Tb9wJLr3cIH7lgLFL5ZcAqbEn0Hwf2qLLdER3OfJFuyUJvpkRzas5UEh3cffQIKl19w2IHqiw8LzvDqRiXJAWfwL6h9RMhsOEXM7MuYIKEn6FDPf7aFAcsK8verk8Hx9FBp3d9U1m2lwcvAvjhZtPynni46FR10m39pS1FccliGO6gJETgFePwmusL8UXdPrPzMzc5SfGrpYnTgGQ7JSbmIu1lx0oh2oWSx8KmVbqsv11n9AaRbnX5slVMkZfdBes3FzGvlZwlZV3KpmRs0K3Fz6d7tQs1zWl5bU0x9F07PHr040XXc1x84HTk1y3HUwB136GskdRK3ne85wniK9ptVcXoVa0gBZfOjaJeSD5gDVn8tVcwG9EHaylldDlHGkgtX7bTMWGECkU0fcpD12hMLO8bSZ419xD1XXZp68FVYBOKnlZCHMhKKViTUd9cYCprjCaPLb24GL5nUmVtLqDB7VRsjjBgbzxJ4cI6P7K5MPJSOgfddXokRMKU6hrcKp3UcDEgfVSYfIKf42WP1jvVYw3eg8E1I8XWHWYi3AlI6vauHG1jdz0ns8IrMSfH3HcSz9Dcd9cmkbXCIctFMHTIkCLvHsdgKaQFPdHYLzqTVI5C7BiUIH8Xy0btZXyGQvQlsa8CGT2hT8CuTSu02AJ2aeYiDig0iIeTsZWa041xepwf214ZIlJ0al80Fvmc7OZjQF8yF7mFWzMSy31RMZ7RwlGz5BPgkK8BAfGRI36G3CrmrXkzetRygdA2SAEcUADLIGC09Rcz', '1557536454', -250, 0.3152, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303031313130303031303131303131313131),
(22, 'II2c3SYanWTm2rS0SjwPd1V2XwFlnjSZmm6Fe7tCRzyyyasGcTMJ6cBX75wZAZE7nTy2OflYI4BDtLqfUlqxlhFIFvKucwO7Lhng', 'JgAbWq1AKfLGZGqdZd6nAOmTaXkZxyzn49chzFOppAt0rUPKZ2UUTZl9veeJGH9mKUcfyMY7rPzbgZzbmJ5jz3HienvmcI6dPwz5VLwGRV2ftXHt7iDACYqjkq9R6CqWg2jOEDq9DUSb3LeDfJzJ3LxcOkbemo7y4qroLnItOJ501t7GJ4TLQs1YD8At03c2gFXSg0oFktFGl4mBCgzF10SBSMmB1yDoPOOd7urKf4Df3w0pSkCsyr67skvBpYsDLP3qmRRHwxZF8S15vh47uJHvrJ2tbeEJ5GFwY6DwbUGZA4oCv6SDMVGLM2XekneILsEuWdOee8Mbpaa3TM33sY2VvcdRRpbAQ52kjcmODeffC7ilDmBkvULVBeSlJivjhAL334ggpc5bcWOvLOxuXHSP49TI14cV6YUDaOyAz3iZaEGyg7RvJnlzVXiYEIhpheo7EqeM7LTFufWt9jwqVXcd9A46FfILRmgrwVhS1nRecHAhonAcsmqJJ8e64Dx0MnvFKhGPiRbFh3BW2k1RoF28HxKYQVK76f8KmwtDYcUZJfZu29PoGR1o3QEIZ4k6O07ImDDl0qZazlKVpQ1MmUnwL0Vlu5gWSDuzIDcVpwseLiTdapz4pQ6xS2zQoZAGi9eisu6ncviam8oniRueQDdqlWBdEKii7wmTzfoHlmvZjQhqMbOgDjGccJ0siomLjMRl3R4UT56FDqxlFmuaPSxQpoMAkVO8SVIGVl7ZMG4elTb9VrxXmiLl1XXAIkDmPVYV9IwX5aoFqebPynZAiBnJZlsstAQt8OA0LWjLJv7ZTqzmycM8ALl0kDmdCJpsPyAYK4tsLJcaIwkLXUYxgQH93ODQ9LmjTcWP7423bQFeVtt5GswPjKra9Qik2EF3kHHwRXXuYOvavjZfOUsYJyx3CKjHjqnE95P8YFeP7EIYs1SijeL0xf1PsxIWW5r9kljAshU2EnjEMB8dcqrUHOSsGcu5YBUvUtbXjLW6', '1557536531', 660, 0.1155, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131313031313030313031313030),
(23, 'u4K0ruvGge6YhJD5m0IJQtq9y9m3RsBEzpLF4rXlbwHmg9aW8hVQ9m3fan9TvPkY2Bae5gKSuHGCBr4HhquPQ73d9vjAx2p9SHVD', 'sWXhaK3LkBlkMrrGUKp3vuSaW8Sd4E3XdwuydGLLqD0PGlLplgaLfmLBJ7I9Euz7kYqHDuSFUy2cW7s2aDhmm64XUYXYBcsaQhIJrbmqJlqrBKxvmULQRIJ9qGwEXMH5ItpDBId4Y0czChZSV2DbHdMdlitdDflSYxtqa9rAyxmz1FO6R2ToWzcaCLPEIAmxAuU55s3ZwWTrMW0dbVvuyPZ0h7xYbMJ6BjHBnD1fTfMcV6zcSFvsyX9HjlC91SvvZ0T14GnnBp4Pr7w3XjSiVVGhIr5ddQDOJzri7C7oGrHjk1RMnOC1EMBJvqX9OF9ZR1nsxqdhamJGBMxobcJBKwU3Fg9WKn22mlGtk6G3198XfrCSnre5f9zgc0ID5YiWfwnovExGeOV4gY4eWz6q7DBl7AGcMqXJuBqa45LcQl44EmTtTAlDl02io42DSKWp7xSPZonAOKAXqD6zctYJYfP73qJWkYkY7mFmhzmR93uGzMEyTeYHWmZP5DQ8a36nv4RKWCI0SdLj6OBqWRkxjlwouKicm1eFfCp20yr1YfqOZHX9om5g3drRhI88WRJRn4lcqmxUrarbftDKdKcRaWJbrzlWUyCTToEee22FiWRqU7Hfo0GjDzpnZiXDe9TPLAk8pATjvCCyVD9BY8yEv4rsTUUcXBwB1EoVW17P69Lyj2ZQU9OTKqSpanfD1XwhDBPzTjId5ziq5jbWe2qYmFEeQIWWt9VPDqD6buGtqRcbdsKXVMqXlMPXSW38jeFf17PvRy3B91tOJtHMZpOMHMmvh3vcvcPxLGnMUtMCf38iDn1wqVxvrDhY32l862kIU8jXkhTwIYaFU9I8eiE6yozidTyX3JdKprBY8YmhyKyVxOMBqyay30fuKB9CnktGhDiSjvdVMql3ykfYZG2UUuhzEc7c5M6txHlERWrrnWu3WI4cXHh79SHwWFsCa779aEMjMf3Pln1VIZgjfzTdK6ulB2aXCkvGatAQ5q26', '1557536796', 6, 0.7596, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131313031313031313130313031303030),
(24, 'S8QiXlTbJdE3Dgg8spg7xaLfKtoeqPcioaM90Yg27dcC3mIbEnopiJkwOp7fvRQMh47Trt0JQ575Qky7fdUzqbgFedd8ZLSayQOu', 'gR7kWPppZbLXcVMCXvzH2THUQyhpctTZr7COrq5BwUmCwv3xOGgCcryx3e3xd0kl1fu9jV7GqvkbeYGl4LjoKSM3ELcxBo9zWfJmxixDIZFCjiH1GHJ3FborCbIpnFlFg8msawktnknXLv5yGwyzZmmHYsCawPVEYTlq9Euapyt7BARZ4eJZEpIRGCUM2QSw2wIgvD2KPEXbOyZhPMigHlsSMFyhXJcfs2sZfvWcBDL7oourWeeq89yKgzzEcvTShpAzmffwLuZVl6nusyxsXP2w7mZUQaYltF53QSVIidzBFGDpkKdm6nTak2K2RGpH2OWoHmWOdPxbn9hdAPh8EO7FVzU2f5eXZOcBXInKuiSBstiTdLHMz7I4UZrU1lq3iGPHyYaA9DAVVGFqdAvkShHkfglEau02ZrOFx5khbSF7KLrRAhHIyl4sYqBhGwWT35bvU4SSAY9aYJz9lRg1BgMt4tgLzqhCuAVeDXMjnXZ6xz5jtiba24Tnxni9RcZejY3PKF5DxMcVuhYmZBucPKn8naGouQ3HuexifiKR4wMBPSehROb60jeLBQtwvmu44mpC6MMVZ7KaxkS57SeTyJsicnCwUKkj0mERl9dSgA5BBESKJPFxt24FaM9oF2wpjfhXWo0HVWOV4SgiJDt4Ld2Ww439Pb6o00gUXvapWaT6UW1I7kEtrgo5fekLkc3g4DDKiuHZmhma7Va1SUdKuc86lhZge6mZv8nt2mCq9fc6GKFb0l9UV0eZOb0DuS4Akwv497VKj6pUDsyevFsXIGHKEYpT8w85wL0wDIAYQP0AZ3P9nR8QUeyoSDb1a2Ar5USSvdC2KqWaGvrWDXcCrEMUtbk1yrpF1V76Jz3Z2UiALQsCgSChnYoirARTjHBMlOJblPQPGf1Ud3RagGrOF9nyMTKDsRbL2yJ9lX0wJt6638BADoCdlcJHv22gZT8C6b60HXx69zy9g6JToWbuo8sIB5GLSLsmxGRHrOsy', '1557537248', -210, 0.2474, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313030313030303031303030303130303130),
(25, 'QXf3wo7EPXyB50I89y9Yl5YjyxKT5oCUMD862IpFCB3nXM7oMcerxksL29q5C8dA8eo1UV6AOaU19rTvOIFO7sk7UDsawIa9QG2P', 'aZamlA8wKZ3vc7u23tzk81T7OcvAV13tMXA1hUJVIoznYoG9mmcqKfFXtyeUmeq2MKoyz5Hb4Gt87xg837coJmQDvMj5cjcrarzWf84jMRKKCydZ7Jye6mndVTL9phkKV18ei4OkTTogwsxIyfjWQeiFHRB5Z7QV3s4oISUemOqCMeeknCqxWYA0RHQUXPIYxLnqwxnZcAPTrTjPyTV1rAgcoqpzhpZTqY4kG6eCqfB0soKb81Mmi4ihi2n9ZSCFF276fws91MK0ROzp422zxrIeAvIz4cDljZyKaP4wZchSC4LvoUEF9Gv3fRqTvp1UjOmit03MlubCKdlu5FED8OFKh5w5luLjGuxH94pX4Esfhfim9i1tuMdkGbZ8ysVBr46ZcZ8WaG7Ka8C5AOLceE8MtaP58iqMzv28CMeQCB87rUkHobTMloq7C12T50jQ4QlaqtIBtoxn5yobArngQ16jaJCzqAzKW114A1zfG3ju65Qx9zfBHv8o4lA883dxc65R9sOKiAsuutFL6zuPXSylmPXzdnddQ2vv4Kp9g0ZmgKSTps7Ux7la1aDTFABLQRj2mXnpBiT7pUrS6d7TxevS3oJ4uFmbdyvr3ZJyksaJXVoIaRtIUd3rsuc8HDvtY74I6VtzquPfPPHsBmerD5YUfs24ht1E6yZSwIzsUpRB5Ap4qJl2JPgepjfTfbUHATiUjo3dKcfSJetxB0QuerXqX3QyzLaCt5ZOuWURYR1ZKKXUb8IQ6XYvRDO8heMpI92A3n8nzobZ9aK978Y4kios879ymyO5m6tfYGJLxOHRVqWfq1z9WxbiMtRSPLcCmVhLgSI2T6BB3zwe8Lz7XElZPGW4DRW3JBsbXV5aBgTezBt6cpWYiETzeMp7RP5lub1sZRObHiwJtuMPCVGF2vO11Lf4qEAwCCWCpEU4bdy6JguqriOh9g6lbCsSomty7XgDdkoQ10WmnVzVDyjJDSLxHl3yIWJu08WyoTft', '1557535887', 12, 0.5789, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303031313130313130303030313031303031),
(26, 'or1hcGb5umOCCW17qpnhfc0kXjt0QcTtMQQv9GqiJIezUqlyvJoWT9qZSC5nPBply72Csz2olY1pyL4SYWLuTYfwaM3DaUj6HgBB', '9k2mk5b7A093M2xVgEqVQRpMT4AIehysdYpcG5IG06C700Fd1eZcTL9OZ6fe7bTcEs9VqWD8M5s3zQbo8FVmjzfGr1gAoWzOtRhvxGXsWVFSxx4qD0do7gIsiOFR2AEhE6LZ2iBFuEgxS8kmwbUiiPz6wsrY376DeeDkTMDJofe7zAY9LgY5QfOB70AYrvVSafTx8a4GFIyxEVZPocoJLxp05p8QdM7Zt8vDJoRwl5hR78mmp1cg4IogqH2AmXGYaTuBIv1enim3Xd7MMInFJLKp9SidSWDPevSr6vyOMpQ79bg5xhXWMHtpfUWILRYyF1BaQntfynF3I0LfEIS6dvzjIPZ52CFaupJKX7LzIeTRGIEia3b81b44zBnlFhJEGEeeqJrMgWtx1iVd3fS2bJVHMhasGOb1fM6zietRayr6ILy1ijVPJa9eoOjs5c1fcOlMwAUPs2LxO6yGVgmtEtKCmeQkRtdlvGYT9QGD7nuRgjWeX5a0YEITHvJ50CMkcrWR8WRl9Bz25oHEjLlpDH51qF1HwDIcg4kGuXoVyH26imQW4lUGGDO2wHEdpx3VHz4peOjnlGT2Sbm7bMQQ7rVV0CGzGjKxvWc0lxBHux6RQUfaG69SV7oGQp6QkWP1HdGtPahU2gGxatv5ziPM5Ffk45SWlthnhlyOGEjZXRD6SX8TPmTyD6tQEB1WJS6BdmO2X1JXelZwWh9yrjjdyp5eD2xQv9iIweq7xgwKTGHQpux6r88JRA4uZjrzEiSHd0p5wnGsVVM2eziwQPj9xDpDHtIcajPyhCMXTme2k1f6rwqPzoSqAy9EOvnH4d8iI8xECe9u7Z622mXZHQOA1nfxgqo5kZQUxvEfJYrPgQjQZ5P2da6CO3Jj7dOkYDUnJL9HeA71OyTwjE5W6lMwZBAWlTzr0amJiU135596IaR517IKlqRix2PsXqJroybZeUggkrz30Dcw6sJqYmhWskqRUQgk9Pn5yMTmXGmS', '1557536715', 672, 0.7542, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313030313031313131303031313031313131),
(27, 'yF7YYb5uKvo7f7a4iYW4fxTkVOwzGd01oKTolTgTqzKgYhqGP0UXjbfbhO496js5AH1G6rPbtutg4k5cHUeEKG0T1EZBTii1bxwR', 'eTKkUiAaxe7zZFVgy47u8phX39vQ8gpUJd4mHZ4Vo1vPCj0KKkBWC1W8zS6wsQFPBpKgTwVyBGiXDQr7jstiuvZdut45aijCStO3qY95derX2eglgsIvITpaLWpvfDjiuqfHmgKtbDYPOvsszllBk7cZqi7PHRHQuf3eErJJwVSyWE2rg6lzkemGswd1xXsgSXeDku5Sf59bsFZikJHpGeUgSCF5JTByCvMVnqPTl8OGmzj2Lfs8q6PIEAv1kI7IKWI4OeVLP2P4Cl1DACzIxQ73PrIPhr0Lgg26BUpxEPejh057LT4c1rMflbjvB1gG8sH0MsgbTu0qiwwtl1XxTXPkgLh4jtUuowLMkTuGt29qGVmHh1bK7jfhxfCvoPU91tcrgc65srFjsbyPAUORJx27cBkPR2iH1i0Yyn4lOIz3Ak8OiEOPIFcOfPq0G737oZcneqquwTRF7m4EmiaE5EJoDXT4T4bq9yKEhm9vCXvb0gooMOVnPwEQqUI0tUHAh0FPHago5Qxyh260Bb2YXgWaAKXPqCADMkZQvQJaXDXOVFauOqwrqTCm8twvKcRyEvFKFoAOaiHVXcCRmzoMhnEr25u4sEtlVAIwePPjKQSVkAr5jzD0wJ5ojyQvx0u1xwab97qHIfoO6SDbCsg58ZSeZUxP0dTzxlYIsipY4xixf1dajdg3762X18D0QiDZV3978mK6MHzaL2a2nQDUt5zvqe642fLhFBHobhu7TJdFEXtKPlnCdWuWddX0C5hsO3DyB5A1mEf3VHbnDJudkGMhm49OzOavjnWApL5LdrDizmfRPZ0FPjsuUMJuUnqqbzCuzkXpq6qpASHdo7S1GOuyOnH3BQ4drDGh8KaX2DzpZhwrk87fVaVv6R2uGb5T4A7V33Lj036iKxIyD1IkwpHlKdKO9osr4pXsmeJAll02TGixkLIiwwS3MrQZZteRr67S2h6I4vhEpIfooo69TvpCcxj3bqm9cFF95dPJ', '1557535729', -232, 0.7733, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130303031313030303130),
(28, 'jBz8QUQRCnk4Zv9ZLgSkk7Biv1XCDsWxzogJEhWsJ7Co8mmOIZKnQqUkiGpotfmMd2ldRxsVdJiBF5Wu3y1iHCAetfg2HU8UeyMz', 'pFkg5ekFzGV3K1E5YGE12FuxirhUCWBPmGztjAKDSafuQmEKAD5FWZ6XhROMoeOVFybzXQxswvYOiy3iAsTcfa5cC9HwxnnUmkbxVWHayJ3Z8EOIY94BVdqlljZ94okLqWynhWfJYQw3kBW1IICTZ9amrlDEWiEuSsi61OacKPmZVrscRay2oWgfUgF2e4l6FQqG8yswVFzMS9lemuS4cCK1K34hSIqAS6VaCa8IroatcJBaeFyYnbBEZHQoTeSWreMvtEaOm072UcfWuKBKVBQazf0ohDHbne2II2AKDtstZxfC7G3pRVryxEwh3UUiG7EPkgnziPbMrJDa7vRX96pPTWq1c3thnSDMjnxhk3gYhQoAud2lP9LWB7HDH5p8rv1CFn5RJ9I2tMwTfLACS4uYH9l9BYJST1Klpf0jw7zY4C34ndwMiSBSb4nwSJrtHoTXwZiDGYMM1kX6SxQP6y5C2RLLvovWUEnp1AYQdHntlVc2KJvIh7XgfvyTwVYjsMfKS50V8ik23nPP0OzuPxaMR3HTVjMxoMuY7sqSpLFt8IQuDK09KQLaPseLGAZEIF74IGdG48oMAVd2DzOG31KraK8vQJyDpq62IPno6ltYq1Zs1g05I56zTVp8mKvut4tS5OVYvrX2CY7KLQymL0QAZW4DfEPeVzdAPFQqiqLYdOCVUhuwcOXtsS51wqwQIWlbVp8Ksh0LavvYoAMy0uqfiEuga4AkVdQDp2OW00zsu6LThMtsa2hTwjgnbA3GtlHZhwQ2UBx2dypGwRwfItvo7Rpnz0SVqlWdvTgZb5TshUqmaOYUDL7M6gWglg41Jezi883ORqALJ6OUaCLqWW53ryR0upD0qZzg7fdvTEGYzczkxjWQC0rcaI7C0rASuCX7teK6iK91M9HCiTv7FXadgKL8UkVAX8GQd6Fx4JZWmZdMqkrg6Jh6JFOva6BdKvOqkQYSezcLjG6QVEKiUpKSzscKOKGGXKiTOsD4', '1557536932', -698, 0.6361, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303031303031303031303130303030313030),
(29, 'EhmKOQrc4YBvO7ZSQh83vUaeFWF9FUK1mJ0y3VuZCoQ1oE8SeFWhrUprVj66Wn6sr50eGRVDxHrpm5EKZW9oKM2xwyTXCJOLThoL', 'GFJaRTqFImyu86Insx2vvF3CEYUWIn9c4nVzwXLOrwQ7E7FewaomSEAd44m1XkiuPXtRzSvPwyuCx10YWF94BwvER2cWvaOEWnp00FBI0tv0PMGzL4gEIhOZ0TpKsSGHrHI2Ml6tRgVfsqL3YjK8dTtcxB0rOsWCkUoWYUW74XGntWdpwrCt4nvgrdY1vVAqzYsIwkbDFsQmSl2EtsSGjJXdJGjrAfA6dVTnrCM1DTmfDCfKMluMVZI3o21K2sZDdJGUJOKiZagZMLPJt6uKU6TKqg7WSxJ4AqSjpS7qHkxCiMKAxIRAh6qkQmz05vSml0qAtMQrOmc7cG5kZeBj1YlLClpXElowtrmKTAWkhhdussMXOBIU7HD6LcCKB3hzYKFMGhq684CJ77RqZSdnBjjjjVdrWDwuRWmGSQhJlJoS8DjMy05ItOlnewb0E6ai61pspgvfXgyRw281u1kXHbLkv0wrJqbYIYR7ly7DVG5Jijk8OTW2kpyaaleKbDyvJMEEDJ6UgYZtqsU7uEW0jwISczjX1IkX7tQ3jMr3Z8g7WtRYyhjQFwgrBFM0eGseS3olmIb45bUBQnaH0M4ypobUoDCXOwYoZukuMwhWy5XZ79SjPab9w8tdyuQJKeRruPDwAcLHoSkeKMXM1qFC0K9q5dqq6P7mn0jqLKCmCx7mLjo9zyyWSebv0Po0OhKaC5ndjbRSd5glaHdnwyMb6BBshiIqTBLPf1OSfusgbuMeXZpuQrpgIRohXErJlP9ngQCoxFqwxLGY58ZtwcpeHYyZYSwXaUVMDxOOdIMEgXYBB9XkAQM54W6ynY0ZnS35o6m5gEvFlZC6u3g42lwOOP11aWQVWHygvxieGsCyPTDtKPWFQIDoVyjlkO3JVprj1SAgu86kFF3Ipt2a2Z9RpbZxRwDqf0HeU4haFGWYTlPRq0tvB71cgF1CL8BZWsl198lWd7buuTYRPoiKx7gqv2rz3BXq2MlGL5LB8qMS', '1557536321', -727, 0.3426, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303031303031303131303130303130313030),
(30, 'AEuRR0Sv7heoHWEJu0JfMUz8rBL8OzotIO4QxKSt6oo6KbJVj5uEaAKx7E7hwJF6fQ1HBofksnXF9hcZw3DWUajPazRiCMkA9Jlq', '3UZ2cfR8Xf3V6T982BfZAnWb6GmYpv23Sh6DjZ9s66gJ4A2bxVy0o4rWWtKd397w4xB6OBPEDQRpobi6q7fVyCiAa9wl4FyTCFtrF6RJxqOZ6DVTFbiG73w6KGGls4n7yFIEUshGPU9pbYXyi8Jl2l8uJ6ddelAeTylKvH4vugSIDbk7iWxTlw6K5o7YnuadzjkIvPedwtWVsg5wFDIh1zsUOxoAUv64DWHySPLMXApYFedPqdhy4vbVUA25MpqO5srhBFGfHygVf4J0yEdIujiOnu4s3b8pTQzSIqZzSptIdLC34ZwKh0LydisHHQcT564lc2ELp84pxmSYXacEsxCcrWfQImDfDeXG4wGRjJ1YfPvKcfgr1YRI2uoQ7KtuAebUiT7OBdmpk9wqPbG5Xhs70UVHT1FAU7O0V8UDgy5IMmUYP0uCesrnmcPs2afzASMYUf4kiMaUBrFocHG2VvMv5m65xccqEuaOgfBVHTCYPpOGWgfjYrwwboKzr6va60Uw07wmuSsUofjS5HasnfCpDjLWHSdLVo277RPGDIFImWcUA2tubV6bu6bclvhg6DwABsuTbrgoGxsQseaomtYPHKWkm2JCFLoXsWwY52eYo06CIidbUUckji6kKqyRBMD9HkWVnvzotk7ilfEQQdMIhHCcwHKYVFgfjyJK2ShHXxuQl4sm8oLZC0wWFRkWCqfdiFUr46nUKCggIKDLOr88laOzcShOG3C3EFr2tcQWYAoytkc3RnR9rcs45LBx7ynLoxmtgaFUxqUJBL8chbY2V7urmxi9XWumvhEOq1THv8ML75re5RrOLUTG0cnC8cZP0Uk1WJtoQI3GZh78gpirZyFP1HPZGkRaSom5SlrWxbGuflbVOQwWA6PPp7DdDl6o6KM29PMoCvGaSiBzJ88lyvlGbnQkWdItH0zSOauH5I5HS7q62j7BUOfrkwpjDZIrH7JzQoATUOQ8fOBvHnsKCYw4QymaHB5i46h9', '1557535898', -317, 0.8929, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303030303130303030303130303130303130),
(31, '7LZq0naMKicKI0ayJrGU97Q1OYcA2tTTGBuA8P6Wb6iEcVcX0envYuWBUHuVck6HEjnDD9oZZMLp2HBbDSs09Kr4oka8I3GnZUDy', 'vk5TakD3gmnjFoUlITjpgPccDEEWGmgmLp9EHLSzRUwj4MIAETyCubC9V80nLGh2olzjC4sYPj3bP4XGYLbI7qpZztHGeUFzoanRXfrebBWXYduFEwbG6xzGBHOT4Zq0LSyfBiOmULeyuerxIaxwsw7g1OgWgWyiwq7wEewn0OT3n8LgaFifco2IOL6TRM4sES3G52DgsIUqEUtTZ3pQj8k3YCjGOuYvacmITH72jvjFiyxmbjUjOK0fumUn85dq2o3C3gYFwa5Oj4ZIJrLEEf2kpWSXQxReis6pBGcb8HeOHtPWGr1SUBshGqcnVSSUVpx4w0Oz67LFtJ140kDYvRf6lMVGn5frVelAQbMQrpFqCTA3G5DXuYpOo00Sda1SiVw0ve8ZazX38VxUKI0LRYWnO7tXp89a3u5hyaS0gBAx2ORDceKuAPSQz5jS0YEkbX1qZYYTJwCVizyf0BS5HzaaJXwGWFxnGfksLDrEAj1aWeCIcSmycbQmhE7nhgOiyr0mWcjiOYOiYK55L0eU3FSrbg5XZIr6Pv49vCxOpvWim9UkH0t7i3iosJpm43sLrsuOqX8cnVta8q6q1T6dUh5d858FwgQjrhikI67sIdnVgzFpHD6bTofVajdSmlBJPYuJpatBrnExMACgLht1goMuzpGXyjJ2zx31s5cBxpj2FuW0dMdJ0gHWmowS99fcHZZaSTjv1kkpWgDB2akk600hveJF6R8fcjhcFzMgR7JEAUI6eqQOABFt3Ykmqroa5uY7R8DU5MvMBqasMyH8s6HyWyiV8U2Ykz1ToySqFjEM0QZGIyWmGt8vf2Cmde2DYvsxkRtOEJbEL6bO3ryrjHVkUolFFrqbYkg4C2s5015pVfKMJcypiQ52XCqRvwbBl2rti5OdIbm2qhHDOPXgEPCBlITVHukU6A0Kl1xePd1wka2nfkFZoGx48GJRikQ4e2XVLPD7h83UAXIZ3IMzvqQohxWFf2I7ImfWzv7T', '1557537663', 530, 0.2869, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313130303131303030303031313131313031),
(32, 'fAOsfYi2Z3vAPgxmzCZ2ByXRK3ZwmAdhg7fPO6anRxxFISuVh5BQRCZCitd2W7nhEv43K7pA6UYC1lQlmpCuuzpheMOqVxU9qMga', '401GH9KsFGyEPC13uoePwYMGgPOUyXQ9KK1EGgV9HVDREHLsS5pdc19QZZ5w5WM0Pnov3fsJ716VRFUKCEYvfWSR51I1ZR7JgT8dM7nbU0XRrvpXK6UEFKZJyXKofCPl5hgPURFv4RaEodiZfpdGtqsvpI9DTgTQgwKhotlHAzJlIMyU8BTAEZj9CoXLUMkbQECCfYnMvbHUqgcGnFWncpxEeX5LibaqLFSQukOJME3lvAdm1Cn28I93clBD4smw5xuX6zAzr0KEYOAV1rbyqU8jxCvodBXvMjtU5GKhteRQOTmko8mY6WtrgMM1JCTnRXRJrFiRTkjU0RuC9HXf9TdsmQrvCwc6hrAsbxdiFi9QAF0Oh9RozGjmQJsTTiUI6PI3ihvCQ9mExoTRLtaqnmM7FwS8xWYci5dwMUbQmTWlSY9LEFRkxVEKUcDgytqyRd5SEodUhtVUzrMyUJU76lThuJMgWSfMOdk5TKDRyWglELOexFlL1DtEt9j8I9rU76Wbu0qGdjYE7ZbMxu9ikPsXPqdTSi1TORX9u7Aofw4QW4XcVckH0TP4xAuvnjYJSujZR78YECwU915uFKTZ3Ox5DD90hdhtj03HAY3prBmQJRAFOdP9tBEY6xbnxZZ58nbiHIlJBszDGztHiw8agi8JWkzCbC4yjDFLbk1W9bak19JDbIO5rQZnb0lKc9vVTLx73P313M8TIBnqqMSR0hdTLxvKAxkaPLMkhctZkgtkOWn63JivVzPhJW2CmPwg8EppUqgO0BbDgaLD4y73dKOx5eXnvY6fPppoTxqv2QhP6fw4rfirUO9GOod02Z36T3LefxY5rXJTicFmcPRIWJTHUrRuVTnQkywWZpTxdVzPT2bxjgMTnxZAnlTScE4r9XDx69bSnKMDQK4zPz5Vadsme8h7Qj9Xlc80AKR4VunkakkvHLLPlLk0rO4fRQAiUk0lrfT9P5lTTMWiWQQBUcyv3ldffepwRkfzGCj6', '1557537616', -186, 0.5247, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313031303030303130303030303130313130),
(33, 'W8YYzMgfPv9U1KJ71uBDadSEiR6VLVoDplmvAB4M7G8am3DSaDbCRYSChZgCO8tPfq7XYifcMJui5cVuFF8tVBetDYOcdfWTsnfe', 'ISOtQFdjbfzZzzsdm7ZbnQIE0dMP2dKoQjJCgtkdEaAmQlaPau6Muz1Z940CZXDrlD3E49OYuW0BtZeimKAfZcGbGMAjjvUmeQJyfHEBIBLJvvFEXTsARGIgAoyS2YxatUMlM8T8j9VJUUvTSTHO539dTSTj7jyQ6Qe0IruviysBEbH0bLkUGiX2xdBCywXn7E2w1BtMDRmmOkhZSwkSGp6JzrGOoBHOumdXGFPVm1CZkleQX9GH3oDjZxaSByQ6fVLdJAyXs3htdfxznErqMgyLLw0ObolgmnHmaoEPVYjRu1fbc3y1U0R6XndC87ejSG1oY58ALKH68FjFoi3unCwis6OjtGueKTGi9D0e0pue9cL1WqVQf7ynnGLSb9820WK5G4eJAWDexAAgTra3ttZkEa6jgu9HCUbJCmP8yma6jRMmdkM96IL9jwPCHHwfCIZgVxOoUE4Rs0mlU5M75QXRlKUOxMhF1pbFAAaxCPltY2jdYH9WrPtqKRnSKJqYKZJWDwTyIRZYSXCXpdUFbGoTxPdOkzX8TqE74k0rcL1l8HkydB1girGdHFqBhiPboJY9S1td3yqAMlp2pRvJM3mpeo1iCS56gXE32ykRgdcIOSRoYZo5Dxou90YSkkIUw0HPAZymSKlIcgFCV0CiTUPrqtjipFIz9W9tviaKQaSAYxSJeSfou9Bh5P2BRT779LW1Pt91bsLl6GrIVDfmtgLY737OGYSxws8puwu9UC3YCHozZgCcQgjyw9zRUV0Qh2GGxsea0EHsvBIjqLmVz8e0j8qMtKw0ptCRYgk4tzIQMnpVf9tvGSwktZDBqtp3VOXTLXOPjm85q2uoqpZYbtcw0HeiL3FYM0CMXuFsx1UdrxXK0xRj2YeBVjbRtviL34FzuVUZ8y4dQWK0Xy6xhlEycMwiyRjrF06epeum7YA5BdW6fqHCTzroR8fB04HZFPVKHptCsguQKmw5WbHATGB6UmkMQ9sp3w6aosQL', '1557535754', -465, 0.6063, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303031303031313131313131303131313130),
(34, 'gotX1P5rfG9FjsMR36AHO5ErroyMhspWahOFrkPaZy475qCMCX6SXxAAScFFJnrkq4vhgHXK5imrfhQAADZVrRTCES9rAaQz5HzL', 'sYrdzV2EM1qhVefQj3zwQq05PPCH6e1816jyro4IGBoRCGTDz7DjoReApmLHuCRmY6yLFLuFY5JhH2Ujc44Yj9QZnLizgU3thZbSi1hvDrrAaehRcTSuBkPfI4cko3CsYJaQh8rdFExMZk3hzz3UhoaoretWV4yj2nxGD7ZM5L0Qchbzk9BbkjUpxg8rPYT3tThonZUfSJQLL7GJsAxkK70i1b9P5JAEigpZuIcy1A3AJPzMYURmyOt3SYy4IoE8twUsYlSLyjDh4pQHQ6xhJlkG5CkcJU7u3ELOQQUQsVBQLStv6aA3hMydGatc8jXIZE115ckOKoWhRdtaI72Hd5aBEz04Uz8QixD7Gr7CpJEAjpSIIXQevg9S0SUP3IHPZiC5FyhkrYKL8vC86C1Dbjv0I2brzKEF3X0V2xPUR4dQlsLqRczVefe1P4QXsDYpurJDLpJmD33LVihBZDv5E3lUiZSjIpF1jPSeT92GMUgzT0aEuYP7sIPF8Lgyn4Jvv5mHnLHTkCRgdAqzmau1DhFjmr2GoAcR4de3egJYedPQV34mCeyMbHUQWYcGMZ161dtgtCaVwGag0o42faZr71vdXoIyygdck66m5SWJb3SzsAsAfZOZpcuthFCjHpMb1R5k4Z7rdhYLhGd0CGZn5fQC0QUXdqJ35usarZE1CnqPuDlinfxF8bzD6Sxq7k4LwZdTbQztplgK4tStvHtPyZFwzMzOn6KoknkthASOzctz2bKw11LRmE9ipzY41JQSwCPWLcx06V4gmL1rTdsKwd0XDfKb2ghe6KGhDGz51w2P4eDe9hvx5DereLUbqF6s2LXvS302i0mg9zEULeWc0WQQccq3cXizlEyAuiMRWl5zBL3sL3KIj7P6xtkOl5Sy2pyytpWyZzaKqSOS9JX8ZbbfhDBqS7Pp62VpQpu8oFDPDPXaUjup26UfmFgXK099xxF8zhpAbEtKdErl2KqysU19QAhi2LRKmXMIG1HV', '1557536082', -306, 0.5316, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313030313030303030313130303130313030),
(35, 'bmknx4JAgAuUGnGyFqVeybhbaCn7SehfvWAjpgquq9lxU3sFGWmA7j9w27pcMQfPdpe6EkthZzz4vABF5lcP3koKguQ94jzfiKfL', 'ihUXUSbst08xRCoXnc1QTICYIEiyKWCji6Isc3aIPh2i0LYV4Y1OSQMFKTnKz3oJFMUST6vRxrjVvMUL8AnEeQkgaZROM0w2qms9X2fSDuYqpGevz68mYHfHWWGKmQ2dyOojmQlK7o0MFsX7ntfY5rx27OUykxVf38Hk9vPwYbo3j60BzJJqz4deExufE8bbXknfk4FabRbalCsY8SBLqyfjy8sOmAPYbor1TuUFLokaJ1hc5TRZFVFgQBMfrVPDPkSFOOv4KOR2uitjoKt5has6vYvyU8dbP9Fd6Zuk65KMDr3h5vt3ghCMxbAJJdYBcRSBL2RtPf2pas0999QTCganWh3OXb7UWpqTPYzuViFV3mjTAEABm85PIgUJw1C45Sl3fLGnocHhk81up2HctSn9T77ytIv7zbE53ra9eZ7xYM5YAicFYu3mqQHeOjL2snlZe01MsETEZjxkaq41QZ5qkrEOvLpQHroLLqfi3c2EnHmy6qje4lvnCV0eA6pvloQqHJRG1Byw9ZyFqjXkFAidhgIx3jO3ldDW0VQWnTshi88E74XiFHsVjuOJToytIUPmFYb663JUO95vbHj82G0uIAgM5mGLttnDITV6b6opH3pfBd3RLyVXvz6JFcdXBVjM9H10E0pLYP6RqAarTidgEpkxCU6Z6eCPWnuKvOP2CsblCRFVmVTtc9UeWumUZqiI8XloIsA9DZCGbZxgepVx6JSMEWZHeumvFmzVk0J92nrX8ZMtsLluoddeJh0nSrMaBEbjiph1OED2rSoz518k3zVxcunVSgBGUQazDHbLXOd18Cox48i25M1I2z9lfWM6zUwHmSrosPaTcgLnq8QBuUtMexhD0wlnCPfIsU6UlIuBDLv6aZK4hSjIPnMO8Yhw3CmBXP8gCubes9CGhJ3nqIwxL5FRCizyRjQnMBwwg9gHDp89LlIAYr7d6FXLvugs1RG10gjDhFH4dx0uCQKFT35MO8zzKykfziVw', '1557536596', 291, 0.3006, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130313130313030313030313130313131),
(36, 'F4xi9xfISdbCawqdTsAfouKUuAwVzdZvrkJpsqROtrYrPS8wlFYMojyqOLvbVvTgAtjo9bRLsy89R6eIbKJdL1JQtPRkDFaT6vff', 'dPeCPyFIgcGLnISvwzi7wKAlJHPo0pzZEjYlyqAb3bwIYynFD2ehWyGedCQKgbhAtH6XFaTvd2JwVggI9lxjKea03pf1VPl4FWAoaLyHJKkdfRwD2xedVM1Dh418XlOqe5sJ2gAMEmiLWjarhBhZtdf9SBa8kJCEb6HWgD1JXQDd2Da7UyIDowRxQ1G061PLuZk3SSOyAblwuRyEVnwbGHQOcjAKeaoKbJj1S0YgCprHkXj5i4HznKcXVtSnKblBfmGSeZvQ2vULwUsn3DgRqGVW0vwTE5ElGSqzYRqiPtJH7JYxa5c1Ru2RtqxfVRmWvgya4AICZkWw4rRAFov3DavBkdWvyvqrGv3DydnPv3xdo27vyAbWPImfxSICz2TOgDVZqHqUqEvL6uKjOEfJn9AL9pTCYqH2cEacE4QRH8RcbPKZqBFoisc97PpuJGU9vwMihjDFmtyvD29wrqtVACbqs7jfTQt7ciLggqOnpHDHt7UXP7FkgGwybhASpSqZgV96CplWOO7LF52fzGeBjBgzhjeniKKIHqTPmhgpAMWHgVypG8aKJpmsKegKyxrkwO1pt1yJKDavdCrscssMx6QeB1E0dbwOI4vTYDdXimKcxdGn5E9GIEGSPFr7eHYahcneP8g1cYIKfFkakIctg5VnqdA7C6ModdCr4uFYtr3ck0lQWED8cnwLoC70onZvx5fxFJtO9MLvMdIoWtrEuyv2JV1JxwyueQfvERDub1RGCiuOlbC4aBSbs5im3xvlitBl1Qb5A7kKPgC65JbldxAcy7WSWrQ5JZm4KH6wn5aGp68hdc7vDlH522YfddwGxmtESroRwXnvmO1kIvqwr1bRSPnuRSBbJCY8m4334FYcGohfAH7rCz2u6t9BSn3wiKQsdy68YgXKoRV2RLada0g0G1iBgMSLfK5GsVv5gJgbtbXHtIAS6jSoEqPu235SyDHL4ajVV6ZuXojgtxpoouRE1IIebcERfoHJ3htB', '1557537299', -675, 0.9134, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030303031303131303131303031303031),
(37, 'Lt5FReAO4xcMJT0RHeAIj24Aqh1cmqxKYrdYBO957tXOQVEmA7VrKxPja8XD9onGyhI9Jf5fxh2HiQGJSUC3zVXUgTeYifAuvZBc', 'fyohlWvs9C5ZvxGxKbqmKuTbQYbbQzS77K4bvvm6mhR6w48UkjiHCZXfJz8Jx2vUnP8W4XACYP16VsY8gjxXRmlc23tbCmvz0LyBZfc0XfxZGJafAca1tA92Gocu5zU80Am9iqbhhwrIQTJehWaZsHjJIChFVEExnhxxYtxp0GIllUG5lAwQPHRj8IJJ8COQ8R6Q1ogq6ImRfO0PL6hxyzLKVHAFHsj1gi2ZrcnjzDoevzHqAto9Fj455yOuEac3LCl1fTR5qqMt9dLUMJTB9VIiBhobZKsZDP2VprHID6zAbJeglSKW1pLmwSlJHd5LUT5HYSXefCIAz93uiS0agMbkOlGbLx6rwPwmTaxCd3ftkpfBBKCgS2Z9sHpueKuZwDkTblwTyk9dtyPAivCeR99RuXuF4QfpUlviSpS2huqQ0ALrm9Z4d8GqU2WJhOnHEU4zVkB3nw5lTt6bODJMW0BTG0MFRDUTMm0Il8HXRr6IafMMC2Rn4JUdRR0tOlMViFjK8PbHGevYOUShOhlRymypnzAa9X2RaSZEjm2lVUh5PqjDnpecpRBuibyIRoFDqX3rSOgRvqq5dP8SjqspEd1rzEUaXIGj3Tt6M6SfuRYYZ6kYCj5vgsPge0BtnX4R3HiC5hRvQ8RH8fUWj45tfzZYgeHEd1Qhqot2KkdDyi8kDgRPnGsjBywxFkaIqZYzbY2jPgXEElMQxabyPcc2lqr0sj0E0PtJjpYte42y7fPdOXSaDAjCsaJkCadtWwmMPIgu2JwjY2dsszWDQQP6WMowaTOai7CHGVWpdinWcH0zt6o0oYGrPhrB4uLI0zgvWZ1bKIBtMf9zSvdelZXE3DRylY7a5UhbzXrQG2dRKEFsDLqlESxJETEn1jPtw7EIzKfnZdb86XzcLV0klCxIE0P53xVEmcq9WrqLEgxgP6RPiWXbpfVy1ZmEsDnIzayrH1Z3HchhV9ukbQgVRKEhKRh7eBdE904BQsVd80na', '1557536188', 798, 0.3699, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030313030313031303031303031303030),
(38, 'sBYwF8LSSBzrosqs6HWElMefXFRXfQXW6g21RohkldeDXc19ridzdZV97eHzsvH47Mtmqw9FdHhIQMZH9KRnt3YXEEX543R4vbjB', 'mxoUr4GF7gk9e5R36ZpAAWxt2snWhsvHFp1Z4juuMC2sFifA6Od7T8wJnJhGqB5Gmb0W3qEcPQ8Dvn01tvowycTT6UyjXC2yqOnOpqcLeXAHIl9je4WOB7BUcWdPQwlhSj7v9i7e1VqDiaEtmwTW2VHMFRec6i3TGGf7g2pyaLDsgTxwSQcZQBcxvDDrKX7nTWJzKD4KHue9AsOrJ2ST0a3bJjpyLszJr5BVB87QB6cHiXqfZ6XFyAhHkRzyaRoYn5R8RvwMUzw9ngrVC3mktTT6jg6rX8A5HYtesJkCyVfsQtQsCSaRM4RmEy0b4ha4oIscrRujA9kDEyAT0ymgs7dunHgOAi7VsmQ2OR2U0fOHSwIbK8Vxv3WvtKVjucrEUSzKxIWlMeDDrlelTzQGXR3oXEWGKY8gHfHlEsfFX4Rrp48onT9IJwwaMslXoCdJUvcP95UStOr8JDnjg5QCU5nO1783p9E6sD4a1zWWoopGr617v9TpsvBkBEh3OxtkpDjnfXmUFSJ8wr2M96k4nPdHz4OXzPFrIwXtRbaJkesrZEpk9V8AG0cYVmHFIYfqphVrRikrmsxDOJbKwBj0m3y7DwZifZchtVihdhS1Ly1G1Gj3hbShpZh8JyDO8Tw1Vq30W9MsywRCAwPdpCOrQMn1dtEboEdCJOaA4T5MIn4ryfHgUW7tCsSM4g4q3ii7V4E4xvJ0f6E8TPYbM9MnO1IqhVQx4PJtucwpp0M4aHCGAhBZ2dR9mrWXTsZxsdyHqcLCDmc1rbW8FCCEF9hOhKykRSvqeuLOK5oIgB0R6wFr8Q0cFY6lzXwAcapanDkMrQoGfIay8KKCWVLB3FhJfZTJVkGMTEhEvtKwBHH8xRdGaSUVOeQ1jUCK1mliMyBoXYvflzCzkQ4CJHp5XGLbIHIDuhnF3kj0KmCQsjVUuGhqHqi8q04dwocok4LVGZntWB7jWXz71pS720y3jcK7HW32yIx2HvPQvJZDOqCb', '1557537266', 707, 0.6702, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030303030303031313130313130313130),
(39, 'JscQygPUfnhy9gH26UE4sKeS3M29dua7POcvcdfybFTW8FeVSaRbLDRWE2QYSQTqh1A4c235tRSdtY8E1jqasoRVD90FV4YC66lt', 'zIeu9Velc8pixln1w1dL09xfjaqFj3uLkiMLcQWmia3MqfGKYwYuJ0sH68gBTT0WsJIVCD3fK55aH1omMV55RKK2gZuqRBT0W32Wqkx1BStplEsRYazxlmpeOH47bb9VQfIRBSoEQwgxmbVcxirTcRsjHj2FTDLH5jLD9jCaq4pwKzJrtjG6rdSgZMn7YZMnIgdi5BeyotXpwRXxMcjc3sF5E95qqcbXI51PnMcPJLQ9F0vwtWja3zQMGmbBfhXl6Lce3QyYsX7Mb1soxzF1pznm6sDFse4DRlKv6LiZyYLh5VM7Z5qI9riPSrtB24zPYMGFwzoS2TMElGtIOsxkfbA92iGp0MsSt70GkfSDTFcUZlyd0I2MJMflz1h6kmIMmjFBuOIh6kY21S0zyRU8BhiqtCfF2PmzBnJn3eWMHS71pgPOvS9lQEHnL6A67anfeja2YxybFhDUaw1VPJLrsTvcqripznKOf8YyhIxr1zxDjFAUvvLpr0FUsFoBoswdCQaYWLUAJJPhQHxKz89fO0dtSLREBpEvnoIf0HCAQLtLIASu1DTYxS8XEKGAcfaGuREpqvIujGv90ny6Q10yEBqgOAUp9Y3I0aWrebdf9tUoD1Dz1hv28e5slku6txjETmDloJ4Tn8FwEx5XApnn0I8xfVsEb0Wr8qG7WaipYFQw3XUawpCAf5xuxoO6glY7Kn8LSsUOW5moPd6hQieGRkljcKvpIylELcXjbDS4ing9YmFgw3eEQrv1eYBAyD759T7HRHec1xxLtnC7AGBucq3AD54EKAfnUsF0UCYd7zbgnhWR2cldXiY3q3UAlqKy1UB9kq46zudDD3EsRzsO32gnAU7pi9DAwdVb77xSqhBThHIW3QYhxEVz7CH5CIUwppB5iEovEWo1jdajBYQCo9YE2eFEkbxjEtESR6C1ftx1HC0xxY5QDvnBjH15pwxZhq5wLoepdU4TtTcDSRGVfKbrY3IoSIXwhfU34zdF', '1557536530', -947, 0.8143, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130313030303031313030303130303130),
(40, 'B2LCyBGTeSl80hOAHPGWFX5sKCzPhlfg84IuCf4JBRTIpnhDULQfpvDJOyiQnnUK1W2e4KOslIOacm7AuBlpxWzTdmoIRiV8iJJQ', 'S8X3rs6umdkorjes3hTV12TuH5knXnOj4oqvX5KHTXV5LUunXtyPcAJ8VK6vWUgFCwiROzOLOwTDtm7bbxCBJ1YDwhfvli5Uzwx52XdI50d5yH8ROt3gFkz2uHMn7zh1TpaaEb1yJmXo1UwoOiRMYvxiQZG8gIR0za98DibgLA1zR0hPb02cDyUry9WKLJORDOwZ0iIQbGuD3Wp7XyAtGuDrEbBfFD7A5igGJ9DhYEkzDMVh41wD7iJl86DCXpPcUGoiRUXB8vxoAuOkzkQEVYd6YT2SA3UG5XTKkvAPEe84V54frwwz6w4JcyP0Bzl2E4K6c0DTzQ6DCxH3HAzlDWigM6Y00ZahA50jqn3QRjq4HTIIkx10zgUDLvuSLfmnVYCp3BRFwE9na56gkmPxSqTV7MoCUoXmBIBn2I1nyTez0bSGH30Xxuf3QWFfqqTeFlZdoIyWYZHCc80ZsCydApY4X0jJkjdW6RIX8AtpJYxzMYv9A4un1d4WpUl7A5UyVfRwfkLIUPKnJFoc6nOpPUyIfGKmeJZ37ul0JXqXrxl44gE7Yztj0spmtmwufgqpFCdlAqt1l9iCLIiVeDx6xTDS4UFuDEfDCDsyQOTYCCD4R4jARAYKsbfg2jcmpXrKXw5Er2GMiYmnjgG8RpMhLmdwnA67y51JCh5CqaRukcry9mrye6YGrpzF7KnJ56YAGUrsM9o4JiUCljARZFwYuljGcO2eY0ik8pcbw1jwwgKyX96177s7V9pzFH3BeL0XWMjLDKBRF7YnTRZ4CrK9IQTlwusRTp4p83Of8ng3dRy3drfZuDr3TnJZJaeZUXvLHbFA0Sj87rvCVUTMKHvQrOYulHoZill0DcVOeeI5pVR30fTsnDXum7zTj7VR4Bx7W4xUQtwU4hzmsrh0nsJ1Fiy9EoPBcK76EQxSQAGB6uEyix2qKaVqllVhny5eIM3WHsUHczebvB7BuuaIvItHohDitBJICFnG9YEqXr9D', '1557535982', -163, 0.8021, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313030303030313030303031303131303131);
INSERT INTO `test_table` (`ID`, `testVarchar`, `testLargeText`, `testDateVarchar`, `testInt`, `testFloat`, `testDate`, `testDatetime`, `testTimestamp`, `testBlob`) VALUES
(41, '5kGTDbpRP5JcWvL6Tr5iYlL13brYrqam22zX9uITBKeWOjalw69MaBgtwO6aZ9K3mCQR1GpMMj5A1YWtxCB9IJ8Poi9fTKIB45sE', 'hKszlJj7Bv6tX1qnFJn3CEycbe439ptjUHUeg3VuAVClHiCtZC08fUm1QzLmBCSSUwHKyeTLXdw6RrcsFn06e1wISOSxrHChhdTafhfUEmOIns9kJ1mWA04ihUkBDFKA2MrridZVKpsdgms4bw7FkSZK4TaxevgKaenBH15OektAx8aF0UegrBh5eJnmbd9OFxGDvGyz47TQbLf9baIIXeXhKsY3vOpIxJmxGfpdiLEYciGvKiA4MIZmF3XBdg3vOOqjeFDITjOYAGvJGiQh25ojWwh2iA4bqKRYaYf7RIkQmYHR0bsnDkc8BTZlKOrJqzEvs9end1eAv7hQGXslCrmQD75xATd9OgRU8dzwXbvd18eGKzPcZrUq3dxBORlryQpcb8jx1daHV2yqc5zUIiPSQbnxnGRCGhklBXpqu8c5bOf21sGuQ37c02AlkoJFcBDnpCUclVAkPskwdIbYkELowKb2EZ0A4OkhAaKQyzmsRZLSLR4jc9Ptrm9AnrDnkSn48BZla7wsfnA7HRiwqweqIQu2rLE3WOPI4UAJ8w3k0EMd2JVC2K2gnbclUZ2BWCCfm5y0tPW59OmcIuVA2ScWppiwJ4M1kkOE28V8cZeHFPj4M8iqoSJxPvKAW2Xj5TmX54D9i1ScyIDMeD298JEZBuAwwSrudli5vSK3LXUzQulo219JftWjLlOltzkxHEB7jxeOCIiPt8pTegEdI5Bwj4o2PaAsARh1u65rQn5WuERfMpwyAzEAdFmAwCefQVlO2wjYqVeWT3GtJpLLPW4xu9G1BWeVtSLsWQVlpkKPEkTA3inSrcSnaupk3aCstGAZg1UCKCEzOtszJ3nQqj25cIuwTfnTRnLoX4fKtMXcjuoqOFKFMizEBPYA6dvbBWkFZ0ZLzPAGdoIafbuowau6nMOwF32mJogQpO5E3JB4taqL4zBZDUMqxD1kCKVoeHyRdtzqTw1j7PuffP7s8wrD5nB1Ylbk7UfLn2q4', '1557537622', -942, 0.6336, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303030313031303031313130303130303131),
(42, '9lWBPWZMZ1uHZYzzFOO7mZjxXsEzHIXrxJLQKYe1enUEhrU1K8PM0VJcRLgYF8sjj0YW5RR6QCHuXOCkcldk0JxJaXee2qm4r9xX', 'LBQ4PJScY1Hv2qYKnqI8Q0AnKADGYbuMQedVbIpLn7bzfo6380hpTVjoQCibR5OwhJWDVAkea61vPeBegrdzjIqhjxky8Rv8575e2kCyjWekLXugKLwB6pU2akIOLuzChnzGwWhKRFP17wKcDYdvhYKGnZvXM12ZQvr2nrkQKhMzPZoZT2ghQoZcZwEXbpRdMwGgCOJM3K70UjpEwYHXKGAAWXbOWG3j6ojle3xBH6QjlwMcwMvt3SzRie5y6QCiMaijdaHjJkVvbByCUuGSJVVZ1ombBRzaRMFaA9fT9qnzozGVE4faMRE07q0FvKUUiipSk1alXpevYpc5MvbjdEKUAl23LwAv7FxtqLsF6frjV758hPul0lfEr8riqbFZiX2XVn7SCZ20gHl3a1afbT6iEMdqrH7lS4UhMSaWxzZyYaZRp5e2IjkPgkmqQ6XzO49u1ezUP3k03uZw32EGECXceJTiBm8G7WLADtnItp3jvHn43RtdWOUsz2M3JvHFPHKyCAxqvC8ukM8uqxECCRgBic4FgxEwTl8oZA50VJAyxKhMb7dUFMZCoeIaaqZgjRS7Is0sHHqu7AMWjy936A6vS9JxqdGS8e0HQciMSyEj5iF0OSr5UgzhHX9M4RKmkuubjOWZohe0pTXVG48Z5PqVXBVV5ncHTCmwbi04jTcy7lzIX9bLCfEqw84VtL2WQCBJqFp1Amx0cFzoy5CqyygPuyBMf3e39veQ2UdQfHfjETYXzUqWRJf5RQvxocO2QgeO11nxhXlutYImWABmwMAez0LaVdJUUUADn1V7G2OyGXREHaaDzIkfF2qEO74Clplm7TQzt1DugLnPPB6O0wq88Ws24TLeaMsWeC8UDSRietgSkXpPOcVTZJRhIxQIl3WqIfM6aArZy4wMd86JZKLwcpDpJ3i5VbPLzJQb5cpxgw9Asc9vwb03OXMp8s7jRb4ZP6f8mFKZlRag58zastBrLmjhUIjqa4G5ql3Y', '1557537449', 718, 0.3089, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313030303130303130303130313131303030),
(43, 'O4xO6WoHKEzH7Dd22STpRPG3psdE4fytC9jetEz6qIXQQOuEyUQgVs3TMrKftl1xQ7rwee8ntDERXR99sM90mYOBvjFGfjRtpWWG', 'lF4xUrLJpKawIzRBblVcC3Y1pa4inEQJRZnzH8fvgxzLmdV5nApE7FCdWTEZHf6EJb3tSF69tdlUnJnrXJh0ZaFiRuCxpHJsZf7gq7kF5KuUL8cFSJwedw5f8YYZu2K8BcxVlpX33a1LxpoMcC9jPLT5OjFiWf8FC1lrEAVjorVwGyYLTn9hPT3MQxLtLkU60HwRkDgs7Bc9dzVCW0v8bSAmfDexZi2oJh68nz0tdERD6tfmovgRVJvO2C4ty8xySI1hOn6mGyT1nfXYcUnr2tO8bthhwQqBn2kjB3A8wlhg1T1so9SUv6slIcSYRqGwge1dLBrLK13o2psPYhJfnAvpCOQwyTkkvj40k2FhlydoqPh3UiZsBWVmVhbYDdkZ8fvEflhFkYJgc5t9dbByecIczCTh6qIx84jbxwfXFfD1le38UXBwdjTUBRYsVvtWvKuAezB5opVDRg00YyZmzjqt1Wrw8tCfgk3Shvk5usy8K9kJp4I5jalVOVhsHj8qoLZ1HjrZWmAv1V1lerQFqVDfWLuhF11tU6i3uZVJO9ZKEz6PpHk9Vwisuv5Y0BhoLiYYFxLn2PLTG6xbZQduL1lwo63wH4Vb2m2JeY0UCmVT5umpVRsH1nKuGznYMoVREiso9hBiALrKQLzwfI4OCCyjlX6hfBjpE7hVrrAyX3lvZV9vXu4LBJI1n9bs4G4P2Psk7vXGEdC8vX5m07rBYJgAMgEwhEc7Mo1BaqFHKghCoQp6rCbkHBb3zeusRuIiVQWLAeLAeai0FB7Hf0iVPltnJ5HgPcBlq9fOoVgm5YHfjfbcrgOojW8zgOiW9MRgilXHzt70iCtnkLDx0oFJbrbEbpgwRfu3yp0t7UlvUaCnIbsMWoVWpPABsTAWXzvIbmq83cWUSz9furETghw313oq7ejgoMThbbeFlnVadS30DAeSW2w11ay89soseSEGySp41qhjX2kC9BbJ1FURna6HyySvqQMZjrYm4m0k', '1557537464', 815, 0.828, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313031303131313131303030303031313030),
(44, '3vussbDz721alxHr1FiarTUvua7dvZ1ujhc4hyLaeLjuvoVgYnbdWcdxiRAZlLpJWXgysPgDHoYG27vWiWr8PoUrtorCzqbSZsIV', '2W8YzT1LWHsv0q5V5tWe1PF8aYlSnRx9YWncOfqIebOW5K6AHpoTW8hw9nSJ98JghQ0hquexTxwgxYt8HecpfjgMuFLuhhjfZAZfpBofVLBrn3fy5VnPVmBXdQ37Oig63em6LAXPkS4vz1nRQuX6YilXjSGBGcAQtJ6PvsRh7QVraQT2YXSfo6rQLMIZYYhri7epCc9BhG8f7yL4tgbhcLXACz7eBBmVunIS7POOPpIXr820lsRbmkMeReUmC8Oh3vAdYjRTI1Fv9BFMBwVYVK1KrL3m1wCv0vQqdFgQ0u1XeXFseslCQ4C9pbzeMOPCjoswPV4EFQJfG940eh999fApKttZXWoB09ruO2emH4PrwePqBZlyPiWxtDKBrYls4MPla1LX7ahuIbYImyUQSeFyzFp6lSFcviy3UTGoT97qj1tUu0P0i2Mr3AqtBDmOkFGE1CZI30kfgJmX0j816HgdUnQIgirivVb7vfDVAIVXAjCRSvPXgg7R72BRhPTE543smJG0ukTuiLfE8zSHPGlmIzKRFdHT14iFB66WMOeXn7gkKwjmJZWKGZiIruVZkWVLdlUMr9XfQkESKl7U2aX12hctzDuY1HVJds4ttn2qFppi82iiIehaKrs66EqQ5khzzsB4TtuuSmxATBRzL91bRt7B0yKzwQ2ijjwvFrkqsc4K13MJcW74ko9Ygksble9Tp4PQPixepVWOwm6LZDBQabxeUYwExtDmUFt2m28VJucIoyMFabstoQklVuY16BvHLaw7gC6urWQwEDQrICGZZntljTOf2CKV0xX4y6rVwiRchzg6DVinYM0d5a0mmvn1CLJUds9eZveJho5DX6gDj5UYejzl3gnZBTUBfFfqPA0aE5g3B9CL2fbAKkwc7TJPYTrbELHt1x8spEPkE5lM8hP6DeQXyouxHKmCrKxqBnDCx6Kt5TsGAcRsU0xxmMB8PuEWBBKey6wF2q3vTyXrrZgIyEB2y26Bi6ja', '1557537666', -651, 0.1907, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313131303031313031313030303031313130),
(45, 'TFMAVCJp47M5FD2Qzb4n8aYWaAme3XjtA8qoaGOcBx1BgbbQYzTC4bdapYLbkpEVFtr4OCeRxRCZeAHHJQ5In3Qf1cz1ZKme8GPB', 'Or2nQ2BgzTBsSZEH4PQd0kJI1ZspYLA2b9dMv5Woi3T5o1Bz8rc4mjhiq5VtaIIkXIL4y1Gpo5xAiVXizWWM6bcJd4KpKyeu4aHdZPMiS0yWyGCUok4ndVu4nUYeHh7xyt1fMug4IMYdckHozAyQHx9hUDyU2RnsrFH9Y38HXrJkdR9K9Iqby2clPewtJj1gGJKXvtmdxZUkBfYZ5IFpOoBj6HRUPE1XkGcArMWBvpqcnwa6pBiupDp8K4zdhSptkv07JWXSRGkWwFJ56misoKzQMiEp7WaUHcbwp1i1zRAz3GGXa0EjLJ7pco8sjUjcsLJOsX12FTf5XA1FBvp1vB2SZmYpUJPmAdFYTJ8V9OhrdmHhpTwCBlkc9dbdRsHp5wZZGqBGZAFHR1MKB9156YZoFXLUb2YkYIEURZskdgsPSwe7ahUqYs2tAxJsTuA8dOIFppGQOMBPgX3l7h8DcPrqS14UYQBORJ9kkHieMd8G2cgsqaKJP4ffwmMdq30lRyYSDThu8u2rblPr7VKHObpWzASog8KLef9gjXCCREj4GnLiby8xaaWwZGlss5T4ZPHxmSmDWGYzAg62C4SgU2SZKFbo3Voe7gDHMFsxpBZXR3ODrrZR1L9jVwod0DihBAXJAlXigoocuGS8CHukuoPvsfZTkdxcuMCDKUOXu4ajvdjucQmFmTSAmRWs3Fb0JRFqjk2s5AjjVB9I8QBTAfhxDkhT71cEnM75eDCQ31QbFTlPrIdZdu4mjF0czezdnBVBwPB7oiJXP2VO9tdWcBf4lU5opjlCKj61dSYf7s1yl3SFd7AMyBMDK0xrCgtVvTEigOGgdvF4eWbpDCkvisH6xYooc6Z6DkArGBO9GpHqvIT1s0r6pdZqGPBc9PS98DUtthhVxc6G9nWuEgWzUPECexcTuo841QAnEQ8yKSSOaTpRdoPVKjHH899rcRLRgUDadgm4mp2Oyie5ao480G7EqCuThcMwTR4P8zYs', '1557536055', 321, 0.3973, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131313131313130313131313131313031),
(46, 'kyqcthGeBVUt5ZdcIoa5UFTlqKWIF6sqtH0ba2FcA25b7cinyuXuhm4K6OiSogJ3ZJW2eE32W2CKwiKrLr4M2XC29I2TujnyTChL', 'FaMKGUxdjhBnlhzY9nybzx8LYdpV9pYnuyVlODPxs8PciZs1EGSdndBxO0ObM33SFOpOiguJ0RoTDzIXxTx8yLtb2FAiPzudfXh9aJxPUsmrl2mIMYBU6cHGCdJidYjsbWwno7WLcXHSqnmopU2y2ui5BCgaYfvyuQ9s0mJBRhpbSzKWqIQ5kFhlWUaV7o5xbA8q0tViTvvnHFvmOp2u0JDtF4rxDp2pfdvhmssTiBYrVCEEyZAL3EmuL763wjm8GIf06knk5AOnusaQFqvXtstoe17pO53Jv7nAd4EEfq1bra3TbKPYh9W95OwFrI8eHmS3GGkSLaBSMKjO4WvSsGOMjtiMsfzAguJoybnXGKzqudXAj1yD082jU1rMREoPcvZBMxMTYeVSzyWgXW0iXqDGSqYECVAXwnBHpMzICACb1KlOWLOQeBCWdISpL4aVd9AFoUKqEOImRR6ektZeUEY6WS92h67LhLYwKTi04Vbq4Oew53xwWAH72VOxbZrvIhHeuKdrRT1mDDJHcutFnoO0vPQVrK97wEQPBuuL1JebAlCJHOMHb4hLmCea6pdAIVki67aZxsPSXXTFA0sBlC9pzh0h7XEWi3cDWBd3s4MqDowsQ4woU3nVbPahvkube3rRcYC0Jx8RIJx8s1W3PmYj9eGahBGixX4WOdpQoTQaaXVFsQLz8xWzuwAUpKgheG4VMkAxq7Xm02G6RwWZOAjIdGSwXLd8ikqK9j87QdoqdZPoA6vgRw2JjIv2PFwSJQbtTb3zCcemMPkzIxrphk9CMDxp6retydi40XkTM3raKwdBeRJr50CnDqWEJ5iYJtMxux06kL2R57tw63qlfyt1R5ILKBKkjBETm23bem0pMz7km8u8OZHxrCSL91zyfBU6Aos8vQlRSV80Z4VMIhjXq2oEVhLEzuwccDfWbc3ak7vxZTIj1sicLkio4qlDgfwacKqEdq9l9dhYmzUIHwDkuuz1ArivkTT0yKYe', '1557536633', -270, 0.4476, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313131313130303131303131303131303131),
(47, 'mapg79s0KrnlAwewtlCfLoDIiCTGourlX0VqfAoabfte4rfUJ7jRzLKjpma1ylEaUHOtKVHbYXW0UeE9oLokL2fMTYQd64fRei4o', 'C7o69uPD8TqgpiQGka77KsTi0FdpXKHcTbrSHV3aIqzgOGEVhamlZQifi9xQ15HSv7TwCdDxGQ79zYR2A3ZqB454Wug9ti6pvXG4VoCO381TH7q1hOZoAbgLZIllinRQTDSsArZWLihve8nSlrlfWbOloPPpvl08DdqJDnHYRkX182HBMW6YG3IObOEl5bviLEmU4bPRkfYooOodBkdyOM08kES93TolhYFXSRiCb2mD2rtHMAH1ipFkSnsQntEg9alQ3p9goG9K3YV3mIzm9UIpLZqo5Xh4pepBAQnL0eiKrmJiiIPAog8m4sKQagiJ2bQgw9ZaYDPDdDXoBBrF0vVbIOt9CtGh20DOPkYqjXInmMvnjmrDZC6TK2ykryrHpGQdunjz2600TOsfnZPulBDsa82oEwz0agouxj3A88EvLHMYOuyc5tyVW6Skem5aiHkDY79tB3FT3tuzCTFOcdQf6W59c4YdO1CFLMCesQ58G8y4P8agGQvrDGFQwEe8FdjzWluSFuRfHE0qng3BxkywyhCoe7SXXimmuLIog20f63QEkhiPMGYtQKYQjrTByeO1q5jMfrw8Sk2LDaUVoXKiu7G9LEg9y3BxIgi3AJqS1tBKkVUTn3X0wkLkAJ2zXKMWojEbjUHuwuyBoxhIK2tAXreoOHaSGjlerencpXm0qoSlQ31ruUo2Ip5knxF2PKhnS2u5TRnnGazWEr82ADFmTgi8lfy5k5ApFIYRIDMCkODqQGDv5glypZTPFQP0chhjQhPuWiyJlk6MpPvRWKoDkAQnnisOslk6oH30xQIJJIV1lQK4b7OAB4bPsCtt5iKKj0EovffCv078EHmaOmAqgpU8VQR156zhCbDESx9mE9G7ltm8MtL7iDZjJVBrsOKGifZOAHqZbaDYp6JY9tjHHJrnWTKJdnjYlaIPFJ4u44WHRBtGTke9uIhjwIgUlPf8LYPH9E6SlQEjFZBh05vtEyu8uq9WR8y9zEit', '1557537398', -424, 0.3416, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313031303031303131313131313030313131),
(48, 'ZuJOSf6KtGbGbi5PP1pSIke4Jca7d7he01baqnY6lbeK6T3nwt3FZoiQiDoCPDqeop0omndjAxDHnmoPBO3kBlIudXZ1M4W7aFcu', 'GgQpcMqx2I6841rTBaw2w7Yh8lRRjPLtn1PnbUBf5WcjU6ciZRHqcakqRv8tPRIlrEcdxU9Pt3En64lAJqgHf63qWxMZIK35TaXXhL4gg1ujGURLSScSFUakqsOmZwJGGx4wovlAqSH7DBJPmbvUszD5hfdBCaPaTOyZT71OYAiOYc0JfncOD8uIuVZIEGgwsXqkJB4SScgmFECwusfAcyIf6r8I355KoXFyZZtP9FBOKZDc8oGf7SkD4SEBOmhSHPiDAdgEP1j7dc2K8duLp3jUp9ylWvRRozhBzlrmRfpi3hMavVFb56E28jQYtwOHsdEsWkZXglSmffVsgtes92o3elutmq8rUIobFcUo2kHiQ5qDoVaByQuXHgwRDcQ3I6wLMXbIcbV7MMjGTftDmvYHx3V6hRUxUm1ehyRVJUvO7nzBLr9xx4QlLIGdimlTtuTz93U0DvtmPQdo1vdk5u4RmgRdGLb8pu8MnpjWXZPOUae4EsDZ1MEfkFn6s2neJnKTZE6LAkw7mnBCEgsvjYDvGWhQBbWdq8KRZLhtCyCicsn22YDVZ20Ep7ys7dT5uL7HlKP32E5moqvkMxcc2WIFvacY16dOXhSp5CJvPCViZg1vVZ8lsKQyY4elhTVpJEZ0cm1QYt86XYUxpiqngrjkPRCAXwZUXVttFZG2vdIMgyatiu7ir0aY2wpHW3rgu3lPxtJ7pOGmY1Ogxyb4ZqotD4yHlrgur3A2LQ94Hh1M3lPXbvBIVI0SBt5A7IsBKXd8o5XTmDJ6vyctbkpfdUZ8WKZkfS2ArGd6nc7AoRPilDWUy1AETWkgFVgWLTZrvkzXJbEaOWilxB6cjA9XXT4hLYVsEMibWPkEt3zCAX8h8rBnr256mGabfSXQXy0MLdrfAMRWKMl659upXlo8amDX6El5zd5gWsXI5pw9hvXMpJKlPx52kVuzjk7cAIwCwAO4XUzec7Ul7co84C8OTlI6VSgcZ8lRsB3hbgZb', '1557536349', -139, 0.0794, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303131303030313130303130313030303030),
(49, 'cwoOHyzsOEktThO5KoxYLuFnMvL08XW6EJMlHnn07QjKeyGPUx7WtfFlLCWHaa2huPxL55yoMTFTWIYsqz4OxS2b8CuhzgvlGMF4', 'QD7GQPoU3LCWjsoxYnMUStpJmflhhCceY53QgCvMwFEkzf59MLUuZeG4w5y5ek5hspmS4iZymt3zeTaDZ1oYtQmg3P9LyVlclB2LeRQcA8QHfpB0x9gilkplYp7lgnY0AF6yMh4HbFZGDOqeuavwzHPifTrLlHZFdCwdHAF695vzp5CkO28BbXB8Ufa5OVnderkJ1LEmvnpjxecjuO8zb3MPXsfhD08DB8w9GP0vexGW4f9byquqx3kplzHkQYgXmH5qJJJwkzkrY9tV0Xf9hVfR8xygqOL6t90zaxQpMumPeVbwPjmJoEwbioL5nvE9ZsjBWejbDhL4Syf00zRcSgcnQ7mLH6V4SE0v8MaPSXxcT5GmzHJxJKfsJIjkpyyS7I3iGdokstGbhuwAvIYKY8Ep1cELuTzxJFuWBv0IqTd43KIHPAARAmrfGxn5W6W5KuitUGZZLb7OcUiGvlAPzuCWILsgMbIv8btTAJl7ulorIXexzZYFXtaw8SVkZ9ROTK2aDF48An3XBPyh1uHnFl5YURLgzZmY0cYk3tb24i4jTAgTQSPZM5mi4HZ4wGf1vwhlRaEMV5tywfkm28krhH2vBqyKRhvXoHWg2Hvq8JfGxLMIAgcM8c5zv1wkyJ9JDM12z9JWJhpGXaBYwgr0nyuwMvSKD49pgIrGvrlkHGXyHrO4R936ZOhmsRz46hxWhxgeOCkB3ZQjRAn3xU34YVs4u5FgXminEfrCtFFJL96XmBkVBxqUkU0DUb8j8krFpO0UwBpKSbKqgvDD33aC4LV5G9YgIaWQwfX4WpvDl6MOwhlfRqhdbvcpQ0b4FSQT2ze6K5ZpbTb3aVpJ3GMGF8SCnILK0s6OVLV0XDQ3pxYbbrS6CPE2wCVGhkJjHVJBaQZLt44y057bzQGkyPUfLZkEzO5KMfJhMMpqpnFWZuD3l7TrSHwlne7te9M4fs8PMBdYHyEdkMxOugsqysvjnlibgnTf5xTfbionnB1m', '1557537489', 583, 0.661, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303030303030303131313031303030313131),
(50, '1hphC6T9JkQKFtljiv1xVSWEqxJn9ZtVUbJ14BCStcKdssbfSkxH3jTORlRgBUuibWqCTZKszW2xBjo4P3qKyCcQE1k2sGUxPBv6', '4ffX4yHJ92ZJ9CGFqPTJQzbFGlFFQ8WsDn7hX3KP4DWjS6jtGTXwn0pbhTPFewLGznmuapaLl7iJXqk9jQnbii1zfilx0OYOUgZzMEWA0s03oDHGjEbHBt0QAAfi9WxMA1YyLL8i2G6feIt7Glm7hxlYjKwVEYuDEElo8LFSrMyirGBprVVoks5ZpMbpySPn6957SCAkeKof1v7zzmRxKgbTTHdMPDvZUxdHZnSEoBB3Ye0C5GazyWEDJuB2shAt6MHatZxRVlcJjOgxWSQtIuvhW9nauO2QEVzvktAXQXai1hUldWUghXJOyGxaTcS4BXPJzR0T7pvJ6BV0QTkVcelbw642Dt4aVPrPb5MHLLd3xPiyQH8rvpksSoYMMCD9BzqMacYpOZjenU4YdpkRbsGAAyfpjDz1FcODwcvZd6LiARcgYYT8eopBGATUcxUJ7Hxlg4qr04BeaGHr6pPiEcwuavVhtjBmX6FWnOHLaVP37pAuBJ7jrS0g0ijw7YFQ7lapSqnYGDpIsZRptXOeCqRUeW6E8u8cGt2KIUq3BfniarucJ0R0bR5pPufEwTWqCuhYYhQ0TIHIfMuSmWiE6aGOOULwia9xXmU4zwCPx4q2G0TqmL6colF49cFhriIwD8U2yDOwzivew5DQJshA5o1dSmWUWkFnHKgSXCl6ZoZhJ2M8u2QS8kKeYoBoReZ78g1AFugyLnPejSijCtL2x8R7qjCL70GIWD8bLexTXe22gAbm8M54lOkSh621LDKc9UCEgRd5tWCIBarh0ZLYwmbwvLO9MadyH2u08lganxAhjC54g3PK4Mp26iW9by2OE3JdmHF7E1VIoY5JT0fp061q4It1WQeUYVmjZWsWknD2QbtiTP4Xig0Gp0nL5ZOTEFmhY4DDmBIdFgeHgvflYkmP8aEoB0KKIjI7k3beLHchTdm015OC1f5QecjTuU5taPtQ4V6FxF2ds3Tb9wJLr3cIH7lgLFL5ZcAqbEn0', '1557536816', -259, 0.0862, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303130313030313031303030303131313130),
(51, 'qLLdER3OfJFuyUJvpkRzas5UEh3cffQIKl19w2IHqiw8LzvDqRiXJAWfwL6h9RMhsOEXM7MuYIKEn6FDPf7aFAcsK8verk8Hx9FB', 'p3d9U1m2lwcvAvjhZtPynni46FR10m39pS1FccliGO6gJETgFePwmusL8UXdPrPzMzc5SfGrpYnTgGQ7JSbmIu1lx0oh2oWSx8KmVbqsv11n9AaRbnX5slVMkZfdBes3FzGvlZwlZV3KpmRs0K3Fz6d7tQs1zWl5bU0x9F07PHr040XXc1x84HTk1y3HUwB136GskdRK3ne85wniK9ptVcXoVa0gBZfOjaJeSD5gDVn8tVcwG9EHaylldDlHGkgtX7bTMWGECkU0fcpD12hMLO8bSZ419xD1XXZp68FVYBOKnlZCHMhKKViTUd9cYCprjCaPLb24GL5nUmVtLqDB7VRsjjBgbzxJ4cI6P7K5MPJSOgfddXokRMKU6hrcKp3UcDEgfVSYfIKf42WP1jvVYw3eg8E1I8XWHWYi3AlI6vauHG1jdz0ns8IrMSfH3HcSz9Dcd9cmkbXCIctFMHTIkCLvHsdgKaQFPdHYLzqTVI5C7BiUIH8Xy0btZXyGQvQlsa8CGT2hT8CuTSu02AJ2aeYiDig0iIeTsZWa041xepwf214ZIlJ0al80Fvmc7OZjQF8yF7mFWzMSy31RMZ7RwlGz5BPgkK8BAfGRI36G3CrmrXkzetRygdA2SAEcUADLIGC09RczwwtJII2c3SYanWTm2rS0SjwPd1V2XwFlnjSZmm6Fe7tCRzyyyasGcTMJ6cBX75wZAZE7nTy2OflYI4BDtLqfUlqxlhFIFvKucwO7LhngJgAbWq1AKfLGZGqdZd6nAOmTaXkZxyzn49chzFOppAt0rUPKZ2UUTZl9veeJGH9mKUcfyMY7rPzbgZzbmJ5jz3HienvmcI6dPwz5VLwGRV2ftXHt7iDACYqjkq9R6CqWg2jOEDq9DUSb3LeDfJzJ3LxcOkbemo7y4qroLnItOJ501t7GJ4TLQs1YD8At03c2gFXSg0oFktFGl4mBCgzF10SBSMmB1yDoPOOd7urKf4Df3w0pSkCsyr67', '1557536331', -662, 0.3553, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031313031303030303130313030303031),
(52, 'pYsDLP3qmRRHwxZF8S15vh47uJHvrJ2tbeEJ5GFwY6DwbUGZA4oCv6SDMVGLM2XekneILsEuWdOee8Mbpaa3TM33sY2VvcdRRpbA', 'Q52kjcmODeffC7ilDmBkvULVBeSlJivjhAL334ggpc5bcWOvLOxuXHSP49TI14cV6YUDaOyAz3iZaEGyg7RvJnlzVXiYEIhpheo7EqeM7LTFufWt9jwqVXcd9A46FfILRmgrwVhS1nRecHAhonAcsmqJJ8e64Dx0MnvFKhGPiRbFh3BW2k1RoF28HxKYQVK76f8KmwtDYcUZJfZu29PoGR1o3QEIZ4k6O07ImDDl0qZazlKVpQ1MmUnwL0Vlu5gWSDuzIDcVpwseLiTdapz4pQ6xS2zQoZAGi9eisu6ncviam8oniRueQDdqlWBdEKii7wmTzfoHlmvZjQhqMbOgDjGccJ0siomLjMRl3R4UT56FDqxlFmuaPSxQpoMAkVO8SVIGVl7ZMG4elTb9VrxXmiLl1XXAIkDmPVYV9IwX5aoFqebPynZAiBnJZlsstAQt8OA0LWjLJv7ZTqzmycM8ALl0kDmdCJpsPyAYK4tsLJcaIwkLXUYxgQH93ODQ9LmjTcWP7423bQFeVtt5GswPjKra9Qik2EF3kHHwRXXuYOvavjZfOUsYJyx3CKjHjqnE95P8YFeP7EIYs1SijeL0xf1PsxIWW5r9kljAshU2EnjEMB8dcqrUHOSsGcu5YBUvUtbXjLW6yZhdu4K0ruvGge6YhJD5m0IJQtq9y9m3RsBEzpLF4rXlbwHmg9aW8hVQ9m3fan9TvPkY2Bae5gKSuHGCBr4HhquPQ73d9vjAx2p9SHVDsWXhaK3LkBlkMrrGUKp3vuSaW8Sd4E3XdwuydGLLqD0PGlLplgaLfmLBJ7I9Euz7kYqHDuSFUy2cW7s2aDhmm64XUYXYBcsaQhIJrbmqJlqrBKxvmULQRIJ9qGwEXMH5ItpDBId4Y0czChZSV2DbHdMdlitdDflSYxtqa9rAyxmz1FO6R2ToWzcaCLPEIAmxAuU55s3ZwWTrMW0dbVvuyPZ0h7xYbMJ6BjHBnD1fTfMcV6zcSFvsyX9H', '1557536033', -628, 0.4681, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313130303031313131313031303130303131),
(53, '1SvvZ0T14GnnBp4Pr7w3XjSiVVGhIr5ddQDOJzri7C7oGrHjk1RMnOC1EMBJvqX9OF9ZR1nsxqdhamJGBMxobcJBKwU3Fg9WKn22', 'mlGtk6G3198XfrCSnre5f9zgc0ID5YiWfwnovExGeOV4gY4eWz6q7DBl7AGcMqXJuBqa45LcQl44EmTtTAlDl02io42DSKWp7xSPZonAOKAXqD6zctYJYfP73qJWkYkY7mFmhzmR93uGzMEyTeYHWmZP5DQ8a36nv4RKWCI0SdLj6OBqWRkxjlwouKicm1eFfCp20yr1YfqOZHX9om5g3drRhI88WRJRn4lcqmxUrarbftDKdKcRaWJbrzlWUyCTToEee22FiWRqU7Hfo0GjDzpnZiXDe9TPLAk8pATjvCCyVD9BY8yEv4rsTUUcXBwB1EoVW17P69Lyj2ZQU9OTKqSpanfD1XwhDBPzTjId5ziq5jbWe2qYmFEeQIWWt9VPDqD6buGtqRcbdsKXVMqXlMPXSW38jeFf17PvRy3B91tOJtHMZpOMHMmvh3vcvcPxLGnMUtMCf38iDn1wqVxvrDhY32l862kIU8jXkhTwIYaFU9I8eiE6yozidTyX3JdKprBY8YmhyKyVxOMBqyay30fuKB9CnktGhDiSjvdVMql3ykfYZG2UUuhzEc7c5M6txHlERWrrnWu3WI4cXHh79SHwWFsCa779aEMjMf3Pln1VIZgjfzTdK6ulB2aXCkvGatAQ5q26HEVFS8QiXlTbJdE3Dgg8spg7xaLfKtoeqPcioaM90Yg27dcC3mIbEnopiJkwOp7fvRQMh47Trt0JQ575Qky7fdUzqbgFedd8ZLSayQOugR7kWPppZbLXcVMCXvzH2THUQyhpctTZr7COrq5BwUmCwv3xOGgCcryx3e3xd0kl1fu9jV7GqvkbeYGl4LjoKSM3ELcxBo9zWfJmxixDIZFCjiH1GHJ3FborCbIpnFlFg8msawktnknXLv5yGwyzZmmHYsCawPVEYTlq9Euapyt7BARZ4eJZEpIRGCUM2QSw2wIgvD2KPEXbOyZhPMigHlsSMFyhXJcfs2sZfvWcBDL7oourWeeq89yK', '1557535922', -156, 0.4246, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131303131303030313130313130303130),
(54, 'cvTShpAzmffwLuZVl6nusyxsXP2w7mZUQaYltF53QSVIidzBFGDpkKdm6nTak2K2RGpH2OWoHmWOdPxbn9hdAPh8EO7FVzU2f5eX', 'ZOcBXInKuiSBstiTdLHMz7I4UZrU1lq3iGPHyYaA9DAVVGFqdAvkShHkfglEau02ZrOFx5khbSF7KLrRAhHIyl4sYqBhGwWT35bvU4SSAY9aYJz9lRg1BgMt4tgLzqhCuAVeDXMjnXZ6xz5jtiba24Tnxni9RcZejY3PKF5DxMcVuhYmZBucPKn8naGouQ3HuexifiKR4wMBPSehROb60jeLBQtwvmu44mpC6MMVZ7KaxkS57SeTyJsicnCwUKkj0mERl9dSgA5BBESKJPFxt24FaM9oF2wpjfhXWo0HVWOV4SgiJDt4Ld2Ww439Pb6o00gUXvapWaT6UW1I7kEtrgo5fekLkc3g4DDKiuHZmhma7Va1SUdKuc86lhZge6mZv8nt2mCq9fc6GKFb0l9UV0eZOb0DuS4Akwv497VKj6pUDsyevFsXIGHKEYpT8w85wL0wDIAYQP0AZ3P9nR8QUeyoSDb1a2Ar5USSvdC2KqWaGvrWDXcCrEMUtbk1yrpF1V76Jz3Z2UiALQsCgSChnYoirARTjHBMlOJblPQPGf1Ud3RagGrOF9nyMTKDsRbL2yJ9lX0wJt6638BADoCdlcJHv22gZT8C6b60HXx69zy9g6JToWbuo8sIB5GLSLsmxGRHrOsyVyp5QXf3wo7EPXyB50I89y9Yl5YjyxKT5oCUMD862IpFCB3nXM7oMcerxksL29q5C8dA8eo1UV6AOaU19rTvOIFO7sk7UDsawIa9QG2PaZamlA8wKZ3vc7u23tzk81T7OcvAV13tMXA1hUJVIoznYoG9mmcqKfFXtyeUmeq2MKoyz5Hb4Gt87xg837coJmQDvMj5cjcrarzWf84jMRKKCydZ7Jye6mndVTL9phkKV18ei4OkTTogwsxIyfjWQeiFHRB5Z7QV3s4oISUemOqCMeeknCqxWYA0RHQUXPIYxLnqwxnZcAPTrTjPyTV1rAgcoqpzhpZTqY4kG6eCqfB0soKb81Mmi4ih', '1557535999', 754, 0.2249, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313130303030313130303031303030303030),
(55, 'ZSCFF276fws91MK0ROzp422zxrIeAvIz4cDljZyKaP4wZchSC4LvoUEF9Gv3fRqTvp1UjOmit03MlubCKdlu5FED8OFKh5w5luLj', 'GuxH94pX4Esfhfim9i1tuMdkGbZ8ysVBr46ZcZ8WaG7Ka8C5AOLceE8MtaP58iqMzv28CMeQCB87rUkHobTMloq7C12T50jQ4QlaqtIBtoxn5yobArngQ16jaJCzqAzKW114A1zfG3ju65Qx9zfBHv8o4lA883dxc65R9sOKiAsuutFL6zuPXSylmPXzdnddQ2vv4Kp9g0ZmgKSTps7Ux7la1aDTFABLQRj2mXnpBiT7pUrS6d7TxevS3oJ4uFmbdyvr3ZJyksaJXVoIaRtIUd3rsuc8HDvtY74I6VtzquPfPPHsBmerD5YUfs24ht1E6yZSwIzsUpRB5Ap4qJl2JPgepjfTfbUHATiUjo3dKcfSJetxB0QuerXqX3QyzLaCt5ZOuWURYR1ZKKXUb8IQ6XYvRDO8heMpI92A3n8nzobZ9aK978Y4kios879ymyO5m6tfYGJLxOHRVqWfq1z9WxbiMtRSPLcCmVhLgSI2T6BB3zwe8Lz7XElZPGW4DRW3JBsbXV5aBgTezBt6cpWYiETzeMp7RP5lub1sZRObHiwJtuMPCVGF2vO11Lf4qEAwCCWCpEU4bdy6JguqriOh9g6lbCsSomty7XgDdkoQ10WmnVzVDyjJDSLxHl3yIWJu08WyoTftfEJtor1hcGb5umOCCW17qpnhfc0kXjt0QcTtMQQv9GqiJIezUqlyvJoWT9qZSC5nPBply72Csz2olY1pyL4SYWLuTYfwaM3DaUj6HgBB9k2mk5b7A093M2xVgEqVQRpMT4AIehysdYpcG5IG06C700Fd1eZcTL9OZ6fe7bTcEs9VqWD8M5s3zQbo8FVmjzfGr1gAoWzOtRhvxGXsWVFSxx4qD0do7gIsiOFR2AEhE6LZ2iBFuEgxS8kmwbUiiPz6wsrY376DeeDkTMDJofe7zAY9LgY5QfOB70AYrvVSafTx8a4GFIyxEVZPocoJLxp05p8QdM7Zt8vDJoRwl5hR78mmp1cg4Iog', '1557536264', 100, 0.869, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031303130313031303031313131303131),
(56, 'mXGYaTuBIv1enim3Xd7MMInFJLKp9SidSWDPevSr6vyOMpQ79bg5xhXWMHtpfUWILRYyF1BaQntfynF3I0LfEIS6dvzjIPZ52CFa', 'upJKX7LzIeTRGIEia3b81b44zBnlFhJEGEeeqJrMgWtx1iVd3fS2bJVHMhasGOb1fM6zietRayr6ILy1ijVPJa9eoOjs5c1fcOlMwAUPs2LxO6yGVgmtEtKCmeQkRtdlvGYT9QGD7nuRgjWeX5a0YEITHvJ50CMkcrWR8WRl9Bz25oHEjLlpDH51qF1HwDIcg4kGuXoVyH26imQW4lUGGDO2wHEdpx3VHz4peOjnlGT2Sbm7bMQQ7rVV0CGzGjKxvWc0lxBHux6RQUfaG69SV7oGQp6QkWP1HdGtPahU2gGxatv5ziPM5Ffk45SWlthnhlyOGEjZXRD6SX8TPmTyD6tQEB1WJS6BdmO2X1JXelZwWh9yrjjdyp5eD2xQv9iIweq7xgwKTGHQpux6r88JRA4uZjrzEiSHd0p5wnGsVVM2eziwQPj9xDpDHtIcajPyhCMXTme2k1f6rwqPzoSqAy9EOvnH4d8iI8xECe9u7Z622mXZHQOA1nfxgqo5kZQUxvEfJYrPgQjQZ5P2da6CO3Jj7dOkYDUnJL9HeA71OyTwjE5W6lMwZBAWlTzr0amJiU135596IaR517IKlqRix2PsXqJroybZeUggkrz30Dcw6sJqYmhWskqRUQgk9Pn5yMTmXGmSEZVQyF7YYb5uKvo7f7a4iYW4fxTkVOwzGd01oKTolTgTqzKgYhqGP0UXjbfbhO496js5AH1G6rPbtutg4k5cHUeEKG0T1EZBTii1bxwReTKkUiAaxe7zZFVgy47u8phX39vQ8gpUJd4mHZ4Vo1vPCj0KKkBWC1W8zS6wsQFPBpKgTwVyBGiXDQr7jstiuvZdut45aijCStO3qY95derX2eglgsIvITpaLWpvfDjiuqfHmgKtbDYPOvsszllBk7cZqi7PHRHQuf3eErJJwVSyWE2rg6lzkemGswd1xXsgSXeDku5Sf59bsFZikJHpGeUgSCF5JTByCvMVnqPTl8OGmzj2Lfs8q6PI', '1557536717', -116, 0.3567, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303130303031303030303131313030313031),
(57, 'kI7IKWI4OeVLP2P4Cl1DACzIxQ73PrIPhr0Lgg26BUpxEPejh057LT4c1rMflbjvB1gG8sH0MsgbTu0qiwwtl1XxTXPkgLh4jtUu', 'owLMkTuGt29qGVmHh1bK7jfhxfCvoPU91tcrgc65srFjsbyPAUORJx27cBkPR2iH1i0Yyn4lOIz3Ak8OiEOPIFcOfPq0G737oZcneqquwTRF7m4EmiaE5EJoDXT4T4bq9yKEhm9vCXvb0gooMOVnPwEQqUI0tUHAh0FPHago5Qxyh260Bb2YXgWaAKXPqCADMkZQvQJaXDXOVFauOqwrqTCm8twvKcRyEvFKFoAOaiHVXcCRmzoMhnEr25u4sEtlVAIwePPjKQSVkAr5jzD0wJ5ojyQvx0u1xwab97qHIfoO6SDbCsg58ZSeZUxP0dTzxlYIsipY4xixf1dajdg3762X18D0QiDZV3978mK6MHzaL2a2nQDUt5zvqe642fLhFBHobhu7TJdFEXtKPlnCdWuWddX0C5hsO3DyB5A1mEf3VHbnDJudkGMhm49OzOavjnWApL5LdrDizmfRPZ0FPjsuUMJuUnqqbzCuzkXpq6qpASHdo7S1GOuyOnH3BQ4drDGh8KaX2DzpZhwrk87fVaVv6R2uGb5T4A7V33Lj036iKxIyD1IkwpHlKdKO9osr4pXsmeJAll02TGixkLIiwwS3MrQZZteRr67S2h6I4vhEpIfooo69TvpCcxj3bqm9cFF95dPJaxXajBz8QUQRCnk4Zv9ZLgSkk7Biv1XCDsWxzogJEhWsJ7Co8mmOIZKnQqUkiGpotfmMd2ldRxsVdJiBF5Wu3y1iHCAetfg2HU8UeyMzpFkg5ekFzGV3K1E5YGE12FuxirhUCWBPmGztjAKDSafuQmEKAD5FWZ6XhROMoeOVFybzXQxswvYOiy3iAsTcfa5cC9HwxnnUmkbxVWHayJ3Z8EOIY94BVdqlljZ94okLqWynhWfJYQw3kBW1IICTZ9amrlDEWiEuSsi61OacKPmZVrscRay2oWgfUgF2e4l6FQqG8yswVFzMS9lemuS4cCK1K34hSIqAS6VaCa8IroatcJBaeFyYnbBE', '1557537357', 106, 0.6883, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313131303131313031303131313131313030),
(58, 'TeSWreMvtEaOm072UcfWuKBKVBQazf0ohDHbne2II2AKDtstZxfC7G3pRVryxEwh3UUiG7EPkgnziPbMrJDa7vRX96pPTWq1c3th', 'nSDMjnxhk3gYhQoAud2lP9LWB7HDH5p8rv1CFn5RJ9I2tMwTfLACS4uYH9l9BYJST1Klpf0jw7zY4C34ndwMiSBSb4nwSJrtHoTXwZiDGYMM1kX6SxQP6y5C2RLLvovWUEnp1AYQdHntlVc2KJvIh7XgfvyTwVYjsMfKS50V8ik23nPP0OzuPxaMR3HTVjMxoMuY7sqSpLFt8IQuDK09KQLaPseLGAZEIF74IGdG48oMAVd2DzOG31KraK8vQJyDpq62IPno6ltYq1Zs1g05I56zTVp8mKvut4tS5OVYvrX2CY7KLQymL0QAZW4DfEPeVzdAPFQqiqLYdOCVUhuwcOXtsS51wqwQIWlbVp8Ksh0LavvYoAMy0uqfiEuga4AkVdQDp2OW00zsu6LThMtsa2hTwjgnbA3GtlHZhwQ2UBx2dypGwRwfItvo7Rpnz0SVqlWdvTgZb5TshUqmaOYUDL7M6gWglg41Jezi883ORqALJ6OUaCLqWW53ryR0upD0qZzg7fdvTEGYzczkxjWQC0rcaI7C0rASuCX7teK6iK91M9HCiTv7FXadgKL8UkVAX8GQd6Fx4JZWmZdMqkrg6Jh6JFOva6BdKvOqkQYSezcLjG6QVEKiUpKSzscKOKGGXKiTOsD4LjMsEhmKOQrc4YBvO7ZSQh83vUaeFWF9FUK1mJ0y3VuZCoQ1oE8SeFWhrUprVj66Wn6sr50eGRVDxHrpm5EKZW9oKM2xwyTXCJOLThoLGFJaRTqFImyu86Insx2vvF3CEYUWIn9c4nVzwXLOrwQ7E7FewaomSEAd44m1XkiuPXtRzSvPwyuCx10YWF94BwvER2cWvaOEWnp00FBI0tv0PMGzL4gEIhOZ0TpKsSGHrHI2Ml6tRgVfsqL3YjK8dTtcxB0rOsWCkUoWYUW74XGntWdpwrCt4nvgrdY1vVAqzYsIwkbDFsQmSl2EtsSGjJXdJGjrAfA6dVTnrCM1DTmfDCfKMluMVZI3', '1557536183', 765, 0.8636, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303130303130313130313031303030303130),
(59, '2sZDdJGUJOKiZagZMLPJt6uKU6TKqg7WSxJ4AqSjpS7qHkxCiMKAxIRAh6qkQmz05vSml0qAtMQrOmc7cG5kZeBj1YlLClpXElow', 'trmKTAWkhhdussMXOBIU7HD6LcCKB3hzYKFMGhq684CJ77RqZSdnBjjjjVdrWDwuRWmGSQhJlJoS8DjMy05ItOlnewb0E6ai61pspgvfXgyRw281u1kXHbLkv0wrJqbYIYR7ly7DVG5Jijk8OTW2kpyaaleKbDyvJMEEDJ6UgYZtqsU7uEW0jwISczjX1IkX7tQ3jMr3Z8g7WtRYyhjQFwgrBFM0eGseS3olmIb45bUBQnaH0M4ypobUoDCXOwYoZukuMwhWy5XZ79SjPab9w8tdyuQJKeRruPDwAcLHoSkeKMXM1qFC0K9q5dqq6P7mn0jqLKCmCx7mLjo9zyyWSebv0Po0OhKaC5ndjbRSd5glaHdnwyMb6BBshiIqTBLPf1OSfusgbuMeXZpuQrpgIRohXErJlP9ngQCoxFqwxLGY58ZtwcpeHYyZYSwXaUVMDxOOdIMEgXYBB9XkAQM54W6ynY0ZnS35o6m5gEvFlZC6u3g42lwOOP11aWQVWHygvxieGsCyPTDtKPWFQIDoVyjlkO3JVprj1SAgu86kFF3Ipt2a2Z9RpbZxRwDqf0HeU4haFGWYTlPRq0tvB71cgF1CL8BZWsl198lWd7buuTYRPoiKx7gqv2rz3BXq2MlGL5LB8qMSsiuIAEuRR0Sv7heoHWEJu0JfMUz8rBL8OzotIO4QxKSt6oo6KbJVj5uEaAKx7E7hwJF6fQ1HBofksnXF9hcZw3DWUajPazRiCMkA9Jlq3UZ2cfR8Xf3V6T982BfZAnWb6GmYpv23Sh6DjZ9s66gJ4A2bxVy0o4rWWtKd397w4xB6OBPEDQRpobi6q7fVyCiAa9wl4FyTCFtrF6RJxqOZ6DVTFbiG73w6KGGls4n7yFIEUshGPU9pbYXyi8Jl2l8uJ6ddelAeTylKvH4vugSIDbk7iWxTlw6K5o7YnuadzjkIvPedwtWVsg5wFDIh1zsUOxoAUv64DWHySPLMXApYFedPqdhy4vbV', '1557537198', -138, 0.8827, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131313030303130303130313031313130313130),
(60, 'MpqO5srhBFGfHygVf4J0yEdIujiOnu4s3b8pTQzSIqZzSptIdLC34ZwKh0LydisHHQcT564lc2ELp84pxmSYXacEsxCcrWfQImDf', 'DeXG4wGRjJ1YfPvKcfgr1YRI2uoQ7KtuAebUiT7OBdmpk9wqPbG5Xhs70UVHT1FAU7O0V8UDgy5IMmUYP0uCesrnmcPs2afzASMYUf4kiMaUBrFocHG2VvMv5m65xccqEuaOgfBVHTCYPpOGWgfjYrwwboKzr6va60Uw07wmuSsUofjS5HasnfCpDjLWHSdLVo277RPGDIFImWcUA2tubV6bu6bclvhg6DwABsuTbrgoGxsQseaomtYPHKWkm2JCFLoXsWwY52eYo06CIidbUUckji6kKqyRBMD9HkWVnvzotk7ilfEQQdMIhHCcwHKYVFgfjyJK2ShHXxuQl4sm8oLZC0wWFRkWCqfdiFUr46nUKCggIKDLOr88laOzcShOG3C3EFr2tcQWYAoytkc3RnR9rcs45LBx7ynLoxmtgaFUxqUJBL8chbY2V7urmxi9XWumvhEOq1THv8ML75re5RrOLUTG0cnC8cZP0Uk1WJtoQI3GZh78gpirZyFP1HPZGkRaSom5SlrWxbGuflbVOQwWA6PPp7DdDl6o6KM29PMoCvGaSiBzJ88lyvlGbnQkWdItH0zSOauH5I5HS7q62j7BUOfrkwpjDZIrH7JzQoATUOQ8fOBvHnsKCYw4QymaHB5i46h9fu3W7LZq0naMKicKI0ayJrGU97Q1OYcA2tTTGBuA8P6Wb6iEcVcX0envYuWBUHuVck6HEjnDD9oZZMLp2HBbDSs09Kr4oka8I3GnZUDyvk5TakD3gmnjFoUlITjpgPccDEEWGmgmLp9EHLSzRUwj4MIAETyCubC9V80nLGh2olzjC4sYPj3bP4XGYLbI7qpZztHGeUFzoanRXfrebBWXYduFEwbG6xzGBHOT4Zq0LSyfBiOmULeyuerxIaxwsw7g1OgWgWyiwq7wEewn0OT3n8LgaFifco2IOL6TRM4sES3G52DgsIUqEUtTZ3pQj8k3YCjGOuYvacmITH72jvjFiyxmbjUjOK0f', '1557536400', -604, 0.7454, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313130313130303030313031303130313131),
(61, '85dq2o3C3gYFwa5Oj4ZIJrLEEf2kpWSXQxReis6pBGcb8HeOHtPWGr1SUBshGqcnVSSUVpx4w0Oz67LFtJ140kDYvRf6lMVGn5fr', 'VelAQbMQrpFqCTA3G5DXuYpOo00Sda1SiVw0ve8ZazX38VxUKI0LRYWnO7tXp89a3u5hyaS0gBAx2ORDceKuAPSQz5jS0YEkbX1qZYYTJwCVizyf0BS5HzaaJXwGWFxnGfksLDrEAj1aWeCIcSmycbQmhE7nhgOiyr0mWcjiOYOiYK55L0eU3FSrbg5XZIr6Pv49vCxOpvWim9UkH0t7i3iosJpm43sLrsuOqX8cnVta8q6q1T6dUh5d858FwgQjrhikI67sIdnVgzFpHD6bTofVajdSmlBJPYuJpatBrnExMACgLht1goMuzpGXyjJ2zx31s5cBxpj2FuW0dMdJ0gHWmowS99fcHZZaSTjv1kkpWgDB2akk600hveJF6R8fcjhcFzMgR7JEAUI6eqQOABFt3Ykmqroa5uY7R8DU5MvMBqasMyH8s6HyWyiV8U2Ykz1ToySqFjEM0QZGIyWmGt8vf2Cmde2DYvsxkRtOEJbEL6bO3ryrjHVkUolFFrqbYkg4C2s5015pVfKMJcypiQ52XCqRvwbBl2rti5OdIbm2qhHDOPXgEPCBlITVHukU6A0Kl1xePd1wka2nfkFZoGx48GJRikQ4e2XVLPD7h83UAXIZ3IMzvqQohxWFf2I7ImfWzv7T8Vr9fAOsfYi2Z3vAPgxmzCZ2ByXRK3ZwmAdhg7fPO6anRxxFISuVh5BQRCZCitd2W7nhEv43K7pA6UYC1lQlmpCuuzpheMOqVxU9qMga401GH9KsFGyEPC13uoePwYMGgPOUyXQ9KK1EGgV9HVDREHLsS5pdc19QZZ5w5WM0Pnov3fsJ716VRFUKCEYvfWSR51I1ZR7JgT8dM7nbU0XRrvpXK6UEFKZJyXKofCPl5hgPURFv4RaEodiZfpdGtqsvpI9DTgTQgwKhotlHAzJlIMyU8BTAEZj9CoXLUMkbQECCfYnMvbHUqgcGnFWncpxEeX5LibaqLFSQukOJME3lvAdm1Cn28I93', '1557535789', -633, 0.452, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130313130303130313031313030313131),
(62, '4smw5xuX6zAzr0KEYOAV1rbyqU8jxCvodBXvMjtU5GKhteRQOTmko8mY6WtrgMM1JCTnRXRJrFiRTkjU0RuC9HXf9TdsmQrvCwc6', 'hrAsbxdiFi9QAF0Oh9RozGjmQJsTTiUI6PI3ihvCQ9mExoTRLtaqnmM7FwS8xWYci5dwMUbQmTWlSY9LEFRkxVEKUcDgytqyRd5SEodUhtVUzrMyUJU76lThuJMgWSfMOdk5TKDRyWglELOexFlL1DtEt9j8I9rU76Wbu0qGdjYE7ZbMxu9ikPsXPqdTSi1TORX9u7Aofw4QW4XcVckH0TP4xAuvnjYJSujZR78YECwU915uFKTZ3Ox5DD90hdhtj03HAY3prBmQJRAFOdP9tBEY6xbnxZZ58nbiHIlJBszDGztHiw8agi8JWkzCbC4yjDFLbk1W9bak19JDbIO5rQZnb0lKc9vVTLx73P313M8TIBnqqMSR0hdTLxvKAxkaPLMkhctZkgtkOWn63JivVzPhJW2CmPwg8EppUqgO0BbDgaLD4y73dKOx5eXnvY6fPppoTxqv2QhP6fw4rfirUO9GOod02Z36T3LefxY5rXJTicFmcPRIWJTHUrRuVTnQkywWZpTxdVzPT2bxjgMTnxZAnlTScE4r9XDx69bSnKMDQK4zPz5Vadsme8h7Qj9Xlc80AKR4VunkakkvHLLPlLk0rO4fRQAiUk0lrfT9P5lTTMWiWQQBUcyv3ldffepwRkfzGCj67yGkW8YYzMgfPv9U1KJ71uBDadSEiR6VLVoDplmvAB4M7G8am3DSaDbCRYSChZgCO8tPfq7XYifcMJui5cVuFF8tVBetDYOcdfWTsnfeISOtQFdjbfzZzzsdm7ZbnQIE0dMP2dKoQjJCgtkdEaAmQlaPau6Muz1Z940CZXDrlD3E49OYuW0BtZeimKAfZcGbGMAjjvUmeQJyfHEBIBLJvvFEXTsARGIgAoyS2YxatUMlM8T8j9VJUUvTSTHO539dTSTj7jyQ6Qe0IruviysBEbH0bLkUGiX2xdBCywXn7E2w1BtMDRmmOkhZSwkSGp6JzrGOoBHOumdXGFPVm1CZkleQX9GH3oDj', '1557537367', -223, 0.0022, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313031313130313131313031313030313031),
(63, 'ByQ6fVLdJAyXs3htdfxznErqMgyLLw0ObolgmnHmaoEPVYjRu1fbc3y1U0R6XndC87ejSG1oY58ALKH68FjFoi3unCwis6OjtGue', 'KTGi9D0e0pue9cL1WqVQf7ynnGLSb9820WK5G4eJAWDexAAgTra3ttZkEa6jgu9HCUbJCmP8yma6jRMmdkM96IL9jwPCHHwfCIZgVxOoUE4Rs0mlU5M75QXRlKUOxMhF1pbFAAaxCPltY2jdYH9WrPtqKRnSKJqYKZJWDwTyIRZYSXCXpdUFbGoTxPdOkzX8TqE74k0rcL1l8HkydB1girGdHFqBhiPboJY9S1td3yqAMlp2pRvJM3mpeo1iCS56gXE32ykRgdcIOSRoYZo5Dxou90YSkkIUw0HPAZymSKlIcgFCV0CiTUPrqtjipFIz9W9tviaKQaSAYxSJeSfou9Bh5P2BRT779LW1Pt91bsLl6GrIVDfmtgLY737OGYSxws8puwu9UC3YCHozZgCcQgjyw9zRUV0Qh2GGxsea0EHsvBIjqLmVz8e0j8qMtKw0ptCRYgk4tzIQMnpVf9tvGSwktZDBqtp3VOXTLXOPjm85q2uoqpZYbtcw0HeiL3FYM0CMXuFsx1UdrxXK0xRj2YeBVjbRtviL34FzuVUZ8y4dQWK0Xy6xhlEycMwiyRjrF06epeum7YA5BdW6fqHCTzroR8fB04HZFPVKHptCsguQKmw5WbHATGB6UmkMQ9sp3w6aosQLbqKsgotX1P5rfG9FjsMR36AHO5ErroyMhspWahOFrkPaZy475qCMCX6SXxAAScFFJnrkq4vhgHXK5imrfhQAADZVrRTCES9rAaQz5HzLsYrdzV2EM1qhVefQj3zwQq05PPCH6e1816jyro4IGBoRCGTDz7DjoReApmLHuCRmY6yLFLuFY5JhH2Ujc44Yj9QZnLizgU3thZbSi1hvDrrAaehRcTSuBkPfI4cko3CsYJaQh8rdFExMZk3hzz3UhoaoretWV4yj2nxGD7ZM5L0Qchbzk9BbkjUpxg8rPYT3tThonZUfSJQLL7GJsAxkK70i1b9P5JAEigpZuIcy1A3AJPzMYURmyOt3', '1557537132', 624, 0.3963, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303131313131313131313031303130303030),
(64, 'IoE8twUsYlSLyjDh4pQHQ6xhJlkG5CkcJU7u3ELOQQUQsVBQLStv6aA3hMydGatc8jXIZE115ckOKoWhRdtaI72Hd5aBEz04Uz8Q', 'ixD7Gr7CpJEAjpSIIXQevg9S0SUP3IHPZiC5FyhkrYKL8vC86C1Dbjv0I2brzKEF3X0V2xPUR4dQlsLqRczVefe1P4QXsDYpurJDLpJmD33LVihBZDv5E3lUiZSjIpF1jPSeT92GMUgzT0aEuYP7sIPF8Lgyn4Jvv5mHnLHTkCRgdAqzmau1DhFjmr2GoAcR4de3egJYedPQV34mCeyMbHUQWYcGMZ161dtgtCaVwGag0o42faZr71vdXoIyygdck66m5SWJb3SzsAsAfZOZpcuthFCjHpMb1R5k4Z7rdhYLhGd0CGZn5fQC0QUXdqJ35usarZE1CnqPuDlinfxF8bzD6Sxq7k4LwZdTbQztplgK4tStvHtPyZFwzMzOn6KoknkthASOzctz2bKw11LRmE9ipzY41JQSwCPWLcx06V4gmL1rTdsKwd0XDfKb2ghe6KGhDGz51w2P4eDe9hvx5DereLUbqF6s2LXvS302i0mg9zEULeWc0WQQccq3cXizlEyAuiMRWl5zBL3sL3KIj7P6xtkOl5Sy2pyytpWyZzaKqSOS9JX8ZbbfhDBqS7Pp62VpQpu8oFDPDPXaUjup26UfmFgXK099xxF8zhpAbEtKdErl2KqysU19QAhi2LRKmXMIG1HVlvGzbmknx4JAgAuUGnGyFqVeybhbaCn7SehfvWAjpgquq9lxU3sFGWmA7j9w27pcMQfPdpe6EkthZzz4vABF5lcP3koKguQ94jzfiKfLihUXUSbst08xRCoXnc1QTICYIEiyKWCji6Isc3aIPh2i0LYV4Y1OSQMFKTnKz3oJFMUST6vRxrjVvMUL8AnEeQkgaZROM0w2qms9X2fSDuYqpGevz68mYHfHWWGKmQ2dyOojmQlK7o0MFsX7ntfY5rx27OUykxVf38Hk9vPwYbo3j60BzJJqz4deExufE8bbXknfk4FabRbalCsY8SBLqyfjy8sOmAPYbor1TuUFLokaJ1hc5TRZFVFg', '1557537084', -93, 0.6341, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313031303031303131313031303031),
(65, 'rVPDPkSFOOv4KOR2uitjoKt5has6vYvyU8dbP9Fd6Zuk65KMDr3h5vt3ghCMxbAJJdYBcRSBL2RtPf2pas0999QTCganWh3OXb7U', 'WpqTPYzuViFV3mjTAEABm85PIgUJw1C45Sl3fLGnocHhk81up2HctSn9T77ytIv7zbE53ra9eZ7xYM5YAicFYu3mqQHeOjL2snlZe01MsETEZjxkaq41QZ5qkrEOvLpQHroLLqfi3c2EnHmy6qje4lvnCV0eA6pvloQqHJRG1Byw9ZyFqjXkFAidhgIx3jO3ldDW0VQWnTshi88E74XiFHsVjuOJToytIUPmFYb663JUO95vbHj82G0uIAgM5mGLttnDITV6b6opH3pfBd3RLyVXvz6JFcdXBVjM9H10E0pLYP6RqAarTidgEpkxCU6Z6eCPWnuKvOP2CsblCRFVmVTtc9UeWumUZqiI8XloIsA9DZCGbZxgepVx6JSMEWZHeumvFmzVk0J92nrX8ZMtsLluoddeJh0nSrMaBEbjiph1OED2rSoz518k3zVxcunVSgBGUQazDHbLXOd18Cox48i25M1I2z9lfWM6zUwHmSrosPaTcgLnq8QBuUtMexhD0wlnCPfIsU6UlIuBDLv6aZK4hSjIPnMO8Yhw3CmBXP8gCubes9CGhJ3nqIwxL5FRCizyRjQnMBwwg9gHDp89LlIAYr7d6FXLvugs1RG10gjDhFH4dx0uCQKFT35MO8zzKykfziVwAOsDF4xi9xfISdbCawqdTsAfouKUuAwVzdZvrkJpsqROtrYrPS8wlFYMojyqOLvbVvTgAtjo9bRLsy89R6eIbKJdL1JQtPRkDFaT6vffdPeCPyFIgcGLnISvwzi7wKAlJHPo0pzZEjYlyqAb3bwIYynFD2ehWyGedCQKgbhAtH6XFaTvd2JwVggI9lxjKea03pf1VPl4FWAoaLyHJKkdfRwD2xedVM1Dh418XlOqe5sJ2gAMEmiLWjarhBhZtdf9SBa8kJCEb6HWgD1JXQDd2Da7UyIDowRxQ1G061PLuZk3SSOyAblwuRyEVnwbGHQOcjAKeaoKbJj1S0YgCprHkXj5i4HznKcX', '1557537224', -371, 0.7157, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313130313130313131303130313130303031),
(66, 'KblBfmGSeZvQ2vULwUsn3DgRqGVW0vwTE5ElGSqzYRqiPtJH7JYxa5c1Ru2RtqxfVRmWvgya4AICZkWw4rRAFov3DavBkdWvyvqr', 'Gv3DydnPv3xdo27vyAbWPImfxSICz2TOgDVZqHqUqEvL6uKjOEfJn9AL9pTCYqH2cEacE4QRH8RcbPKZqBFoisc97PpuJGU9vwMihjDFmtyvD29wrqtVACbqs7jfTQt7ciLggqOnpHDHt7UXP7FkgGwybhASpSqZgV96CplWOO7LF52fzGeBjBgzhjeniKKIHqTPmhgpAMWHgVypG8aKJpmsKegKyxrkwO1pt1yJKDavdCrscssMx6QeB1E0dbwOI4vTYDdXimKcxdGn5E9GIEGSPFr7eHYahcneP8g1cYIKfFkakIctg5VnqdA7C6ModdCr4uFYtr3ck0lQWED8cnwLoC70onZvx5fxFJtO9MLvMdIoWtrEuyv2JV1JxwyueQfvERDub1RGCiuOlbC4aBSbs5im3xvlitBl1Qb5A7kKPgC65JbldxAcy7WSWrQ5JZm4KH6wn5aGp68hdc7vDlH522YfddwGxmtESroRwXnvmO1kIvqwr1bRSPnuRSBbJCY8m4334FYcGohfAH7rCz2u6t9BSn3wiKQsdy68YgXKoRV2RLada0g0G1iBgMSLfK5GsVv5gJgbtbXHtIAS6jSoEqPu235SyDHL4ajVV6ZuXojgtxpoouRE1IIebcERfoHJ3htBWj4GLt5FReAO4xcMJT0RHeAIj24Aqh1cmqxKYrdYBO957tXOQVEmA7VrKxPja8XD9onGyhI9Jf5fxh2HiQGJSUC3zVXUgTeYifAuvZBcfyohlWvs9C5ZvxGxKbqmKuTbQYbbQzS77K4bvvm6mhR6w48UkjiHCZXfJz8Jx2vUnP8W4XACYP16VsY8gjxXRmlc23tbCmvz0LyBZfc0XfxZGJafAca1tA92Gocu5zU80Am9iqbhhwrIQTJehWaZsHjJIChFVEExnhxxYtxp0GIllUG5lAwQPHRj8IJJ8COQ8R6Q1ogq6ImRfO0PL6hxyzLKVHAFHsj1gi2ZrcnjzDoevzHqAto9Fj45', '1557537551', -212, 0.6409, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130303031303030303031313030313130),
(67, 'Eac3LCl1fTR5qqMt9dLUMJTB9VIiBhobZKsZDP2VprHID6zAbJeglSKW1pLmwSlJHd5LUT5HYSXefCIAz93uiS0agMbkOlGbLx6r', 'wPwmTaxCd3ftkpfBBKCgS2Z9sHpueKuZwDkTblwTyk9dtyPAivCeR99RuXuF4QfpUlviSpS2huqQ0ALrm9Z4d8GqU2WJhOnHEU4zVkB3nw5lTt6bODJMW0BTG0MFRDUTMm0Il8HXRr6IafMMC2Rn4JUdRR0tOlMViFjK8PbHGevYOUShOhlRymypnzAa9X2RaSZEjm2lVUh5PqjDnpecpRBuibyIRoFDqX3rSOgRvqq5dP8SjqspEd1rzEUaXIGj3Tt6M6SfuRYYZ6kYCj5vgsPge0BtnX4R3HiC5hRvQ8RH8fUWj45tfzZYgeHEd1Qhqot2KkdDyi8kDgRPnGsjBywxFkaIqZYzbY2jPgXEElMQxabyPcc2lqr0sj0E0PtJjpYte42y7fPdOXSaDAjCsaJkCadtWwmMPIgu2JwjY2dsszWDQQP6WMowaTOai7CHGVWpdinWcH0zt6o0oYGrPhrB4uLI0zgvWZ1bKIBtMf9zSvdelZXE3DRylY7a5UhbzXrQG2dRKEFsDLqlESxJETEn1jPtw7EIzKfnZdb86XzcLV0klCxIE0P53xVEmcq9WrqLEgxgP6RPiWXbpfVy1ZmEsDnIzayrH1Z3HchhV9ukbQgVRKEhKRh7eBdE904BQsVd80nao3wHsBYwF8LSSBzrosqs6HWElMefXFRXfQXW6g21RohkldeDXc19ridzdZV97eHzsvH47Mtmqw9FdHhIQMZH9KRnt3YXEEX543R4vbjBmxoUr4GF7gk9e5R36ZpAAWxt2snWhsvHFp1Z4juuMC2sFifA6Od7T8wJnJhGqB5Gmb0W3qEcPQ8Dvn01tvowycTT6UyjXC2yqOnOpqcLeXAHIl9je4WOB7BUcWdPQwlhSj7v9i7e1VqDiaEtmwTW2VHMFRec6i3TGGf7g2pyaLDsgTxwSQcZQBcxvDDrKX7nTWJzKD4KHue9AsOrJ2ST0a3bJjpyLszJr5BVB87QB6cHiXqfZ6XFyAhH', '1557536065', 385, 0.41, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313030303131313030303030303031303130),
(68, 'aRoYn5R8RvwMUzw9ngrVC3mktTT6jg6rX8A5HYtesJkCyVfsQtQsCSaRM4RmEy0b4ha4oIscrRujA9kDEyAT0ymgs7dunHgOAi7V', 'smQ2OR2U0fOHSwIbK8Vxv3WvtKVjucrEUSzKxIWlMeDDrlelTzQGXR3oXEWGKY8gHfHlEsfFX4Rrp48onT9IJwwaMslXoCdJUvcP95UStOr8JDnjg5QCU5nO1783p9E6sD4a1zWWoopGr617v9TpsvBkBEh3OxtkpDjnfXmUFSJ8wr2M96k4nPdHz4OXzPFrIwXtRbaJkesrZEpk9V8AG0cYVmHFIYfqphVrRikrmsxDOJbKwBj0m3y7DwZifZchtVihdhS1Ly1G1Gj3hbShpZh8JyDO8Tw1Vq30W9MsywRCAwPdpCOrQMn1dtEboEdCJOaA4T5MIn4ryfHgUW7tCsSM4g4q3ii7V4E4xvJ0f6E8TPYbM9MnO1IqhVQx4PJtucwpp0M4aHCGAhBZ2dR9mrWXTsZxsdyHqcLCDmc1rbW8FCCEF9hOhKykRSvqeuLOK5oIgB0R6wFr8Q0cFY6lzXwAcapanDkMrQoGfIay8KKCWVLB3FhJfZTJVkGMTEhEvtKwBHH8xRdGaSUVOeQ1jUCK1mliMyBoXYvflzCzkQ4CJHp5XGLbIHIDuhnF3kj0KmCQsjVUuGhqHqi8q04dwocok4LVGZntWB7jWXz71pS720y3jcK7HW32yIx2HvPQvJZDOqCbX1PGJscQygPUfnhy9gH26UE4sKeS3M29dua7POcvcdfybFTW8FeVSaRbLDRWE2QYSQTqh1A4c235tRSdtY8E1jqasoRVD90FV4YC66ltzIeu9Velc8pixln1w1dL09xfjaqFj3uLkiMLcQWmia3MqfGKYwYuJ0sH68gBTT0WsJIVCD3fK55aH1omMV55RKK2gZuqRBT0W32Wqkx1BStplEsRYazxlmpeOH47bb9VQfIRBSoEQwgxmbVcxirTcRsjHj2FTDLH5jLD9jCaq4pwKzJrtjG6rdSgZMn7YZMnIgdi5BeyotXpwRXxMcjc3sF5E95qqcbXI51PnMcPJLQ9F0vwtWja3zQM', '1557536767', -581, 0.0227, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031313130303130313130303131313030),
(69, 'fhXl6Lce3QyYsX7Mb1soxzF1pznm6sDFse4DRlKv6LiZyYLh5VM7Z5qI9riPSrtB24zPYMGFwzoS2TMElGtIOsxkfbA92iGp0MsS', 't70GkfSDTFcUZlyd0I2MJMflz1h6kmIMmjFBuOIh6kY21S0zyRU8BhiqtCfF2PmzBnJn3eWMHS71pgPOvS9lQEHnL6A67anfeja2YxybFhDUaw1VPJLrsTvcqripznKOf8YyhIxr1zxDjFAUvvLpr0FUsFoBoswdCQaYWLUAJJPhQHxKz89fO0dtSLREBpEvnoIf0HCAQLtLIASu1DTYxS8XEKGAcfaGuREpqvIujGv90ny6Q10yEBqgOAUp9Y3I0aWrebdf9tUoD1Dz1hv28e5slku6txjETmDloJ4Tn8FwEx5XApnn0I8xfVsEb0Wr8qG7WaipYFQw3XUawpCAf5xuxoO6glY7Kn8LSsUOW5moPd6hQieGRkljcKvpIylELcXjbDS4ing9YmFgw3eEQrv1eYBAyD759T7HRHec1xxLtnC7AGBucq3AD54EKAfnUsF0UCYd7zbgnhWR2cldXiY3q3UAlqKy1UB9kq46zudDD3EsRzsO32gnAU7pi9DAwdVb77xSqhBThHIW3QYhxEVz7CH5CIUwppB5iEovEWo1jdajBYQCo9YE2eFEkbxjEtESR6C1ftx1HC0xxY5QDvnBjH15pwxZhq5wLoepdU4TtTcDSRGVfKbrY3IoSIXwhfU34zdFybYDB2LCyBGTeSl80hOAHPGWFX5sKCzPhlfg84IuCf4JBRTIpnhDULQfpvDJOyiQnnUK1W2e4KOslIOacm7AuBlpxWzTdmoIRiV8iJJQS8X3rs6umdkorjes3hTV12TuH5knXnOj4oqvX5KHTXV5LUunXtyPcAJ8VK6vWUgFCwiROzOLOwTDtm7bbxCBJ1YDwhfvli5Uzwx52XdI50d5yH8ROt3gFkz2uHMn7zh1TpaaEb1yJmXo1UwoOiRMYvxiQZG8gIR0za98DibgLA1zR0hPb02cDyUry9WKLJORDOwZ0iIQbGuD3Wp7XyAtGuDrEbBfFD7A5igGJ9DhYEkzDMVh41wD7iJl', '1557537658', 891, 0.4793, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313130303031313030313030303131303131),
(70, 'XpPcUGoiRUXB8vxoAuOkzkQEVYd6YT2SA3UG5XTKkvAPEe84V54frwwz6w4JcyP0Bzl2E4K6c0DTzQ6DCxH3HAzlDWigM6Y00Zah', 'A50jqn3QRjq4HTIIkx10zgUDLvuSLfmnVYCp3BRFwE9na56gkmPxSqTV7MoCUoXmBIBn2I1nyTez0bSGH30Xxuf3QWFfqqTeFlZdoIyWYZHCc80ZsCydApY4X0jJkjdW6RIX8AtpJYxzMYv9A4un1d4WpUl7A5UyVfRwfkLIUPKnJFoc6nOpPUyIfGKmeJZ37ul0JXqXrxl44gE7Yztj0spmtmwufgqpFCdlAqt1l9iCLIiVeDx6xTDS4UFuDEfDCDsyQOTYCCD4R4jARAYKsbfg2jcmpXrKXw5Er2GMiYmnjgG8RpMhLmdwnA67y51JCh5CqaRukcry9mrye6YGrpzF7KnJ56YAGUrsM9o4JiUCljARZFwYuljGcO2eY0ik8pcbw1jwwgKyX96177s7V9pzFH3BeL0XWMjLDKBRF7YnTRZ4CrK9IQTlwusRTp4p83Of8ng3dRy3drfZuDr3TnJZJaeZUXvLHbFA0Sj87rvCVUTMKHvQrOYulHoZill0DcVOeeI5pVR30fTsnDXum7zTj7VR4Bx7W4xUQtwU4hzmsrh0nsJ1Fiy9EoPBcK76EQxSQAGB6uEyix2qKaVqllVhny5eIM3WHsUHczebvB7BuuaIvItHohDitBJICFnG9YEqXr9DizWy5kGTDbpRP5JcWvL6Tr5iYlL13brYrqam22zX9uITBKeWOjalw69MaBgtwO6aZ9K3mCQR1GpMMj5A1YWtxCB9IJ8Poi9fTKIB45sEhKszlJj7Bv6tX1qnFJn3CEycbe439ptjUHUeg3VuAVClHiCtZC08fUm1QzLmBCSSUwHKyeTLXdw6RrcsFn06e1wISOSxrHChhdTafhfUEmOIns9kJ1mWA04ihUkBDFKA2MrridZVKpsdgms4bw7FkSZK4TaxevgKaenBH15OektAx8aF0UegrBh5eJnmbd9OFxGDvGyz47TQbLf9baIIXeXhKsY3vOpIxJmxGfpdiLEYciGvKiA4MIZm', '1557536734', 801, 0.7796, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031313031303031303130303031303031),
(71, 'dg3vOOqjeFDITjOYAGvJGiQh25ojWwh2iA4bqKRYaYf7RIkQmYHR0bsnDkc8BTZlKOrJqzEvs9end1eAv7hQGXslCrmQD75xATd9', 'OgRU8dzwXbvd18eGKzPcZrUq3dxBORlryQpcb8jx1daHV2yqc5zUIiPSQbnxnGRCGhklBXpqu8c5bOf21sGuQ37c02AlkoJFcBDnpCUclVAkPskwdIbYkELowKb2EZ0A4OkhAaKQyzmsRZLSLR4jc9Ptrm9AnrDnkSn48BZla7wsfnA7HRiwqweqIQu2rLE3WOPI4UAJ8w3k0EMd2JVC2K2gnbclUZ2BWCCfm5y0tPW59OmcIuVA2ScWppiwJ4M1kkOE28V8cZeHFPj4M8iqoSJxPvKAW2Xj5TmX54D9i1ScyIDMeD298JEZBuAwwSrudli5vSK3LXUzQulo219JftWjLlOltzkxHEB7jxeOCIiPt8pTegEdI5Bwj4o2PaAsARh1u65rQn5WuERfMpwyAzEAdFmAwCefQVlO2wjYqVeWT3GtJpLLPW4xu9G1BWeVtSLsWQVlpkKPEkTA3inSrcSnaupk3aCstGAZg1UCKCEzOtszJ3nQqj25cIuwTfnTRnLoX4fKtMXcjuoqOFKFMizEBPYA6dvbBWkFZ0ZLzPAGdoIafbuowau6nMOwF32mJogQpO5E3JB4taqL4zBZDUMqxD1kCKVoeHyRdtzqTw1j7PuffP7s8wrD5nB1Ylbk7UfLn2q47bMr9lWBPWZMZ1uHZYzzFOO7mZjxXsEzHIXrxJLQKYe1enUEhrU1K8PM0VJcRLgYF8sjj0YW5RR6QCHuXOCkcldk0JxJaXee2qm4r9xXLBQ4PJScY1Hv2qYKnqI8Q0AnKADGYbuMQedVbIpLn7bzfo6380hpTVjoQCibR5OwhJWDVAkea61vPeBegrdzjIqhjxky8Rv8575e2kCyjWekLXugKLwB6pU2akIOLuzChnzGwWhKRFP17wKcDYdvhYKGnZvXM12ZQvr2nrkQKhMzPZoZT2ghQoZcZwEXbpRdMwGgCOJM3K70UjpEwYHXKGAAWXbOWG3j6ojle3xBH6QjlwMcwMvt3SzR', '1557535999', -854, 0.9237, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313030303031303030313131313030313031),
(72, '6QCiMaijdaHjJkVvbByCUuGSJVVZ1ombBRzaRMFaA9fT9qnzozGVE4faMRE07q0FvKUUiipSk1alXpevYpc5MvbjdEKUAl23LwAv', '7FxtqLsF6frjV758hPul0lfEr8riqbFZiX2XVn7SCZ20gHl3a1afbT6iEMdqrH7lS4UhMSaWxzZyYaZRp5e2IjkPgkmqQ6XzO49u1ezUP3k03uZw32EGECXceJTiBm8G7WLADtnItp3jvHn43RtdWOUsz2M3JvHFPHKyCAxqvC8ukM8uqxECCRgBic4FgxEwTl8oZA50VJAyxKhMb7dUFMZCoeIaaqZgjRS7Is0sHHqu7AMWjy936A6vS9JxqdGS8e0HQciMSyEj5iF0OSr5UgzhHX9M4RKmkuubjOWZohe0pTXVG48Z5PqVXBVV5ncHTCmwbi04jTcy7lzIX9bLCfEqw84VtL2WQCBJqFp1Amx0cFzoy5CqyygPuyBMf3e39veQ2UdQfHfjETYXzUqWRJf5RQvxocO2QgeO11nxhXlutYImWABmwMAez0LaVdJUUUADn1V7G2OyGXREHaaDzIkfF2qEO74Clplm7TQzt1DugLnPPB6O0wq88Ws24TLeaMsWeC8UDSRietgSkXpPOcVTZJRhIxQIl3WqIfM6aArZy4wMd86JZKLwcpDpJ3i5VbPLzJQb5cpxgw9Asc9vwb03OXMp8s7jRb4ZP6f8mFKZlRag58zastBrLmjhUIjqa4G5ql3Y11siO4xO6WoHKEzH7Dd22STpRPG3psdE4fytC9jetEz6qIXQQOuEyUQgVs3TMrKftl1xQ7rwee8ntDERXR99sM90mYOBvjFGfjRtpWWGlF4xUrLJpKawIzRBblVcC3Y1pa4inEQJRZnzH8fvgxzLmdV5nApE7FCdWTEZHf6EJb3tSF69tdlUnJnrXJh0ZaFiRuCxpHJsZf7gq7kF5KuUL8cFSJwedw5f8YYZu2K8BcxVlpX33a1LxpoMcC9jPLT5OjFiWf8FC1lrEAVjorVwGyYLTn9hPT3MQxLtLkU60HwRkDgs7Bc9dzVCW0v8bSAmfDexZi2oJh68nz0tdERD6tfmovgRVJvO', '1557537451', -69, 0.9115, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303031313031303131313030313031313130),
(73, 'y8xySI1hOn6mGyT1nfXYcUnr2tO8bthhwQqBn2kjB3A8wlhg1T1so9SUv6slIcSYRqGwge1dLBrLK13o2psPYhJfnAvpCOQwyTkk', 'vj40k2FhlydoqPh3UiZsBWVmVhbYDdkZ8fvEflhFkYJgc5t9dbByecIczCTh6qIx84jbxwfXFfD1le38UXBwdjTUBRYsVvtWvKuAezB5opVDRg00YyZmzjqt1Wrw8tCfgk3Shvk5usy8K9kJp4I5jalVOVhsHj8qoLZ1HjrZWmAv1V1lerQFqVDfWLuhF11tU6i3uZVJO9ZKEz6PpHk9Vwisuv5Y0BhoLiYYFxLn2PLTG6xbZQduL1lwo63wH4Vb2m2JeY0UCmVT5umpVRsH1nKuGznYMoVREiso9hBiALrKQLzwfI4OCCyjlX6hfBjpE7hVrrAyX3lvZV9vXu4LBJI1n9bs4G4P2Psk7vXGEdC8vX5m07rBYJgAMgEwhEc7Mo1BaqFHKghCoQp6rCbkHBb3zeusRuIiVQWLAeLAeai0FB7Hf0iVPltnJ5HgPcBlq9fOoVgm5YHfjfbcrgOojW8zgOiW9MRgilXHzt70iCtnkLDx0oFJbrbEbpgwRfu3yp0t7UlvUaCnIbsMWoVWpPABsTAWXzvIbmq83cWUSz9furETghw313oq7ejgoMThbbeFlnVadS30DAeSW2w11ay89soseSEGySp41qhjX2kC9BbJ1FURna6HyySvqQMZjrYm4m0k24Z73vussbDz721alxHr1FiarTUvua7dvZ1ujhc4hyLaeLjuvoVgYnbdWcdxiRAZlLpJWXgysPgDHoYG27vWiWr8PoUrtorCzqbSZsIV2W8YzT1LWHsv0q5V5tWe1PF8aYlSnRx9YWncOfqIebOW5K6AHpoTW8hw9nSJ98JghQ0hquexTxwgxYt8HecpfjgMuFLuhhjfZAZfpBofVLBrn3fy5VnPVmBXdQ37Oig63em6LAXPkS4vz1nRQuX6YilXjSGBGcAQtJ6PvsRh7QVraQT2YXSfo6rQLMIZYYhri7epCc9BhG8f7yL4tgbhcLXACz7eBBmVunIS7POOPpIXr820lsRbmkMe', '1557537091', -848, 0.743, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313130303130303031303031313030313130),
(74, 'C8Oh3vAdYjRTI1Fv9BFMBwVYVK1KrL3m1wCv0vQqdFgQ0u1XeXFseslCQ4C9pbzeMOPCjoswPV4EFQJfG940eh999fApKttZXWoB', '09ruO2emH4PrwePqBZlyPiWxtDKBrYls4MPla1LX7ahuIbYImyUQSeFyzFp6lSFcviy3UTGoT97qj1tUu0P0i2Mr3AqtBDmOkFGE1CZI30kfgJmX0j816HgdUnQIgirivVb7vfDVAIVXAjCRSvPXgg7R72BRhPTE543smJG0ukTuiLfE8zSHPGlmIzKRFdHT14iFB66WMOeXn7gkKwjmJZWKGZiIruVZkWVLdlUMr9XfQkESKl7U2aX12hctzDuY1HVJds4ttn2qFppi82iiIehaKrs66EqQ5khzzsB4TtuuSmxATBRzL91bRt7B0yKzwQ2ijjwvFrkqsc4K13MJcW74ko9Ygksble9Tp4PQPixepVWOwm6LZDBQabxeUYwExtDmUFt2m28VJucIoyMFabstoQklVuY16BvHLaw7gC6urWQwEDQrICGZZntljTOf2CKV0xX4y6rVwiRchzg6DVinYM0d5a0mmvn1CLJUds9eZveJho5DX6gDj5UYejzl3gnZBTUBfFfqPA0aE5g3B9CL2fbAKkwc7TJPYTrbELHt1x8spEPkE5lM8hP6DeQXyouxHKmCrKxqBnDCx6Kt5TsGAcRsU0xxmMB8PuEWBBKey6wF2q3vTyXrrZgIyEB2y26Bi6ja8klVTFMAVCJp47M5FD2Qzb4n8aYWaAme3XjtA8qoaGOcBx1BgbbQYzTC4bdapYLbkpEVFtr4OCeRxRCZeAHHJQ5In3Qf1cz1ZKme8GPBOr2nQ2BgzTBsSZEH4PQd0kJI1ZspYLA2b9dMv5Woi3T5o1Bz8rc4mjhiq5VtaIIkXIL4y1Gpo5xAiVXizWWM6bcJd4KpKyeu4aHdZPMiS0yWyGCUok4ndVu4nUYeHh7xyt1fMug4IMYdckHozAyQHx9hUDyU2RnsrFH9Y38HXrJkdR9K9Iqby2clPewtJj1gGJKXvtmdxZUkBfYZ5IFpOoBj6HRUPE1XkGcArMWBvpqcnwa6pBiupDp8', '1557536918', 812, 0.4183, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131303031313130303031303131),
(75, 'hSptkv07JWXSRGkWwFJ56misoKzQMiEp7WaUHcbwp1i1zRAz3GGXa0EjLJ7pco8sjUjcsLJOsX12FTf5XA1FBvp1vB2SZmYpUJPm', 'AdFYTJ8V9OhrdmHhpTwCBlkc9dbdRsHp5wZZGqBGZAFHR1MKB9156YZoFXLUb2YkYIEURZskdgsPSwe7ahUqYs2tAxJsTuA8dOIFppGQOMBPgX3l7h8DcPrqS14UYQBORJ9kkHieMd8G2cgsqaKJP4ffwmMdq30lRyYSDThu8u2rblPr7VKHObpWzASog8KLef9gjXCCREj4GnLiby8xaaWwZGlss5T4ZPHxmSmDWGYzAg62C4SgU2SZKFbo3Voe7gDHMFsxpBZXR3ODrrZR1L9jVwod0DihBAXJAlXigoocuGS8CHukuoPvsfZTkdxcuMCDKUOXu4ajvdjucQmFmTSAmRWs3Fb0JRFqjk2s5AjjVB9I8QBTAfhxDkhT71cEnM75eDCQ31QbFTlPrIdZdu4mjF0czezdnBVBwPB7oiJXP2VO9tdWcBf4lU5opjlCKj61dSYf7s1yl3SFd7AMyBMDK0xrCgtVvTEigOGgdvF4eWbpDCkvisH6xYooc6Z6DkArGBO9GpHqvIT1s0r6pdZqGPBc9PS98DUtthhVxc6G9nWuEgWzUPECexcTuo841QAnEQ8yKSSOaTpRdoPVKjHH899rcRLRgUDadgm4mp2Oyie5ao480G7EqCuThcMwTR4P8zYskPyFkyqcthGeBVUt5ZdcIoa5UFTlqKWIF6sqtH0ba2FcA25b7cinyuXuhm4K6OiSogJ3ZJW2eE32W2CKwiKrLr4M2XC29I2TujnyTChLFaMKGUxdjhBnlhzY9nybzx8LYdpV9pYnuyVlODPxs8PciZs1EGSdndBxO0ObM33SFOpOiguJ0RoTDzIXxTx8yLtb2FAiPzudfXh9aJxPUsmrl2mIMYBU6cHGCdJidYjsbWwno7WLcXHSqnmopU2y2ui5BCgaYfvyuQ9s0mJBRhpbSzKWqIQ5kFhlWUaV7o5xbA8q0tViTvvnHFvmOp2u0JDtF4rxDp2pfdvhmssTiBYrVCEEyZAL3Emu', '1557536933', 909, 0.9374, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303131303030313130303131303131313131),
(76, 'wjm8GIf06knk5AOnusaQFqvXtstoe17pO53Jv7nAd4EEfq1bra3TbKPYh9W95OwFrI8eHmS3GGkSLaBSMKjO4WvSsGOMjtiMsfzA', 'guJoybnXGKzqudXAj1yD082jU1rMREoPcvZBMxMTYeVSzyWgXW0iXqDGSqYECVAXwnBHpMzICACb1KlOWLOQeBCWdISpL4aVd9AFoUKqEOImRR6ektZeUEY6WS92h67LhLYwKTi04Vbq4Oew53xwWAH72VOxbZrvIhHeuKdrRT1mDDJHcutFnoO0vPQVrK97wEQPBuuL1JebAlCJHOMHb4hLmCea6pdAIVki67aZxsPSXXTFA0sBlC9pzh0h7XEWi3cDWBd3s4MqDowsQ4woU3nVbPahvkube3rRcYC0Jx8RIJx8s1W3PmYj9eGahBGixX4WOdpQoTQaaXVFsQLz8xWzuwAUpKgheG4VMkAxq7Xm02G6RwWZOAjIdGSwXLd8ikqK9j87QdoqdZPoA6vgRw2JjIv2PFwSJQbtTb3zCcemMPkzIxrphk9CMDxp6retydi40XkTM3raKwdBeRJr50CnDqWEJ5iYJtMxux06kL2R57tw63qlfyt1R5ILKBKkjBETm23bem0pMz7km8u8OZHxrCSL91zyfBU6Aos8vQlRSV80Z4VMIhjXq2oEVhLEzuwccDfWbc3ak7vxZTIj1sicLkio4qlDgfwacKqEdq9l9dhYmzUIHwDkuuz1ArivkTT0yKYeCwBpmapg79s0KrnlAwewtlCfLoDIiCTGourlX0VqfAoabfte4rfUJ7jRzLKjpma1ylEaUHOtKVHbYXW0UeE9oLokL2fMTYQd64fRei4oC7o69uPD8TqgpiQGka77KsTi0FdpXKHcTbrSHV3aIqzgOGEVhamlZQifi9xQ15HSv7TwCdDxGQ79zYR2A3ZqB454Wug9ti6pvXG4VoCO381TH7q1hOZoAbgLZIllinRQTDSsArZWLihve8nSlrlfWbOloPPpvl08DdqJDnHYRkX182HBMW6YG3IObOEl5bviLEmU4bPRkfYooOodBkdyOM08kES93TolhYFXSRiCb2mD2rtHMAH1ipFk', '1557537135', -558, 0.3001, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313030313130313030313131313030303031),
(77, 'ntEg9alQ3p9goG9K3YV3mIzm9UIpLZqo5Xh4pepBAQnL0eiKrmJiiIPAog8m4sKQagiJ2bQgw9ZaYDPDdDXoBBrF0vVbIOt9CtGh', '20DOPkYqjXInmMvnjmrDZC6TK2ykryrHpGQdunjz2600TOsfnZPulBDsa82oEwz0agouxj3A88EvLHMYOuyc5tyVW6Skem5aiHkDY79tB3FT3tuzCTFOcdQf6W59c4YdO1CFLMCesQ58G8y4P8agGQvrDGFQwEe8FdjzWluSFuRfHE0qng3BxkywyhCoe7SXXimmuLIog20f63QEkhiPMGYtQKYQjrTByeO1q5jMfrw8Sk2LDaUVoXKiu7G9LEg9y3BxIgi3AJqS1tBKkVUTn3X0wkLkAJ2zXKMWojEbjUHuwuyBoxhIK2tAXreoOHaSGjlerencpXm0qoSlQ31ruUo2Ip5knxF2PKhnS2u5TRnnGazWEr82ADFmTgi8lfy5k5ApFIYRIDMCkODqQGDv5glypZTPFQP0chhjQhPuWiyJlk6MpPvRWKoDkAQnnisOslk6oH30xQIJJIV1lQK4b7OAB4bPsCtt5iKKj0EovffCv078EHmaOmAqgpU8VQR156zhCbDESx9mE9G7ltm8MtL7iDZjJVBrsOKGifZOAHqZbaDYp6JY9tjHHJrnWTKJdnjYlaIPFJ4u44WHRBtGTke9uIhjwIgUlPf8LYPH9E6SlQEjFZBh05vtEyu8uq9WR8y9zEit0ru7ZuJOSf6KtGbGbi5PP1pSIke4Jca7d7he01baqnY6lbeK6T3nwt3FZoiQiDoCPDqeop0omndjAxDHnmoPBO3kBlIudXZ1M4W7aFcuGgQpcMqx2I6841rTBaw2w7Yh8lRRjPLtn1PnbUBf5WcjU6ciZRHqcakqRv8tPRIlrEcdxU9Pt3En64lAJqgHf63qWxMZIK35TaXXhL4gg1ujGURLSScSFUakqsOmZwJGGx4wovlAqSH7DBJPmbvUszD5hfdBCaPaTOyZT71OYAiOYc0JfncOD8uIuVZIEGgwsXqkJB4SScgmFECwusfAcyIf6r8I355KoXFyZZtP9FBOKZDc8oGf7SkD', '1557537525', 415, 0.5067, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031313030313130303131303130303030),
(78, 'OmhSHPiDAdgEP1j7dc2K8duLp3jUp9ylWvRRozhBzlrmRfpi3hMavVFb56E28jQYtwOHsdEsWkZXglSmffVsgtes92o3elutmq8r', 'UIobFcUo2kHiQ5qDoVaByQuXHgwRDcQ3I6wLMXbIcbV7MMjGTftDmvYHx3V6hRUxUm1ehyRVJUvO7nzBLr9xx4QlLIGdimlTtuTz93U0DvtmPQdo1vdk5u4RmgRdGLb8pu8MnpjWXZPOUae4EsDZ1MEfkFn6s2neJnKTZE6LAkw7mnBCEgsvjYDvGWhQBbWdq8KRZLhtCyCicsn22YDVZ20Ep7ys7dT5uL7HlKP32E5moqvkMxcc2WIFvacY16dOXhSp5CJvPCViZg1vVZ8lsKQyY4elhTVpJEZ0cm1QYt86XYUxpiqngrjkPRCAXwZUXVttFZG2vdIMgyatiu7ir0aY2wpHW3rgu3lPxtJ7pOGmY1Ogxyb4ZqotD4yHlrgur3A2LQ94Hh1M3lPXbvBIVI0SBt5A7IsBKXd8o5XTmDJ6vyctbkpfdUZ8WKZkfS2ArGd6nc7AoRPilDWUy1AETWkgFVgWLTZrvkzXJbEaOWilxB6cjA9XXT4hLYVsEMibWPkEt3zCAX8h8rBnr256mGabfSXQXy0MLdrfAMRWKMl659upXlo8amDX6El5zd5gWsXI5pw9hvXMpJKlPx52kVuzjk7cAIwCwAO4XUzec7Ul7co84C8OTlI6VSgcZ8lRsB3hbgZbtAeMcwoOHyzsOEktThO5KoxYLuFnMvL08XW6EJMlHnn07QjKeyGPUx7WtfFlLCWHaa2huPxL55yoMTFTWIYsqz4OxS2b8CuhzgvlGMF4QD7GQPoU3LCWjsoxYnMUStpJmflhhCceY53QgCvMwFEkzf59MLUuZeG4w5y5ek5hspmS4iZymt3zeTaDZ1oYtQmg3P9LyVlclB2LeRQcA8QHfpB0x9gilkplYp7lgnY0AF6yMh4HbFZGDOqeuavwzHPifTrLlHZFdCwdHAF695vzp5CkO28BbXB8Ufa5OVnderkJ1LEmvnpjxecjuO8zb3MPXsfhD08DB8w9GP0vexGW4f9byquqx3kp', '1557536101', -177, 0.557, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313031303131303130313130313031313031),
(79, 'QYgXmH5qJJJwkzkrY9tV0Xf9hVfR8xygqOL6t90zaxQpMumPeVbwPjmJoEwbioL5nvE9ZsjBWejbDhL4Syf00zRcSgcnQ7mLH6V4', 'SE0v8MaPSXxcT5GmzHJxJKfsJIjkpyyS7I3iGdokstGbhuwAvIYKY8Ep1cELuTzxJFuWBv0IqTd43KIHPAARAmrfGxn5W6W5KuitUGZZLb7OcUiGvlAPzuCWILsgMbIv8btTAJl7ulorIXexzZYFXtaw8SVkZ9ROTK2aDF48An3XBPyh1uHnFl5YURLgzZmY0cYk3tb24i4jTAgTQSPZM5mi4HZ4wGf1vwhlRaEMV5tywfkm28krhH2vBqyKRhvXoHWg2Hvq8JfGxLMIAgcM8c5zv1wkyJ9JDM12z9JWJhpGXaBYwgr0nyuwMvSKD49pgIrGvrlkHGXyHrO4R936ZOhmsRz46hxWhxgeOCkB3ZQjRAn3xU34YVs4u5FgXminEfrCtFFJL96XmBkVBxqUkU0DUb8j8krFpO0UwBpKSbKqgvDD33aC4LV5G9YgIaWQwfX4WpvDl6MOwhlfRqhdbvcpQ0b4FSQT2ze6K5ZpbTb3aVpJ3GMGF8SCnILK0s6OVLV0XDQ3pxYbbrS6CPE2wCVGhkJjHVJBaQZLt44y057bzQGkyPUfLZkEzO5KMfJhMMpqpnFWZuD3l7TrSHwlne7te9M4fs8PMBdYHyEdkMxOugsqysvjnlibgnTf5xTfbionnB1m3WPq1hphC6T9JkQKFtljiv1xVSWEqxJn9ZtVUbJ14BCStcKdssbfSkxH3jTORlRgBUuibWqCTZKszW2xBjo4P3qKyCcQE1k2sGUxPBv64ffX4yHJ92ZJ9CGFqPTJQzbFGlFFQ8WsDn7hX3KP4DWjS6jtGTXwn0pbhTPFewLGznmuapaLl7iJXqk9jQnbii1zfilx0OYOUgZzMEWA0s03oDHGjEbHBt0QAAfi9WxMA1YyLL8i2G6feIt7Glm7hxlYjKwVEYuDEElo8LFSrMyirGBprVVoks5ZpMbpySPn6957SCAkeKof1v7zzmRxKgbTTHdMPDvZUxdHZnSEoBB3Ye0C5GazyWED', '1557536866', -330, 0.451, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303130313130303131303130313131303130),
(80, 'shAt6MHatZxRVlcJjOgxWSQtIuvhW9nauO2QEVzvktAXQXai1hUldWUghXJOyGxaTcS4BXPJzR0T7pvJ6BV0QTkVcelbw642Dt4a', 'VPrPb5MHLLd3xPiyQH8rvpksSoYMMCD9BzqMacYpOZjenU4YdpkRbsGAAyfpjDz1FcODwcvZd6LiARcgYYT8eopBGATUcxUJ7Hxlg4qr04BeaGHr6pPiEcwuavVhtjBmX6FWnOHLaVP37pAuBJ7jrS0g0ijw7YFQ7lapSqnYGDpIsZRptXOeCqRUeW6E8u8cGt2KIUq3BfniarucJ0R0bR5pPufEwTWqCuhYYhQ0TIHIfMuSmWiE6aGOOULwia9xXmU4zwCPx4q2G0TqmL6colF49cFhriIwD8U2yDOwzivew5DQJshA5o1dSmWUWkFnHKgSXCl6ZoZhJ2M8u2QS8kKeYoBoReZ78g1AFugyLnPejSijCtL2x8R7qjCL70GIWD8bLexTXe22gAbm8M54lOkSh621LDKc9UCEgRd5tWCIBarh0ZLYwmbwvLO9MadyH2u08lganxAhjC54g3PK4Mp26iW9by2OE3JdmHF7E1VIoY5JT0fp061q4It1WQeUYVmjZWsWknD2QbtiTP4Xig0Gp0nL5ZOTEFmhY4DDmBIdFgeHgvflYkmP8aEoB0KKIjI7k3beLHchTdm015OC1f5QecjTuU5taPtQ4V6FxF2ds3Tb9wJLr3cIH7lgLFL5ZcAqbEn0Hwf2qLLdER3OfJFuyUJvpkRzas5UEh3cffQIKl19w2IHqiw8LzvDqRiXJAWfwL6h9RMhsOEXM7MuYIKEn6FDPf7aFAcsK8verk8Hx9FBp3d9U1m2lwcvAvjhZtPynni46FR10m39pS1FccliGO6gJETgFePwmusL8UXdPrPzMzc5SfGrpYnTgGQ7JSbmIu1lx0oh2oWSx8KmVbqsv11n9AaRbnX5slVMkZfdBes3FzGvlZwlZV3KpmRs0K3Fz6d7tQs1zWl5bU0x9F07PHr040XXc1x84HTk1y3HUwB136GskdRK3ne85wniK9ptVcXoVa0gBZfOjaJeSD5gDVn8tVcwG9EHayll', '1557535818', -46, 0.1888, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030313031313031313031313130303131);
INSERT INTO `test_table` (`ID`, `testVarchar`, `testLargeText`, `testDateVarchar`, `testInt`, `testFloat`, `testDate`, `testDatetime`, `testTimestamp`, `testBlob`) VALUES
(81, 'GkgtX7bTMWGECkU0fcpD12hMLO8bSZ419xD1XXZp68FVYBOKnlZCHMhKKViTUd9cYCprjCaPLb24GL5nUmVtLqDB7VRsjjBgbzxJ', '4cI6P7K5MPJSOgfddXokRMKU6hrcKp3UcDEgfVSYfIKf42WP1jvVYw3eg8E1I8XWHWYi3AlI6vauHG1jdz0ns8IrMSfH3HcSz9Dcd9cmkbXCIctFMHTIkCLvHsdgKaQFPdHYLzqTVI5C7BiUIH8Xy0btZXyGQvQlsa8CGT2hT8CuTSu02AJ2aeYiDig0iIeTsZWa041xepwf214ZIlJ0al80Fvmc7OZjQF8yF7mFWzMSy31RMZ7RwlGz5BPgkK8BAfGRI36G3CrmrXkzetRygdA2SAEcUADLIGC09RczwwtJII2c3SYanWTm2rS0SjwPd1V2XwFlnjSZmm6Fe7tCRzyyyasGcTMJ6cBX75wZAZE7nTy2OflYI4BDtLqfUlqxlhFIFvKucwO7LhngJgAbWq1AKfLGZGqdZd6nAOmTaXkZxyzn49chzFOppAt0rUPKZ2UUTZl9veeJGH9mKUcfyMY7rPzbgZzbmJ5jz3HienvmcI6dPwz5VLwGRV2ftXHt7iDACYqjkq9R6CqWg2jOEDq9DUSb3LeDfJzJ3LxcOkbemo7y4qroLnItOJ501t7GJ4TLQs1YD8At03c2gFXSg0oFktFGl4mBCgzF10SBSMmB1yDoPOOd7urKf4Df3w0pSkCsyr67skvBpYsDLP3qmRRHwxZF8S15vh47uJHvrJ2tbeEJ5GFwY6DwbUGZA4oCv6SDMVGLM2XekneILsEuWdOee8Mbpaa3TM33sY2VvcdRRpbAQ52kjcmODeffC7ilDmBkvULVBeSlJivjhAL334ggpc5bcWOvLOxuXHSP49TI14cV6YUDaOyAz3iZaEGyg7RvJnlzVXiYEIhpheo7EqeM7LTFufWt9jwqVXcd9A46FfILRmgrwVhS1nRecHAhonAcsmqJJ8e64Dx0MnvFKhGPiRbFh3BW2k1RoF28HxKYQVK76f8KmwtDYcUZJfZu29PoGR1o3QEIZ4k6O07ImDDl0qZazlKVpQ1MmUnw', '1557536958', 676, 0.7704, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313031313031303131303030303131303130),
(82, 'u5gWSDuzIDcVpwseLiTdapz4pQ6xS2zQoZAGi9eisu6ncviam8oniRueQDdqlWBdEKii7wmTzfoHlmvZjQhqMbOgDjGccJ0siomL', 'jMRl3R4UT56FDqxlFmuaPSxQpoMAkVO8SVIGVl7ZMG4elTb9VrxXmiLl1XXAIkDmPVYV9IwX5aoFqebPynZAiBnJZlsstAQt8OA0LWjLJv7ZTqzmycM8ALl0kDmdCJpsPyAYK4tsLJcaIwkLXUYxgQH93ODQ9LmjTcWP7423bQFeVtt5GswPjKra9Qik2EF3kHHwRXXuYOvavjZfOUsYJyx3CKjHjqnE95P8YFeP7EIYs1SijeL0xf1PsxIWW5r9kljAshU2EnjEMB8dcqrUHOSsGcu5YBUvUtbXjLW6yZhdu4K0ruvGge6YhJD5m0IJQtq9y9m3RsBEzpLF4rXlbwHmg9aW8hVQ9m3fan9TvPkY2Bae5gKSuHGCBr4HhquPQ73d9vjAx2p9SHVDsWXhaK3LkBlkMrrGUKp3vuSaW8Sd4E3XdwuydGLLqD0PGlLplgaLfmLBJ7I9Euz7kYqHDuSFUy2cW7s2aDhmm64XUYXYBcsaQhIJrbmqJlqrBKxvmULQRIJ9qGwEXMH5ItpDBId4Y0czChZSV2DbHdMdlitdDflSYxtqa9rAyxmz1FO6R2ToWzcaCLPEIAmxAuU55s3ZwWTrMW0dbVvuyPZ0h7xYbMJ6BjHBnD1fTfMcV6zcSFvsyX9HjlC91SvvZ0T14GnnBp4Pr7w3XjSiVVGhIr5ddQDOJzri7C7oGrHjk1RMnOC1EMBJvqX9OF9ZR1nsxqdhamJGBMxobcJBKwU3Fg9WKn22mlGtk6G3198XfrCSnre5f9zgc0ID5YiWfwnovExGeOV4gY4eWz6q7DBl7AGcMqXJuBqa45LcQl44EmTtTAlDl02io42DSKWp7xSPZonAOKAXqD6zctYJYfP73qJWkYkY7mFmhzmR93uGzMEyTeYHWmZP5DQ8a36nv4RKWCI0SdLj6OBqWRkxjlwouKicm1eFfCp20yr1YfqOZHX9om5g3drRhI88WRJRn4lcqmxUrarbftDKdKcRaWJb', '1557536285', -165, 0.1956, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303030303031313030303131313130303030),
(83, 'UyCTToEee22FiWRqU7Hfo0GjDzpnZiXDe9TPLAk8pATjvCCyVD9BY8yEv4rsTUUcXBwB1EoVW17P69Lyj2ZQU9OTKqSpanfD1Xwh', 'DBPzTjId5ziq5jbWe2qYmFEeQIWWt9VPDqD6buGtqRcbdsKXVMqXlMPXSW38jeFf17PvRy3B91tOJtHMZpOMHMmvh3vcvcPxLGnMUtMCf38iDn1wqVxvrDhY32l862kIU8jXkhTwIYaFU9I8eiE6yozidTyX3JdKprBY8YmhyKyVxOMBqyay30fuKB9CnktGhDiSjvdVMql3ykfYZG2UUuhzEc7c5M6txHlERWrrnWu3WI4cXHh79SHwWFsCa779aEMjMf3Pln1VIZgjfzTdK6ulB2aXCkvGatAQ5q26HEVFS8QiXlTbJdE3Dgg8spg7xaLfKtoeqPcioaM90Yg27dcC3mIbEnopiJkwOp7fvRQMh47Trt0JQ575Qky7fdUzqbgFedd8ZLSayQOugR7kWPppZbLXcVMCXvzH2THUQyhpctTZr7COrq5BwUmCwv3xOGgCcryx3e3xd0kl1fu9jV7GqvkbeYGl4LjoKSM3ELcxBo9zWfJmxixDIZFCjiH1GHJ3FborCbIpnFlFg8msawktnknXLv5yGwyzZmmHYsCawPVEYTlq9Euapyt7BARZ4eJZEpIRGCUM2QSw2wIgvD2KPEXbOyZhPMigHlsSMFyhXJcfs2sZfvWcBDL7oourWeeq89yKgzzEcvTShpAzmffwLuZVl6nusyxsXP2w7mZUQaYltF53QSVIidzBFGDpkKdm6nTak2K2RGpH2OWoHmWOdPxbn9hdAPh8EO7FVzU2f5eXZOcBXInKuiSBstiTdLHMz7I4UZrU1lq3iGPHyYaA9DAVVGFqdAvkShHkfglEau02ZrOFx5khbSF7KLrRAhHIyl4sYqBhGwWT35bvU4SSAY9aYJz9lRg1BgMt4tgLzqhCuAVeDXMjnXZ6xz5jtiba24Tnxni9RcZejY3PKF5DxMcVuhYmZBucPKn8naGouQ3HuexifiKR4wMBPSehROb60jeLBQtwvmu44mpC6MMVZ7KaxkS57SeTyJsi', '1557535799', -568, 0.4647, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303131303031313131313031313130313030),
(84, 'UKkj0mERl9dSgA5BBESKJPFxt24FaM9oF2wpjfhXWo0HVWOV4SgiJDt4Ld2Ww439Pb6o00gUXvapWaT6UW1I7kEtrgo5fekLkc3g', '4DDKiuHZmhma7Va1SUdKuc86lhZge6mZv8nt2mCq9fc6GKFb0l9UV0eZOb0DuS4Akwv497VKj6pUDsyevFsXIGHKEYpT8w85wL0wDIAYQP0AZ3P9nR8QUeyoSDb1a2Ar5USSvdC2KqWaGvrWDXcCrEMUtbk1yrpF1V76Jz3Z2UiALQsCgSChnYoirARTjHBMlOJblPQPGf1Ud3RagGrOF9nyMTKDsRbL2yJ9lX0wJt6638BADoCdlcJHv22gZT8C6b60HXx69zy9g6JToWbuo8sIB5GLSLsmxGRHrOsyVyp5QXf3wo7EPXyB50I89y9Yl5YjyxKT5oCUMD862IpFCB3nXM7oMcerxksL29q5C8dA8eo1UV6AOaU19rTvOIFO7sk7UDsawIa9QG2PaZamlA8wKZ3vc7u23tzk81T7OcvAV13tMXA1hUJVIoznYoG9mmcqKfFXtyeUmeq2MKoyz5Hb4Gt87xg837coJmQDvMj5cjcrarzWf84jMRKKCydZ7Jye6mndVTL9phkKV18ei4OkTTogwsxIyfjWQeiFHRB5Z7QV3s4oISUemOqCMeeknCqxWYA0RHQUXPIYxLnqwxnZcAPTrTjPyTV1rAgcoqpzhpZTqY4kG6eCqfB0soKb81Mmi4ihi2n9ZSCFF276fws91MK0ROzp422zxrIeAvIz4cDljZyKaP4wZchSC4LvoUEF9Gv3fRqTvp1UjOmit03MlubCKdlu5FED8OFKh5w5luLjGuxH94pX4Esfhfim9i1tuMdkGbZ8ysVBr46ZcZ8WaG7Ka8C5AOLceE8MtaP58iqMzv28CMeQCB87rUkHobTMloq7C12T50jQ4QlaqtIBtoxn5yobArngQ16jaJCzqAzKW114A1zfG3ju65Qx9zfBHv8o4lA883dxc65R9sOKiAsuutFL6zuPXSylmPXzdnddQ2vv4Kp9g0ZmgKSTps7Ux7la1aDTFABLQRj2mXnpBiT7pUrS6d7TxevS', '1557537502', -534, 0.5775, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303131313130313131303030313030313130),
(85, 'uFmbdyvr3ZJyksaJXVoIaRtIUd3rsuc8HDvtY74I6VtzquPfPPHsBmerD5YUfs24ht1E6yZSwIzsUpRB5Ap4qJl2JPgepjfTfbUH', 'ATiUjo3dKcfSJetxB0QuerXqX3QyzLaCt5ZOuWURYR1ZKKXUb8IQ6XYvRDO8heMpI92A3n8nzobZ9aK978Y4kios879ymyO5m6tfYGJLxOHRVqWfq1z9WxbiMtRSPLcCmVhLgSI2T6BB3zwe8Lz7XElZPGW4DRW3JBsbXV5aBgTezBt6cpWYiETzeMp7RP5lub1sZRObHiwJtuMPCVGF2vO11Lf4qEAwCCWCpEU4bdy6JguqriOh9g6lbCsSomty7XgDdkoQ10WmnVzVDyjJDSLxHl3yIWJu08WyoTftfEJtor1hcGb5umOCCW17qpnhfc0kXjt0QcTtMQQv9GqiJIezUqlyvJoWT9qZSC5nPBply72Csz2olY1pyL4SYWLuTYfwaM3DaUj6HgBB9k2mk5b7A093M2xVgEqVQRpMT4AIehysdYpcG5IG06C700Fd1eZcTL9OZ6fe7bTcEs9VqWD8M5s3zQbo8FVmjzfGr1gAoWzOtRhvxGXsWVFSxx4qD0do7gIsiOFR2AEhE6LZ2iBFuEgxS8kmwbUiiPz6wsrY376DeeDkTMDJofe7zAY9LgY5QfOB70AYrvVSafTx8a4GFIyxEVZPocoJLxp05p8QdM7Zt8vDJoRwl5hR78mmp1cg4IogqH2AmXGYaTuBIv1enim3Xd7MMInFJLKp9SidSWDPevSr6vyOMpQ79bg5xhXWMHtpfUWILRYyF1BaQntfynF3I0LfEIS6dvzjIPZ52CFaupJKX7LzIeTRGIEia3b81b44zBnlFhJEGEeeqJrMgWtx1iVd3fS2bJVHMhasGOb1fM6zietRayr6ILy1ijVPJa9eoOjs5c1fcOlMwAUPs2LxO6yGVgmtEtKCmeQkRtdlvGYT9QGD7nuRgjWeX5a0YEITHvJ50CMkcrWR8WRl9Bz25oHEjLlpDH51qF1HwDIcg4kGuXoVyH26imQW4lUGGDO2wHEdpx3VHz4peOjnlGT2Sbm7bMQQ7rVV', '1557537392', -62, 0.534, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313031303030303030303130303030313031),
(86, 'GjKxvWc0lxBHux6RQUfaG69SV7oGQp6QkWP1HdGtPahU2gGxatv5ziPM5Ffk45SWlthnhlyOGEjZXRD6SX8TPmTyD6tQEB1WJS6B', 'dmO2X1JXelZwWh9yrjjdyp5eD2xQv9iIweq7xgwKTGHQpux6r88JRA4uZjrzEiSHd0p5wnGsVVM2eziwQPj9xDpDHtIcajPyhCMXTme2k1f6rwqPzoSqAy9EOvnH4d8iI8xECe9u7Z622mXZHQOA1nfxgqo5kZQUxvEfJYrPgQjQZ5P2da6CO3Jj7dOkYDUnJL9HeA71OyTwjE5W6lMwZBAWlTzr0amJiU135596IaR517IKlqRix2PsXqJroybZeUggkrz30Dcw6sJqYmhWskqRUQgk9Pn5yMTmXGmSEZVQyF7YYb5uKvo7f7a4iYW4fxTkVOwzGd01oKTolTgTqzKgYhqGP0UXjbfbhO496js5AH1G6rPbtutg4k5cHUeEKG0T1EZBTii1bxwReTKkUiAaxe7zZFVgy47u8phX39vQ8gpUJd4mHZ4Vo1vPCj0KKkBWC1W8zS6wsQFPBpKgTwVyBGiXDQr7jstiuvZdut45aijCStO3qY95derX2eglgsIvITpaLWpvfDjiuqfHmgKtbDYPOvsszllBk7cZqi7PHRHQuf3eErJJwVSyWE2rg6lzkemGswd1xXsgSXeDku5Sf59bsFZikJHpGeUgSCF5JTByCvMVnqPTl8OGmzj2Lfs8q6PIEAv1kI7IKWI4OeVLP2P4Cl1DACzIxQ73PrIPhr0Lgg26BUpxEPejh057LT4c1rMflbjvB1gG8sH0MsgbTu0qiwwtl1XxTXPkgLh4jtUuowLMkTuGt29qGVmHh1bK7jfhxfCvoPU91tcrgc65srFjsbyPAUORJx27cBkPR2iH1i0Yyn4lOIz3Ak8OiEOPIFcOfPq0G737oZcneqquwTRF7m4EmiaE5EJoDXT4T4bq9yKEhm9vCXvb0gooMOVnPwEQqUI0tUHAh0FPHago5Qxyh260Bb2YXgWaAKXPqCADMkZQvQJaXDXOVFauOqwrqTCm8twvKcRyEvFKFoAOaiHVXcCRmzoMhnEr', '1557537469', 847, 0.3343, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303131313031313031313030303130303131),
(87, 'sEtlVAIwePPjKQSVkAr5jzD0wJ5ojyQvx0u1xwab97qHIfoO6SDbCsg58ZSeZUxP0dTzxlYIsipY4xixf1dajdg3762X18D0QiDZ', 'V3978mK6MHzaL2a2nQDUt5zvqe642fLhFBHobhu7TJdFEXtKPlnCdWuWddX0C5hsO3DyB5A1mEf3VHbnDJudkGMhm49OzOavjnWApL5LdrDizmfRPZ0FPjsuUMJuUnqqbzCuzkXpq6qpASHdo7S1GOuyOnH3BQ4drDGh8KaX2DzpZhwrk87fVaVv6R2uGb5T4A7V33Lj036iKxIyD1IkwpHlKdKO9osr4pXsmeJAll02TGixkLIiwwS3MrQZZteRr67S2h6I4vhEpIfooo69TvpCcxj3bqm9cFF95dPJaxXajBz8QUQRCnk4Zv9ZLgSkk7Biv1XCDsWxzogJEhWsJ7Co8mmOIZKnQqUkiGpotfmMd2ldRxsVdJiBF5Wu3y1iHCAetfg2HU8UeyMzpFkg5ekFzGV3K1E5YGE12FuxirhUCWBPmGztjAKDSafuQmEKAD5FWZ6XhROMoeOVFybzXQxswvYOiy3iAsTcfa5cC9HwxnnUmkbxVWHayJ3Z8EOIY94BVdqlljZ94okLqWynhWfJYQw3kBW1IICTZ9amrlDEWiEuSsi61OacKPmZVrscRay2oWgfUgF2e4l6FQqG8yswVFzMS9lemuS4cCK1K34hSIqAS6VaCa8IroatcJBaeFyYnbBEZHQoTeSWreMvtEaOm072UcfWuKBKVBQazf0ohDHbne2II2AKDtstZxfC7G3pRVryxEwh3UUiG7EPkgnziPbMrJDa7vRX96pPTWq1c3thnSDMjnxhk3gYhQoAud2lP9LWB7HDH5p8rv1CFn5RJ9I2tMwTfLACS4uYH9l9BYJST1Klpf0jw7zY4C34ndwMiSBSb4nwSJrtHoTXwZiDGYMM1kX6SxQP6y5C2RLLvovWUEnp1AYQdHntlVc2KJvIh7XgfvyTwVYjsMfKS50V8ik23nPP0OzuPxaMR3HTVjMxoMuY7sqSpLFt8IQuDK09KQLaPseLGAZEIF74IGdG48oMAVd2DzOG31Kr', '1557535733', 194, 0.9784, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130313131313030313031303031313130),
(88, 'QJyDpq62IPno6ltYq1Zs1g05I56zTVp8mKvut4tS5OVYvrX2CY7KLQymL0QAZW4DfEPeVzdAPFQqiqLYdOCVUhuwcOXtsS51wqwQ', 'IWlbVp8Ksh0LavvYoAMy0uqfiEuga4AkVdQDp2OW00zsu6LThMtsa2hTwjgnbA3GtlHZhwQ2UBx2dypGwRwfItvo7Rpnz0SVqlWdvTgZb5TshUqmaOYUDL7M6gWglg41Jezi883ORqALJ6OUaCLqWW53ryR0upD0qZzg7fdvTEGYzczkxjWQC0rcaI7C0rASuCX7teK6iK91M9HCiTv7FXadgKL8UkVAX8GQd6Fx4JZWmZdMqkrg6Jh6JFOva6BdKvOqkQYSezcLjG6QVEKiUpKSzscKOKGGXKiTOsD4LjMsEhmKOQrc4YBvO7ZSQh83vUaeFWF9FUK1mJ0y3VuZCoQ1oE8SeFWhrUprVj66Wn6sr50eGRVDxHrpm5EKZW9oKM2xwyTXCJOLThoLGFJaRTqFImyu86Insx2vvF3CEYUWIn9c4nVzwXLOrwQ7E7FewaomSEAd44m1XkiuPXtRzSvPwyuCx10YWF94BwvER2cWvaOEWnp00FBI0tv0PMGzL4gEIhOZ0TpKsSGHrHI2Ml6tRgVfsqL3YjK8dTtcxB0rOsWCkUoWYUW74XGntWdpwrCt4nvgrdY1vVAqzYsIwkbDFsQmSl2EtsSGjJXdJGjrAfA6dVTnrCM1DTmfDCfKMluMVZI3o21K2sZDdJGUJOKiZagZMLPJt6uKU6TKqg7WSxJ4AqSjpS7qHkxCiMKAxIRAh6qkQmz05vSml0qAtMQrOmc7cG5kZeBj1YlLClpXElowtrmKTAWkhhdussMXOBIU7HD6LcCKB3hzYKFMGhq684CJ77RqZSdnBjjjjVdrWDwuRWmGSQhJlJoS8DjMy05ItOlnewb0E6ai61pspgvfXgyRw281u1kXHbLkv0wrJqbYIYR7ly7DVG5Jijk8OTW2kpyaaleKbDyvJMEEDJ6UgYZtqsU7uEW0jwISczjX1IkX7tQ3jMr3Z8g7WtRYyhjQFwgrBFM0eGseS3olmIb45bUBQnaH0M4ypobU', '1557536185', -22, 0.4661, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130313131313031313131313130313131303030),
(89, 'OwYoZukuMwhWy5XZ79SjPab9w8tdyuQJKeRruPDwAcLHoSkeKMXM1qFC0K9q5dqq6P7mn0jqLKCmCx7mLjo9zyyWSebv0Po0OhKa', 'C5ndjbRSd5glaHdnwyMb6BBshiIqTBLPf1OSfusgbuMeXZpuQrpgIRohXErJlP9ngQCoxFqwxLGY58ZtwcpeHYyZYSwXaUVMDxOOdIMEgXYBB9XkAQM54W6ynY0ZnS35o6m5gEvFlZC6u3g42lwOOP11aWQVWHygvxieGsCyPTDtKPWFQIDoVyjlkO3JVprj1SAgu86kFF3Ipt2a2Z9RpbZxRwDqf0HeU4haFGWYTlPRq0tvB71cgF1CL8BZWsl198lWd7buuTYRPoiKx7gqv2rz3BXq2MlGL5LB8qMSsiuIAEuRR0Sv7heoHWEJu0JfMUz8rBL8OzotIO4QxKSt6oo6KbJVj5uEaAKx7E7hwJF6fQ1HBofksnXF9hcZw3DWUajPazRiCMkA9Jlq3UZ2cfR8Xf3V6T982BfZAnWb6GmYpv23Sh6DjZ9s66gJ4A2bxVy0o4rWWtKd397w4xB6OBPEDQRpobi6q7fVyCiAa9wl4FyTCFtrF6RJxqOZ6DVTFbiG73w6KGGls4n7yFIEUshGPU9pbYXyi8Jl2l8uJ6ddelAeTylKvH4vugSIDbk7iWxTlw6K5o7YnuadzjkIvPedwtWVsg5wFDIh1zsUOxoAUv64DWHySPLMXApYFedPqdhy4vbVUA25MpqO5srhBFGfHygVf4J0yEdIujiOnu4s3b8pTQzSIqZzSptIdLC34ZwKh0LydisHHQcT564lc2ELp84pxmSYXacEsxCcrWfQImDfDeXG4wGRjJ1YfPvKcfgr1YRI2uoQ7KtuAebUiT7OBdmpk9wqPbG5Xhs70UVHT1FAU7O0V8UDgy5IMmUYP0uCesrnmcPs2afzASMYUf4kiMaUBrFocHG2VvMv5m65xccqEuaOgfBVHTCYPpOGWgfjYrwwboKzr6va60Uw07wmuSsUofjS5HasnfCpDjLWHSdLVo277RPGDIFImWcUA2tubV6bu6bclvhg6DwABsuTbrgoGxsQseaomtYP', '1557536825', 200, 0.7977, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313031303030313030313131303031313131),
(90, 'm2JCFLoXsWwY52eYo06CIidbUUckji6kKqyRBMD9HkWVnvzotk7ilfEQQdMIhHCcwHKYVFgfjyJK2ShHXxuQl4sm8oLZC0wWFRkW', 'CqfdiFUr46nUKCggIKDLOr88laOzcShOG3C3EFr2tcQWYAoytkc3RnR9rcs45LBx7ynLoxmtgaFUxqUJBL8chbY2V7urmxi9XWumvhEOq1THv8ML75re5RrOLUTG0cnC8cZP0Uk1WJtoQI3GZh78gpirZyFP1HPZGkRaSom5SlrWxbGuflbVOQwWA6PPp7DdDl6o6KM29PMoCvGaSiBzJ88lyvlGbnQkWdItH0zSOauH5I5HS7q62j7BUOfrkwpjDZIrH7JzQoATUOQ8fOBvHnsKCYw4QymaHB5i46h9fu3W7LZq0naMKicKI0ayJrGU97Q1OYcA2tTTGBuA8P6Wb6iEcVcX0envYuWBUHuVck6HEjnDD9oZZMLp2HBbDSs09Kr4oka8I3GnZUDyvk5TakD3gmnjFoUlITjpgPccDEEWGmgmLp9EHLSzRUwj4MIAETyCubC9V80nLGh2olzjC4sYPj3bP4XGYLbI7qpZztHGeUFzoanRXfrebBWXYduFEwbG6xzGBHOT4Zq0LSyfBiOmULeyuerxIaxwsw7g1OgWgWyiwq7wEewn0OT3n8LgaFifco2IOL6TRM4sES3G52DgsIUqEUtTZ3pQj8k3YCjGOuYvacmITH72jvjFiyxmbjUjOK0fumUn85dq2o3C3gYFwa5Oj4ZIJrLEEf2kpWSXQxReis6pBGcb8HeOHtPWGr1SUBshGqcnVSSUVpx4w0Oz67LFtJ140kDYvRf6lMVGn5frVelAQbMQrpFqCTA3G5DXuYpOo00Sda1SiVw0ve8ZazX38VxUKI0LRYWnO7tXp89a3u5hyaS0gBAx2ORDceKuAPSQz5jS0YEkbX1qZYYTJwCVizyf0BS5HzaaJXwGWFxnGfksLDrEAj1aWeCIcSmycbQmhE7nhgOiyr0mWcjiOYOiYK55L0eU3FSrbg5XZIr6Pv49vCxOpvWim9UkH0t7i3iosJpm43sLrsuOqX8cnVta8q6q1T6dUh5d', '1557537653', 859, 0.973, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313131313131313130303030303130313031),
(91, 'wgQjrhikI67sIdnVgzFpHD6bTofVajdSmlBJPYuJpatBrnExMACgLht1goMuzpGXyjJ2zx31s5cBxpj2FuW0dMdJ0gHWmowS99fc', 'HZZaSTjv1kkpWgDB2akk600hveJF6R8fcjhcFzMgR7JEAUI6eqQOABFt3Ykmqroa5uY7R8DU5MvMBqasMyH8s6HyWyiV8U2Ykz1ToySqFjEM0QZGIyWmGt8vf2Cmde2DYvsxkRtOEJbEL6bO3ryrjHVkUolFFrqbYkg4C2s5015pVfKMJcypiQ52XCqRvwbBl2rti5OdIbm2qhHDOPXgEPCBlITVHukU6A0Kl1xePd1wka2nfkFZoGx48GJRikQ4e2XVLPD7h83UAXIZ3IMzvqQohxWFf2I7ImfWzv7T8Vr9fAOsfYi2Z3vAPgxmzCZ2ByXRK3ZwmAdhg7fPO6anRxxFISuVh5BQRCZCitd2W7nhEv43K7pA6UYC1lQlmpCuuzpheMOqVxU9qMga401GH9KsFGyEPC13uoePwYMGgPOUyXQ9KK1EGgV9HVDREHLsS5pdc19QZZ5w5WM0Pnov3fsJ716VRFUKCEYvfWSR51I1ZR7JgT8dM7nbU0XRrvpXK6UEFKZJyXKofCPl5hgPURFv4RaEodiZfpdGtqsvpI9DTgTQgwKhotlHAzJlIMyU8BTAEZj9CoXLUMkbQECCfYnMvbHUqgcGnFWncpxEeX5LibaqLFSQukOJME3lvAdm1Cn28I93clBD4smw5xuX6zAzr0KEYOAV1rbyqU8jxCvodBXvMjtU5GKhteRQOTmko8mY6WtrgMM1JCTnRXRJrFiRTkjU0RuC9HXf9TdsmQrvCwc6hrAsbxdiFi9QAF0Oh9RozGjmQJsTTiUI6PI3ihvCQ9mExoTRLtaqnmM7FwS8xWYci5dwMUbQmTWlSY9LEFRkxVEKUcDgytqyRd5SEodUhtVUzrMyUJU76lThuJMgWSfMOdk5TKDRyWglELOexFlL1DtEt9j8I9rU76Wbu0qGdjYE7ZbMxu9ikPsXPqdTSi1TORX9u7Aofw4QW4XcVckH0TP4xAuvnjYJSujZR78YECwU915uFKTZ3Ox5', '1557536667', -45, 0.9921, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303031313131303130303031303031303031),
(92, 'hdhtj03HAY3prBmQJRAFOdP9tBEY6xbnxZZ58nbiHIlJBszDGztHiw8agi8JWkzCbC4yjDFLbk1W9bak19JDbIO5rQZnb0lKc9vV', 'TLx73P313M8TIBnqqMSR0hdTLxvKAxkaPLMkhctZkgtkOWn63JivVzPhJW2CmPwg8EppUqgO0BbDgaLD4y73dKOx5eXnvY6fPppoTxqv2QhP6fw4rfirUO9GOod02Z36T3LefxY5rXJTicFmcPRIWJTHUrRuVTnQkywWZpTxdVzPT2bxjgMTnxZAnlTScE4r9XDx69bSnKMDQK4zPz5Vadsme8h7Qj9Xlc80AKR4VunkakkvHLLPlLk0rO4fRQAiUk0lrfT9P5lTTMWiWQQBUcyv3ldffepwRkfzGCj67yGkW8YYzMgfPv9U1KJ71uBDadSEiR6VLVoDplmvAB4M7G8am3DSaDbCRYSChZgCO8tPfq7XYifcMJui5cVuFF8tVBetDYOcdfWTsnfeISOtQFdjbfzZzzsdm7ZbnQIE0dMP2dKoQjJCgtkdEaAmQlaPau6Muz1Z940CZXDrlD3E49OYuW0BtZeimKAfZcGbGMAjjvUmeQJyfHEBIBLJvvFEXTsARGIgAoyS2YxatUMlM8T8j9VJUUvTSTHO539dTSTj7jyQ6Qe0IruviysBEbH0bLkUGiX2xdBCywXn7E2w1BtMDRmmOkhZSwkSGp6JzrGOoBHOumdXGFPVm1CZkleQX9GH3oDjZxaSByQ6fVLdJAyXs3htdfxznErqMgyLLw0ObolgmnHmaoEPVYjRu1fbc3y1U0R6XndC87ejSG1oY58ALKH68FjFoi3unCwis6OjtGueKTGi9D0e0pue9cL1WqVQf7ynnGLSb9820WK5G4eJAWDexAAgTra3ttZkEa6jgu9HCUbJCmP8yma6jRMmdkM96IL9jwPCHHwfCIZgVxOoUE4Rs0mlU5M75QXRlKUOxMhF1pbFAAaxCPltY2jdYH9WrPtqKRnSKJqYKZJWDwTyIRZYSXCXpdUFbGoTxPdOkzX8TqE74k0rcL1l8HkydB1girGdHFqBhiPboJY9S1td3yqAMlp2pRvJM3mp', '1557535869', -511, 0.8548, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313030303131303030303030313031303130),
(93, 'CS56gXE32ykRgdcIOSRoYZo5Dxou90YSkkIUw0HPAZymSKlIcgFCV0CiTUPrqtjipFIz9W9tviaKQaSAYxSJeSfou9Bh5P2BRT77', '9LW1Pt91bsLl6GrIVDfmtgLY737OGYSxws8puwu9UC3YCHozZgCcQgjyw9zRUV0Qh2GGxsea0EHsvBIjqLmVz8e0j8qMtKw0ptCRYgk4tzIQMnpVf9tvGSwktZDBqtp3VOXTLXOPjm85q2uoqpZYbtcw0HeiL3FYM0CMXuFsx1UdrxXK0xRj2YeBVjbRtviL34FzuVUZ8y4dQWK0Xy6xhlEycMwiyRjrF06epeum7YA5BdW6fqHCTzroR8fB04HZFPVKHptCsguQKmw5WbHATGB6UmkMQ9sp3w6aosQLbqKsgotX1P5rfG9FjsMR36AHO5ErroyMhspWahOFrkPaZy475qCMCX6SXxAAScFFJnrkq4vhgHXK5imrfhQAADZVrRTCES9rAaQz5HzLsYrdzV2EM1qhVefQj3zwQq05PPCH6e1816jyro4IGBoRCGTDz7DjoReApmLHuCRmY6yLFLuFY5JhH2Ujc44Yj9QZnLizgU3thZbSi1hvDrrAaehRcTSuBkPfI4cko3CsYJaQh8rdFExMZk3hzz3UhoaoretWV4yj2nxGD7ZM5L0Qchbzk9BbkjUpxg8rPYT3tThonZUfSJQLL7GJsAxkK70i1b9P5JAEigpZuIcy1A3AJPzMYURmyOt3SYy4IoE8twUsYlSLyjDh4pQHQ6xhJlkG5CkcJU7u3ELOQQUQsVBQLStv6aA3hMydGatc8jXIZE115ckOKoWhRdtaI72Hd5aBEz04Uz8QixD7Gr7CpJEAjpSIIXQevg9S0SUP3IHPZiC5FyhkrYKL8vC86C1Dbjv0I2brzKEF3X0V2xPUR4dQlsLqRczVefe1P4QXsDYpurJDLpJmD33LVihBZDv5E3lUiZSjIpF1jPSeT92GMUgzT0aEuYP7sIPF8Lgyn4Jvv5mHnLHTkCRgdAqzmau1DhFjmr2GoAcR4de3egJYedPQV34mCeyMbHUQWYcGMZ161dtgtCaVwGag0o42faZr71vd', '1557537259', -539, 0.5613, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31313030303131303130303030313131303130),
(94, 'ygdck66m5SWJb3SzsAsAfZOZpcuthFCjHpMb1R5k4Z7rdhYLhGd0CGZn5fQC0QUXdqJ35usarZE1CnqPuDlinfxF8bzD6Sxq7k4L', 'wZdTbQztplgK4tStvHtPyZFwzMzOn6KoknkthASOzctz2bKw11LRmE9ipzY41JQSwCPWLcx06V4gmL1rTdsKwd0XDfKb2ghe6KGhDGz51w2P4eDe9hvx5DereLUbqF6s2LXvS302i0mg9zEULeWc0WQQccq3cXizlEyAuiMRWl5zBL3sL3KIj7P6xtkOl5Sy2pyytpWyZzaKqSOS9JX8ZbbfhDBqS7Pp62VpQpu8oFDPDPXaUjup26UfmFgXK099xxF8zhpAbEtKdErl2KqysU19QAhi2LRKmXMIG1HVlvGzbmknx4JAgAuUGnGyFqVeybhbaCn7SehfvWAjpgquq9lxU3sFGWmA7j9w27pcMQfPdpe6EkthZzz4vABF5lcP3koKguQ94jzfiKfLihUXUSbst08xRCoXnc1QTICYIEiyKWCji6Isc3aIPh2i0LYV4Y1OSQMFKTnKz3oJFMUST6vRxrjVvMUL8AnEeQkgaZROM0w2qms9X2fSDuYqpGevz68mYHfHWWGKmQ2dyOojmQlK7o0MFsX7ntfY5rx27OUykxVf38Hk9vPwYbo3j60BzJJqz4deExufE8bbXknfk4FabRbalCsY8SBLqyfjy8sOmAPYbor1TuUFLokaJ1hc5TRZFVFgQBMfrVPDPkSFOOv4KOR2uitjoKt5has6vYvyU8dbP9Fd6Zuk65KMDr3h5vt3ghCMxbAJJdYBcRSBL2RtPf2pas0999QTCganWh3OXb7UWpqTPYzuViFV3mjTAEABm85PIgUJw1C45Sl3fLGnocHhk81up2HctSn9T77ytIv7zbE53ra9eZ7xYM5YAicFYu3mqQHeOjL2snlZe01MsETEZjxkaq41QZ5qkrEOvLpQHroLLqfi3c2EnHmy6qje4lvnCV0eA6pvloQqHJRG1Byw9ZyFqjXkFAidhgIx3jO3ldDW0VQWnTshi88E74XiFHsVjuOJToytIUPmFYb663JUO95vbHj82G0u', '1557536836', -130, 0.1116, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303131303131313131303030313130313131),
(95, '5mGLttnDITV6b6opH3pfBd3RLyVXvz6JFcdXBVjM9H10E0pLYP6RqAarTidgEpkxCU6Z6eCPWnuKvOP2CsblCRFVmVTtc9UeWumU', 'ZqiI8XloIsA9DZCGbZxgepVx6JSMEWZHeumvFmzVk0J92nrX8ZMtsLluoddeJh0nSrMaBEbjiph1OED2rSoz518k3zVxcunVSgBGUQazDHbLXOd18Cox48i25M1I2z9lfWM6zUwHmSrosPaTcgLnq8QBuUtMexhD0wlnCPfIsU6UlIuBDLv6aZK4hSjIPnMO8Yhw3CmBXP8gCubes9CGhJ3nqIwxL5FRCizyRjQnMBwwg9gHDp89LlIAYr7d6FXLvugs1RG10gjDhFH4dx0uCQKFT35MO8zzKykfziVwAOsDF4xi9xfISdbCawqdTsAfouKUuAwVzdZvrkJpsqROtrYrPS8wlFYMojyqOLvbVvTgAtjo9bRLsy89R6eIbKJdL1JQtPRkDFaT6vffdPeCPyFIgcGLnISvwzi7wKAlJHPo0pzZEjYlyqAb3bwIYynFD2ehWyGedCQKgbhAtH6XFaTvd2JwVggI9lxjKea03pf1VPl4FWAoaLyHJKkdfRwD2xedVM1Dh418XlOqe5sJ2gAMEmiLWjarhBhZtdf9SBa8kJCEb6HWgD1JXQDd2Da7UyIDowRxQ1G061PLuZk3SSOyAblwuRyEVnwbGHQOcjAKeaoKbJj1S0YgCprHkXj5i4HznKcXVtSnKblBfmGSeZvQ2vULwUsn3DgRqGVW0vwTE5ElGSqzYRqiPtJH7JYxa5c1Ru2RtqxfVRmWvgya4AICZkWw4rRAFov3DavBkdWvyvqrGv3DydnPv3xdo27vyAbWPImfxSICz2TOgDVZqHqUqEvL6uKjOEfJn9AL9pTCYqH2cEacE4QRH8RcbPKZqBFoisc97PpuJGU9vwMihjDFmtyvD29wrqtVACbqs7jfTQt7ciLggqOnpHDHt7UXP7FkgGwybhASpSqZgV96CplWOO7LF52fzGeBjBgzhjeniKKIHqTPmhgpAMWHgVypG8aKJpmsKegKyxrkwO1pt1yJKDavdCrscssMx6Qe', '1557536600', 717, 0.5057, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3131303031313030313131303030313030303131),
(96, 'dbwOI4vTYDdXimKcxdGn5E9GIEGSPFr7eHYahcneP8g1cYIKfFkakIctg5VnqdA7C6ModdCr4uFYtr3ck0lQWED8cnwLoC70onZv', 'x5fxFJtO9MLvMdIoWtrEuyv2JV1JxwyueQfvERDub1RGCiuOlbC4aBSbs5im3xvlitBl1Qb5A7kKPgC65JbldxAcy7WSWrQ5JZm4KH6wn5aGp68hdc7vDlH522YfddwGxmtESroRwXnvmO1kIvqwr1bRSPnuRSBbJCY8m4334FYcGohfAH7rCz2u6t9BSn3wiKQsdy68YgXKoRV2RLada0g0G1iBgMSLfK5GsVv5gJgbtbXHtIAS6jSoEqPu235SyDHL4ajVV6ZuXojgtxpoouRE1IIebcERfoHJ3htBWj4GLt5FReAO4xcMJT0RHeAIj24Aqh1cmqxKYrdYBO957tXOQVEmA7VrKxPja8XD9onGyhI9Jf5fxh2HiQGJSUC3zVXUgTeYifAuvZBcfyohlWvs9C5ZvxGxKbqmKuTbQYbbQzS77K4bvvm6mhR6w48UkjiHCZXfJz8Jx2vUnP8W4XACYP16VsY8gjxXRmlc23tbCmvz0LyBZfc0XfxZGJafAca1tA92Gocu5zU80Am9iqbhhwrIQTJehWaZsHjJIChFVEExnhxxYtxp0GIllUG5lAwQPHRj8IJJ8COQ8R6Q1ogq6ImRfO0PL6hxyzLKVHAFHsj1gi2ZrcnjzDoevzHqAto9Fj455yOuEac3LCl1fTR5qqMt9dLUMJTB9VIiBhobZKsZDP2VprHID6zAbJeglSKW1pLmwSlJHd5LUT5HYSXefCIAz93uiS0agMbkOlGbLx6rwPwmTaxCd3ftkpfBBKCgS2Z9sHpueKuZwDkTblwTyk9dtyPAivCeR99RuXuF4QfpUlviSpS2huqQ0ALrm9Z4d8GqU2WJhOnHEU4zVkB3nw5lTt6bODJMW0BTG0MFRDUTMm0Il8HXRr6IafMMC2Rn4JUdRR0tOlMViFjK8PbHGevYOUShOhlRymypnzAa9X2RaSZEjm2lVUh5PqjDnpecpRBuibyIRoFDqX3rSOgRvqq5dP8SjqspEd1r', '1557536552', 1, 0.7435, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x3130303030313130313131313030),
(97, 'XIGj3Tt6M6SfuRYYZ6kYCj5vgsPge0BtnX4R3HiC5hRvQ8RH8fUWj45tfzZYgeHEd1Qhqot2KkdDyi8kDgRPnGsjBywxFkaIqZYz', 'bY2jPgXEElMQxabyPcc2lqr0sj0E0PtJjpYte42y7fPdOXSaDAjCsaJkCadtWwmMPIgu2JwjY2dsszWDQQP6WMowaTOai7CHGVWpdinWcH0zt6o0oYGrPhrB4uLI0zgvWZ1bKIBtMf9zSvdelZXE3DRylY7a5UhbzXrQG2dRKEFsDLqlESxJETEn1jPtw7EIzKfnZdb86XzcLV0klCxIE0P53xVEmcq9WrqLEgxgP6RPiWXbpfVy1ZmEsDnIzayrH1Z3HchhV9ukbQgVRKEhKRh7eBdE904BQsVd80nao3wHsBYwF8LSSBzrosqs6HWElMefXFRXfQXW6g21RohkldeDXc19ridzdZV97eHzsvH47Mtmqw9FdHhIQMZH9KRnt3YXEEX543R4vbjBmxoUr4GF7gk9e5R36ZpAAWxt2snWhsvHFp1Z4juuMC2sFifA6Od7T8wJnJhGqB5Gmb0W3qEcPQ8Dvn01tvowycTT6UyjXC2yqOnOpqcLeXAHIl9je4WOB7BUcWdPQwlhSj7v9i7e1VqDiaEtmwTW2VHMFRec6i3TGGf7g2pyaLDsgTxwSQcZQBcxvDDrKX7nTWJzKD4KHue9AsOrJ2ST0a3bJjpyLszJr5BVB87QB6cHiXqfZ6XFyAhHkRzyaRoYn5R8RvwMUzw9ngrVC3mktTT6jg6rX8A5HYtesJkCyVfsQtQsCSaRM4RmEy0b4ha4oIscrRujA9kDEyAT0ymgs7dunHgOAi7VsmQ2OR2U0fOHSwIbK8Vxv3WvtKVjucrEUSzKxIWlMeDDrlelTzQGXR3oXEWGKY8gHfHlEsfFX4Rrp48onT9IJwwaMslXoCdJUvcP95UStOr8JDnjg5QCU5nO1783p9E6sD4a1zWWoopGr617v9TpsvBkBEh3OxtkpDjnfXmUFSJ8wr2M96k4nPdHz4OXzPFrIwXtRbaJkesrZEpk9V8AG0cYVmHFIYfqphVrRikrmsxDOJbKwBj0m3y7', '1557536692', -277, 0.825, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313030303131313130313130303030313030),
(98, 'fZchtVihdhS1Ly1G1Gj3hbShpZh8JyDO8Tw1Vq30W9MsywRCAwPdpCOrQMn1dtEboEdCJOaA4T5MIn4ryfHgUW7tCsSM4g4q3ii7', 'V4E4xvJ0f6E8TPYbM9MnO1IqhVQx4PJtucwpp0M4aHCGAhBZ2dR9mrWXTsZxsdyHqcLCDmc1rbW8FCCEF9hOhKykRSvqeuLOK5oIgB0R6wFr8Q0cFY6lzXwAcapanDkMrQoGfIay8KKCWVLB3FhJfZTJVkGMTEhEvtKwBHH8xRdGaSUVOeQ1jUCK1mliMyBoXYvflzCzkQ4CJHp5XGLbIHIDuhnF3kj0KmCQsjVUuGhqHqi8q04dwocok4LVGZntWB7jWXz71pS720y3jcK7HW32yIx2HvPQvJZDOqCbX1PGJscQygPUfnhy9gH26UE4sKeS3M29dua7POcvcdfybFTW8FeVSaRbLDRWE2QYSQTqh1A4c235tRSdtY8E1jqasoRVD90FV4YC66ltzIeu9Velc8pixln1w1dL09xfjaqFj3uLkiMLcQWmia3MqfGKYwYuJ0sH68gBTT0WsJIVCD3fK55aH1omMV55RKK2gZuqRBT0W32Wqkx1BStplEsRYazxlmpeOH47bb9VQfIRBSoEQwgxmbVcxirTcRsjHj2FTDLH5jLD9jCaq4pwKzJrtjG6rdSgZMn7YZMnIgdi5BeyotXpwRXxMcjc3sF5E95qqcbXI51PnMcPJLQ9F0vwtWja3zQMGmbBfhXl6Lce3QyYsX7Mb1soxzF1pznm6sDFse4DRlKv6LiZyYLh5VM7Z5qI9riPSrtB24zPYMGFwzoS2TMElGtIOsxkfbA92iGp0MsSt70GkfSDTFcUZlyd0I2MJMflz1h6kmIMmjFBuOIh6kY21S0zyRU8BhiqtCfF2PmzBnJn3eWMHS71pgPOvS9lQEHnL6A67anfeja2YxybFhDUaw1VPJLrsTvcqripznKOf8YyhIxr1zxDjFAUvvLpr0FUsFoBoswdCQaYWLUAJJPhQHxKz89fO0dtSLREBpEvnoIf0HCAQLtLIASu1DTYxS8XEKGAcfaGuREpqvIujGv90ny6Q10yEBqg', '1557537020', -118, 0.7503, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x313131313031313131313030313131303031),
(99, '9Y3I0aWrebdf9tUoD1Dz1hv28e5slku6txjETmDloJ4Tn8FwEx5XApnn0I8xfVsEb0Wr8qG7WaipYFQw3XUawpCAf5xuxoO6glY7', 'Kn8LSsUOW5moPd6hQieGRkljcKvpIylELcXjbDS4ing9YmFgw3eEQrv1eYBAyD759T7HRHec1xxLtnC7AGBucq3AD54EKAfnUsF0UCYd7zbgnhWR2cldXiY3q3UAlqKy1UB9kq46zudDD3EsRzsO32gnAU7pi9DAwdVb77xSqhBThHIW3QYhxEVz7CH5CIUwppB5iEovEWo1jdajBYQCo9YE2eFEkbxjEtESR6C1ftx1HC0xxY5QDvnBjH15pwxZhq5wLoepdU4TtTcDSRGVfKbrY3IoSIXwhfU34zdFybYDB2LCyBGTeSl80hOAHPGWFX5sKCzPhlfg84IuCf4JBRTIpnhDULQfpvDJOyiQnnUK1W2e4KOslIOacm7AuBlpxWzTdmoIRiV8iJJQS8X3rs6umdkorjes3hTV12TuH5knXnOj4oqvX5KHTXV5LUunXtyPcAJ8VK6vWUgFCwiROzOLOwTDtm7bbxCBJ1YDwhfvli5Uzwx52XdI50d5yH8ROt3gFkz2uHMn7zh1TpaaEb1yJmXo1UwoOiRMYvxiQZG8gIR0za98DibgLA1zR0hPb02cDyUry9WKLJORDOwZ0iIQbGuD3Wp7XyAtGuDrEbBfFD7A5igGJ9DhYEkzDMVh41wD7iJl86DCXpPcUGoiRUXB8vxoAuOkzkQEVYd6YT2SA3UG5XTKkvAPEe84V54frwwz6w4JcyP0Bzl2E4K6c0DTzQ6DCxH3HAzlDWigM6Y00ZahA50jqn3QRjq4HTIIkx10zgUDLvuSLfmnVYCp3BRFwE9na56gkmPxSqTV7MoCUoXmBIBn2I1nyTez0bSGH30Xxuf3QWFfqqTeFlZdoIyWYZHCc80ZsCydApY4X0jJkjdW6RIX8AtpJYxzMYv9A4un1d4WpUl7A5UyVfRwfkLIUPKnJFoc6nOpPUyIfGKmeJZ37ul0JXqXrxl44gE7Yztj0spmtmwufgqpFCdlAqt1l9iCLIiVeDx6xTDS', '1557537534', 479, 0.5194, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303130303030303131303131303131313031),
(100, 'DEfDCDsyQOTYCCD4R4jARAYKsbfg2jcmpXrKXw5Er2GMiYmnjgG8RpMhLmdwnA67y51JCh5CqaRukcry9mrye6YGrpzF7KnJ56YA', 'GUrsM9o4JiUCljARZFwYuljGcO2eY0ik8pcbw1jwwgKyX96177s7V9pzFH3BeL0XWMjLDKBRF7YnTRZ4CrK9IQTlwusRTp4p83Of8ng3dRy3drfZuDr3TnJZJaeZUXvLHbFA0Sj87rvCVUTMKHvQrOYulHoZill0DcVOeeI5pVR30fTsnDXum7zTj7VR4Bx7W4xUQtwU4hzmsrh0nsJ1Fiy9EoPBcK76EQxSQAGB6uEyix2qKaVqllVhny5eIM3WHsUHczebvB7BuuaIvItHohDitBJICFnG9YEqXr9DizWy5kGTDbpRP5JcWvL6Tr5iYlL13brYrqam22zX9uITBKeWOjalw69MaBgtwO6aZ9K3mCQR1GpMMj5A1YWtxCB9IJ8Poi9fTKIB45sEhKszlJj7Bv6tX1qnFJn3CEycbe439ptjUHUeg3VuAVClHiCtZC08fUm1QzLmBCSSUwHKyeTLXdw6RrcsFn06e1wISOSxrHChhdTafhfUEmOIns9kJ1mWA04ihUkBDFKA2MrridZVKpsdgms4bw7FkSZK4TaxevgKaenBH15OektAx8aF0UegrBh5eJnmbd9OFxGDvGyz47TQbLf9baIIXeXhKsY3vOpIxJmxGfpdiLEYciGvKiA4MIZmF3XBdg3vOOqjeFDITjOYAGvJGiQh25ojWwh2iA4bqKRYaYf7RIkQmYHR0bsnDkc8BTZlKOrJqzEvs9end1eAv7hQGXslCrmQD75xATd9OgRU8dzwXbvd18eGKzPcZrUq3dxBORlryQpcb8jx1daHV2yqc5zUIiPSQbnxnGRCGhklBXpqu8c5bOf21sGuQ37c02AlkoJFcBDnpCUclVAkPskwdIbYkELowKb2EZ0A4OkhAaKQyzmsRZLSLR4jc9Ptrm9AnrDnkSn48BZla7wsfnA7HRiwqweqIQu2rLE3WOPI4UAJ8w3k0EMd2JVC2K2gnbclUZ2BWCCfm5y0tPW59OmcIuVA2ScW', '1557536236', -487, 0.1321, '2019-05-11', '2019-05-11 01:05:12', '2019-05-11 01:05:12', 0x31303131303131303130303031313031313131);

-- --------------------------------------------------------

--
-- Table structure for table `tree_map`
--

CREATE TABLE `tree_map` (
  `treeName` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tree_map`
--

INSERT INTO `tree_map` (`treeName`) VALUES
('test_euler_tree1'),
('test_euler_tree2');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `ID` int(11) NOT NULL,
  `Username` varchar(16) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Active` tinyint(1) NOT NULL,
  `Auth_Rank` int(11) DEFAULT NULL,
  `SessionID` varchar(255) DEFAULT NULL,
  `authDetails` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`ID`, `Username`, `Password`, `Email`, `Active`, `Auth_Rank`, `SessionID`, `authDetails`) VALUES
(1, 'test123', '$2y$10$QiuhkEKOJBgY/RgOe1DyZ.NXzFGCqezkJyZh4/1Ht4ogrSr7s2XZW', '1@1.co', 1, 0, 'op7psv74bfq2s25ognljp074d6', '{"9eb502ed0573fc4b5f0e3223e4e54f47":"{\\"nextLoginID\\":\\"9b8332002616fa5f4e8857748f0226eb\\",\\"nextLoginIV\\":\\"986f2393278fab84e0320a27f9e33b75\\",\\"expires\\":0}"}'),
(2, 'lowAuthTest', '$2a$08$8XpqzrBGdcMITaUGRk2eCOPk6eLLBEvKCBPg45DpUR7hFT/u33RxC', 'igal1333@hotmail.com', 1, 2, NULL, NULL),
(4, 'test001', '$2y$10$QG9eYtcRqxWkgc1CqZ/QWOSZnM7oEOAzaCNCB//vqCgcNZIGk822q', 'aacount001@gmail.com', 1, 9999, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_actions_auth`
--

CREATE TABLE `users_actions_auth` (
  `ID` int(11) NOT NULL,
  `Auth_Action` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users_actions_auth`
--

INSERT INTO `users_actions_auth` (`ID`, `Auth_Action`) VALUES
(1, 'ASSIGN_OBJECT_AUTH'),
(2, 'ASSIGN_OBJECT_AUTH'),
(1, 'BAN_USERS_AUTH'),
(2, 'PLUGIN_GET_AVAILABLE_AUTH'),
(2, 'PLUGIN_GET_INFO_AUTH');

-- --------------------------------------------------------

--
-- Table structure for table `users_auth`
--

CREATE TABLE `users_auth` (
  `ID` int(11) NOT NULL,
  `Last_Changed` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users_auth`
--

INSERT INTO `users_auth` (`ID`, `Last_Changed`) VALUES
(1, '10'),
(2, '1541174303'),
(4, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_extra`
--

CREATE TABLE `users_extra` (
  `ID` int(11) NOT NULL,
  `Created_On` varchar(14) NOT NULL,
  `MailConfirm` varchar(50) DEFAULT NULL,
  `MailConfirm_Expires` varchar(14) DEFAULT NULL,
  `PWDReset` varchar(50) DEFAULT NULL,
  `PWDReset_Expires` varchar(14) DEFAULT NULL,
  `Banned_Until` varchar(14) DEFAULT NULL,
  `Suspicious_Until` varchar(14) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users_extra`
--

INSERT INTO `users_extra` (`ID`, `Created_On`, `MailConfirm`, `MailConfirm_Expires`, `PWDReset`, `PWDReset_Expires`, `Banned_Until`, `Suspicious_Until`) VALUES
(1, '20180330225935', 'code', '1555161777', NULL, NULL, NULL, '0'),
(2, '20180330232629', NULL, NULL, NULL, NULL, NULL, '0'),
(4, '20181103012656', NULL, NULL, NULL, NULL, NULL, '0');

-- --------------------------------------------------------

--
-- Table structure for table `users_groups_auth`
--

CREATE TABLE `users_groups_auth` (
  `ID` int(11) NOT NULL,
  `Auth_Group` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users_groups_auth`
--

INSERT INTO `users_groups_auth` (`ID`, `Auth_Group`) VALUES
(1, 'Another Test Group'),
(1, 'Test Group');

-- --------------------------------------------------------

--
-- Table structure for table `user_events`
--

CREATE TABLE `user_events` (
  `ID` int(11) NOT NULL,
  `Event_Type` bigint(20) UNSIGNED NOT NULL,
  `Sequence_Expires` varchar(14) NOT NULL,
  `Sequence_Start_Time` varchar(14) NOT NULL,
  `Sequence_Count` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `actions_auth`
--
ALTER TABLE `actions_auth`
  ADD PRIMARY KEY (`Auth_Action`);

--
-- Indexes for table `core_values`
--
ALTER TABLE `core_values`
  ADD UNIQUE KEY `tableKey` (`tableKey`);

--
-- Indexes for table `db_backup_meta`
--
ALTER TABLE `db_backup_meta`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `events_rulebook`
--
ALTER TABLE `events_rulebook`
  ADD PRIMARY KEY (`Event_Category`,`Event_Type`,`Sequence_Number`);

--
-- Indexes for table `groups_actions_auth`
--
ALTER TABLE `groups_actions_auth`
  ADD PRIMARY KEY (`Auth_Group`,`Auth_Action`),
  ADD KEY `Auth_Action` (`Auth_Action`);

--
-- Indexes for table `groups_auth`
--
ALTER TABLE `groups_auth`
  ADD PRIMARY KEY (`Auth_Group`);

--
-- Indexes for table `ipv4_range`
--
ALTER TABLE `ipv4_range`
  ADD PRIMARY KEY (`Prefix`,`IP_From`,`IP_To`),
  ADD KEY `ExpiresIndex` (`Expires`);

--
-- Indexes for table `ip_events`
--
ALTER TABLE `ip_events`
  ADD PRIMARY KEY (`IP`,`Event_Type`,`Sequence_Start_Time`),
  ADD UNIQUE KEY `IP` (`IP`,`Event_Type`,`Sequence_Expires`);

--
-- Indexes for table `ip_list`
--
ALTER TABLE `ip_list`
  ADD PRIMARY KEY (`IP`),
  ADD KEY `ExpiresIndex` (`IP_Type`,`Expires`);

--
-- Indexes for table `login_history`
--
ALTER TABLE `login_history`
  ADD PRIMARY KEY (`Username`,`IP`);

--
-- Indexes for table `logs_active`
--
ALTER TABLE `logs_active`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `mail_auth`
--
ALTER TABLE `mail_auth`
  ADD PRIMARY KEY (`Name`);

--
-- Indexes for table `mail_templates`
--
ALTER TABLE `mail_templates`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `object_cache`
--
ALTER TABLE `object_cache`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Ob_Group` (`Ob_Group`),
  ADD KEY `Ob_Group_2` (`Ob_Group`);

--
-- Indexes for table `object_cache_meta`
--
ALTER TABLE `object_cache_meta`
  ADD PRIMARY KEY (`Group_Name`);

--
-- Indexes for table `object_map`
--
ALTER TABLE `object_map`
  ADD PRIMARY KEY (`Map_Name`);

--
-- Indexes for table `settings_mailsettings`
--
ALTER TABLE `settings_mailsettings`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `settings_pagesettings`
--
ALTER TABLE `settings_pagesettings`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `settings_sitesettings`
--
ALTER TABLE `settings_sitesettings`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `settings_usersettings`
--
ALTER TABLE `settings_usersettings`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `test_euler_tree1_tree`
--
ALTER TABLE `test_euler_tree1_tree`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `test_euler_tree1_tree_meta`
--
ALTER TABLE `test_euler_tree1_tree_meta`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `test_euler_tree2_tree`
--
ALTER TABLE `test_euler_tree2_tree`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `test_euler_tree2_tree_meta`
--
ALTER TABLE `test_euler_tree2_tree_meta`
  ADD PRIMARY KEY (`settingKey`);

--
-- Indexes for table `test_pactions_auth`
--
ALTER TABLE `test_pactions_auth`
  ADD PRIMARY KEY (`Auth_Action`);

--
-- Indexes for table `test_pgroups_auth`
--
ALTER TABLE `test_pgroups_auth`
  ADD PRIMARY KEY (`Auth_Group`),
  ADD KEY `LastChangedIndex` (`Last_Changed`);

--
-- Indexes for table `test_pusers`
--
ALTER TABLE `test_pusers`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `Username` (`Username`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `loginIndex` (`Email`);

--
-- Indexes for table `test_table`
--
ALTER TABLE `test_table`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `tree_map`
--
ALTER TABLE `tree_map`
  ADD PRIMARY KEY (`treeName`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `Username` (`Username`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `loginIndex` (`Email`);

--
-- Indexes for table `users_actions_auth`
--
ALTER TABLE `users_actions_auth`
  ADD PRIMARY KEY (`ID`,`Auth_Action`),
  ADD KEY `Auth_Action` (`Auth_Action`);

--
-- Indexes for table `users_auth`
--
ALTER TABLE `users_auth`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `users_extra`
--
ALTER TABLE `users_extra`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Banned_Until` (`Banned_Until`),
  ADD KEY `Suspicious_Until` (`Suspicious_Until`);

--
-- Indexes for table `users_groups_auth`
--
ALTER TABLE `users_groups_auth`
  ADD PRIMARY KEY (`ID`,`Auth_Group`),
  ADD KEY `Auth_Group` (`Auth_Group`);

--
-- Indexes for table `user_events`
--
ALTER TABLE `user_events`
  ADD PRIMARY KEY (`ID`,`Event_Type`,`Sequence_Start_Time`),
  ADD UNIQUE KEY `ID` (`ID`,`Event_Type`,`Sequence_Expires`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `db_backup_meta`
--
ALTER TABLE `db_backup_meta`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;
--
-- AUTO_INCREMENT for table `logs_active`
--
ALTER TABLE `logs_active`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `mail_templates`
--
ALTER TABLE `mail_templates`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `object_cache`
--
ALTER TABLE `object_cache`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;
--
-- AUTO_INCREMENT for table `test_pusers`
--
ALTER TABLE `test_pusers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `test_table`
--
ALTER TABLE `test_table`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `groups_actions_auth`
--
ALTER TABLE `groups_actions_auth`
  ADD CONSTRAINT `groups_actions_auth_ibfk_1` FOREIGN KEY (`Auth_Group`) REFERENCES `groups_auth` (`Auth_Group`) ON DELETE CASCADE,
  ADD CONSTRAINT `groups_actions_auth_ibfk_2` FOREIGN KEY (`Auth_Action`) REFERENCES `actions_auth` (`Auth_Action`) ON DELETE CASCADE;

--
-- Constraints for table `login_history`
--
ALTER TABLE `login_history`
  ADD CONSTRAINT `login_history_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `users` (`Username`) ON DELETE CASCADE;

--
-- Constraints for table `users_actions_auth`
--
ALTER TABLE `users_actions_auth`
  ADD CONSTRAINT `users_actions_auth_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_actions_auth_ibfk_2` FOREIGN KEY (`Auth_Action`) REFERENCES `actions_auth` (`Auth_Action`) ON DELETE CASCADE;

--
-- Constraints for table `users_auth`
--
ALTER TABLE `users_auth`
  ADD CONSTRAINT `users_auth_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE;

--
-- Constraints for table `users_extra`
--
ALTER TABLE `users_extra`
  ADD CONSTRAINT `users_extra_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE;

--
-- Constraints for table `users_groups_auth`
--
ALTER TABLE `users_groups_auth`
  ADD CONSTRAINT `users_groups_auth_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_groups_auth_ibfk_2` FOREIGN KEY (`Auth_Group`) REFERENCES `groups_auth` (`Auth_Group`) ON DELETE CASCADE;

--
-- Constraints for table `user_events`
--
ALTER TABLE `user_events`
  ADD CONSTRAINT `user_events_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
