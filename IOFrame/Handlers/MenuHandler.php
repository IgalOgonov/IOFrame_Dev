<?php
namespace IOFrame\Handlers{
    use IOFrame;
    use Monolog\Logger;
    use Monolog\Handler\IOFrameHandler;
    define('MenuHandler',true);
    if(!defined('abstractObjectsHandler'))
        require 'abstractObjectsHandler.php';

    /** The menu handler is meant to handle simple menus, typically stored in the CORE_VALUES tables as single entries.
     *  Basically, much of the functionality here is extremely simple, since the \ docs menu is just a single JSON entry
     *  in CORE_VALUES.
     * @author Igal Ogonov <igal1333@hotmail.com>
     * @license LGPL
     * @license https://opensource.org/licenses/LGPL-3.0 GNU Lesser General Public License version 3
     */
    class MenuHandler extends IOFrame\abstractDBWithCache{


        /**
         * @var string The table name where the menu resides
         */
        protected $tableName = 'CORE_VALUES';

        /**
         * @var string The table key column for the menu
         */
        protected $tableKeyCol = 'tableKey';

        /**
         * @var string The table column storing the value of the menu
         */
        protected $menuValueCol = 'tableValue';

        /**
         * @var string The identifier of the menu in the table
         */
        protected $menuIdentifier = '';

        /**
         * @var string The cache name for the menu
         */
        protected $cacheName = 'menu_';

        /**
         * Basic construction function
         * @param SettingsHandler $settings local settings handler.
         * @param array $params Typical default settings array
         */
        function __construct(SettingsHandler $settings, $params = []){

            //Either the child passes menuIdentifier
            if(isset($params['menuIdentifier']))
                $this->menuIdentifier = $params['menuIdentifier'];
            //Or it has it set - otherwise, throw exception
            elseif($this->menuIdentifier === '')
                throw new \Exception('menuIdentifier must be set by the parent or passed to this handler directly!');

            //By default, menu's should have a much higher priority than regular cached items.
            if(!isset($params['cacheTTL']))
                $params['cacheTTL'] = 24*3600;
            parent::__construct($settings,$params);
        }

        /** Get menu.
         * @param array $params
         *              'safeStr' - bool, whether item is stored in safestring by default.
         * @returns int|array JSON decoded object of the form:
         * {
         *      <string, "identifier"  of the menu item used for stuff like routing. Assumed to not contain "/".> => {
         *          ['title': <string, Title of the menu item>]
         *          ['children': <array, objects of the same structure as this one>]
         *          //Potentially more stuff, depending on the extending class
         *     },
         *     ...
         * }
         * Or one of the following codes:
         *      -3 Menu not a valid json somehow
         *      -2 Menu not found for some reason
         *      -1 Database Error
         */
        function getMenu(array $params = []){
            $safeStr = isset($params['safeStr'])? $params['safeStr'] : true;

            $result = $this->getFromCacheOrDB(
                [$this->menuIdentifier],
                $this->tableKeyCol,
                $this->tableName,
                $this->cacheName,
                [],
                $params
            )[$this->menuIdentifier];

            if(is_array($result)){
                $result = $result[$this->menuValueCol];
                if(empty($result))
                    $result = [];
                else{
                    if($safeStr)
                        $result = IOFrame\Util\safeStr2Str($result);
                    if(!IOFrame\Util\is_json($result))
                        $result =  -3;
                    else
                        $result = json_decode($result, true);
                }
            }
            elseif($result === 1)
                $result = -2;

            return $result;
        }


        /** Sets (or unsets) a menu item.
         * @param array $inputs of the form:
         *          'address' - string, array of valid identifiers that represent parents. defaults to [] (menu root).
         *                      If a non-existent parent is referenced, will not add the item.
         *          'identifier' - string, "identifier"  of the menu item used for stuff like routing. Assumed to not contain "/".
         *          ['delete' - bool, if true, deletes the item instead of modifying.]
         *          ['title': string, Title of the menu item]
         *          //Potentially more stuff, depending on the extending class
         * @param array $params of the form:
         *          'safeStr' - bool, default true. Whether to convert Meta to a safe string
         * @returns int Code of the form:
         *      -3 Menu not a valid json somehow
         *      -2 Menu not found for some reason
         *      -1 Database Error
         *       0 All good
         *       1 One of the parents not found
         */
        function setMenuItem( array $inputs, array $params = []){
            return $this->setMenuItems([$inputs],$params);
        }

        /** Sets (or unsets) multiple menu item.
         * @param array $inputs Array of input arrays in the same order as the inputs in setMenuItem, HOWEVER:
         *              'address' can also include parents created from inputs in the $inputs array - AS LONG AS THEY
         *                        CAME EARLIER that the child in the array.
         * @param array $params from setMenuItem
         * @returns int Code of the form:
         *      -3 Menu not a valid json somehow
         *      -2 Menu not found for some reason
         *      -1 Database Error
         *       0 All good
         *       1 One of the parents FOR ANY OF THE ITEMS not found
         */
        function setMenuItems(array $inputs, array $params = []){
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $safeStr = isset($params['safeStr'])? $params['safeStr'] : true;

            if(isset($params['existing']))
                $existingMenu = $params['existing'];
            else
                $existingMenu = $this->getMenu(array_merge($params,['updateCache'=>false]));

            if(!is_array($existingMenu))
                return $existingMenu;

            foreach($inputs as $index => $inputArray){
                $target = &$existingMenu;
                if(!empty($inputArray['address']))
                    foreach($inputArray['address'] as $addrIndex => $address){
                        if(isset($target['children'][$address]))
                            $target = &$target['children'][$address];
                        else{
                            if($verbose)
                                echo 'Input '.$index.' address #'.$addrIndex.': '.$address.' does not exist!'.EOL;
                            return 1;
                        }
                    }

                if(empty($target['children']))
                    $target['children'] = [];
                if(empty($target['children'][$inputArray['identifier']]))
                    $target['children'][$inputArray['identifier']] = [];
                //Yes, unset it if you create it when it doesn't exist. I know. It still is structured better this way.
                if(!empty($inputArray['delete']))
                    unset($target['children'][$inputArray['identifier']]);
                else
                    foreach($inputArray as $inputIndex => $input){
                        if(!in_array($inputIndex,['children','identifier','delete','address']))
                            $target['children'][$inputArray['identifier']][$inputIndex] = $input;
                    }
            }

            $existingMenu = json_encode($existingMenu);
            if($safeStr)
                $existingMenu = IOFrame\Util\str2SafeStr($existingMenu);

            $res = $this->SQLHandler->updateTable(
                $this->SQLHandler->getSQLPrefix().$this->tableName,
                [$this->menuValueCol.' = "'.$existingMenu.'"'],
                [$this->tableKeyCol,$this->menuIdentifier,'='],
                $params
            );
            if($res){
                $res = 0;
                if(!$test)
                    $this->RedisHandler->call('del',[$this->cacheName.$this->menuIdentifier]);
                if($verbose)
                    echo 'Deleting cache of '.$this->cacheName.$this->menuIdentifier.EOL;
            }
            else
                $res = -1;
            return $res;
        }

        /** Moves one branch of the menu to a different root
         * @param array $inputs Array of input arrays in the same order as the inputs in setMenuItem, HOWEVER:
         *              'address' can also include parents created from inputs in the $inputs array - AS LONG AS THEY
         *                        CAME EARLIER that the child in the array.
         * @param array $params from setMenuItem
         * @returns int Code of the form:
         *      -3 Menu not a valid json somehow
         *      -2 Menu not found for some reason
         *      -1 Database Error
         *       0 All good
         *       1 One of the parents for the source not found
         *       2 One of the parents for the target not found
         *       3 Source identifier does not exist
         *       4 Source and target are the same (really?!)
         */
        function moveMenuBranch(string $identifier, array $sourceAddress, array $targetAddress, array $params = []){
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $safeStr = isset($params['safeStr'])? $params['safeStr'] : true;

            if(count($sourceAddress) === count($targetAddress) && count(array_diff($sourceAddress,$targetAddress)) === 0)
                return 4;

            if(isset($params['existing']))
                $existingMenu = $params['existing'];
            else
                $existingMenu = $this->getMenu(array_merge($params,['updateCache'=>false]));

            if(!is_array($existingMenu))
                return $existingMenu;

            $source = &$existingMenu;
            if(!empty($sourceAddress))
                foreach($sourceAddress as $address)
                    if(isset($source['children'][$address]))
                        $source = &$source['children'][$address];
                    else
                        return 1;

            $target = &$existingMenu;
            if(!empty($targetAddress))
                foreach($targetAddress as $address)
                    if(isset($target['children'][$address]))
                        $target = &$target['children'][$address];
                    else
                        return 2;

            if(empty($source['children'][$identifier]))
                return 3;

            if(empty($target['children']))
                $target['children'] = [];

            $target['children'][$identifier] = $source['children'][$identifier];
            unset($source['children'][$identifier]);

            $existingMenu = json_encode($existingMenu);
            if($safeStr)
                $existingMenu = IOFrame\Util\str2SafeStr($existingMenu);

            $res = $this->SQLHandler->updateTable(
                $this->SQLHandler->getSQLPrefix().$this->tableName,
                [$this->menuValueCol.' = "'.$existingMenu.'"'],
                [$this->tableKeyCol,$this->menuIdentifier,'='],
                $params
            );
            if($res){
                $res = 0;
                if(!$test)
                    $this->RedisHandler->call('del',[$this->cacheName.$this->menuIdentifier]);
                if($verbose)
                    echo 'Deleting cache of '.$this->cacheName.$this->menuIdentifier.EOL;
            }
            else
                $res = -1;
            return $res;
        }


    }

}

?>