<?php
namespace IOFrame{
    define('abstractDB',true);

    if(!defined('abstractLogger'))
        require 'abstractLogger.php';
    if(!defined('SQLHandler'))
        require 'SQLHandler.php';
    use Monolog\Logger;
    use Monolog\Handler\IOFrameHandler;

    /**
     * To be extended by modules operate user info (login, register, etc)
     * @author Igal Ogonov <igal1333@hotmail.com>
     * @license LGPL
     * @license https://opensource.org/licenses/LGPL-3.0 GNU Lesser General Public License version 3
     */
    abstract class abstractDB extends abstractLogger
    {



        /** Default limit to getting stuff from the DB.
         * */
        protected $defaultQueryLimit = 10000;

        /** Starting from this abstract class and up, everything needs to decide it's default settings mode.
         *  This dictates how handlers extending this class will create settings, and should be set in the main function.
         * */
        protected $defaultSettingsParams;

        /** The site settings
         * */
        protected $siteSettings = null;


        /**
         * Basic construction function
         * @param Handlers\SettingsHandler $localSettings Settings handler containing LOCAL settings.
         * @param array $params An potentially containing an SQLHandler and/or a logger.
         */
        public function __construct(Handlers\SettingsHandler $localSettings,  $params = []){

            //Set defaults
            if(!isset($params['SQLHandler']))
                $SQLHandler = null;
            else
                $SQLHandler = $params['SQLHandler'];

            if(!isset($params['opMode']))
                $opMode = Handlers\SETTINGS_OP_MODE_LOCAL;
            else
                $opMode = $params['opMode'];

            if(isset($params['limit']))
                $this->defaultQueryLimit = $params['limit'];

            //Has to be set before parent construct due to SQLHandler depending on it, and Logger depending on the outcome
            $this->settings=$localSettings;
            $this->SQLHandler = ($SQLHandler == null)? new Handlers\SQLHandler($this->settings) : $SQLHandler;

            //In case it was missing earlier, it isn't anymore. Make sure to pass it to the Logger
            $params['SQLHandler'] = $this->SQLHandler;

            //Starting from this class, extending classes have to decide their default setting mode.
            $this->defaultSettingsParams['opMode'] = $opMode;
            if($opMode != Handlers\SETTINGS_OP_MODE_LOCAL)
                $this->defaultSettingsParams['SQLHandler'] = $this->SQLHandler;

            //This is also where the site settings are added, if they were provided, as they are the first settings
            //that require a db connection
            if(isset($params['siteSettings']))
                $this->siteSettings = $params['siteSettings'];
            else
                $this->siteSettings = null;

            parent::__construct($localSettings,$params);
        }


        /** Retrieves from a table, by key names.
         * @param array $keys Array of keys. If empty, will return the whole table.
         * @param string|array $keyCol Key column name
         * @param string $tableName Name of the table WITHOUT THE PREFIX
         * @param string[] $columns Array of column names.
         * @param array $params
         *              'limit' => SQL parameter LIMIT
         *              'offset'=> SQL parameter OFFSET. Only changes anything if limit is set.
         *              'orderBy'=> Same as SQLHandler
         *              'orderType'=> Same as SQLHandler
         *              'extraConditions'   => Extra conditions one may pass,
         *              'extraKeyColumns'   => Array of additional columns that are considered key columns.
         *              'keyColumnPrefixes' => Array of prefixes to prepend to the key columns when building the query.
         *              'keyDelimiter' => Sometimes, the key columns are multiple, and you wish to get results by them.
         *                                Then, you pass the delimiter (in the example - '/').
         *                                Then, one of two things happen:
         *                                1)You pass an array as $keyCol. Once the results are fetched, the columns
         *                                  in $keyCol are glued by the delimiter to form the identifier that is returned.
         *                                  For example, if you fetched the columns ['Vehicle_Type','Model'], and fetched
         *                                  the models "volvo" and "ford", you'll get "car/volvo" and "car/ford" as the
         *                                  keys of the result array.
         *                                2)You pass strings as keys, but also have extraKeyColumns. For example, you
         *                                  pass 'Vehicle_Type' as the column, but you want to fetch all the different
         *                                  vehicles of the type 'car', not just 1 car.
         *                                  In that case you'll get "car/volvo","car/ford","car/toyota" as result keys
         *                                  (assuming those are all the cars).
         *                                Only works if the delimiter is illegal as a normal character.
         *
         * @returns mixed
         * a result in the form [<keyName> => <Associated array for row>]
         *  or
         * false if nothing exists, or on different error
         * */
        protected function getFromTableByKey(array $keys, $keyCol, string $tableName, array $columns = [], array $params = []){
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $extraConditions = isset($params['extraConditions'])? $params['extraConditions'] : [];

            if(isset($params['limit']))
                $limit = min((int)$params['limit'],$this->defaultQueryLimit);
            else
                $limit = $this->defaultQueryLimit;

            if(isset($params['offset']))
                $offset = $params['offset'];
            else
                $offset = null;

            if(isset($params['extraKeyColumns']))
                $extraKeyColumns = $params['extraKeyColumns'];
            else
                $extraKeyColumns = [];

            if(isset($params['keyColumnPrefixes']))
                $keyColumnPrefixes = $params['keyColumnPrefixes'];
            else
                $keyColumnPrefixes = [];

            if(isset($params['keyDelimiter'])){
                $keyDelimiter = $params['keyDelimiter'];
            }
            else{
                if(gettype($keyCol) === 'array' && count(array_merge($keyCol,$extraKeyColumns)) > 1)
                    $keyDelimiter = '/';
                else
                    $keyDelimiter = '';
            }

            if(isset($params['orderBy'])){
                $orderBy = $params['orderBy'];
                if(isset($params['orderType']))
                    $orderType = $params['orderType'];
                else
                    $orderType = 0;
            }
            else{
                $orderBy = null;
                $orderType = 0;
            }

            //If $keyCol is a string, make it into a length 1 array
            if(gettype($keyCol) === 'string')
                $keyCol = [$keyCol];

            //Separate key columns and columnts to retrieve by
            $retrieveByCol = $keyCol;

            //Add each key column
            foreach($retrieveByCol as $index=>$colName){
                //Append prefixes
                if(isset($keyColumnPrefixes[$index]))
                    $retrieveByCol[$index] = $keyColumnPrefixes[$index].$colName;
                //We always have to get the key column
                if(!in_array($colName,$columns) && $columns!=[]){
                    array_push($columns,$retrieveByCol[$index]);
                }
            }

            $conds = [];
            $tableName = $this->SQLHandler->getSQLPrefix().$tableName;
            $tempRes = [];

            //If keys are not empty, we need to get specific rows
            if($keys != []){

                //Parse the key if we have a delimiter
                foreach($keys as $i=>$key){
                    if(gettype($key) === 'array')
                        $key = implode($keyDelimiter,$key);
                    else
                        $keys[$i] = [$keys[$i]];
                    $tempRes[$key] = 1;
                }

                //Add all of the keys to the conditions
                foreach($keys as $i => $keyArray){
                    foreach($keys[$i] as $j => $key){
                        if(gettype($key) == 'string')
                            $keys[$i][$j] = [$key,'STRING'];
                    }
                    $keys[$i] = [$keys[$i],'CSV'];
                    array_push($conds,$keys[$i]);
                }
            }

            //If keys were not empty, conditions need to be specific
            if($conds != []){
                array_push($conds,'CSV');
                array_push($retrieveByCol,'CSV');
                $conds = [
                    $retrieveByCol,
                    $conds,
                    'IN'
                ];
            }

            if($extraConditions != []){
                if($conds !== [])
                    $conds =  [
                        $conds,
                        $extraConditions,
                        'AND'
                    ];
                else
                    $conds = $extraConditions;
            }

            $res = $this->SQLHandler->selectFromTable(
                $tableName,
                $conds,
                $columns,
                ['test'=>$test,'verbose'=>$verbose,'limit'=>$limit,'offset'=>$offset,'orderBy'=>$orderBy,'orderType'=>$orderType]
            );
            if(is_array($res)){
                $resLength = count($res);
                for($i = 0; $i<$resLength; $i+=1){
                    $resLength2 = count($res[$i]);
                    for($j = 0; $j<$resLength2; $j++){
                        unset($res[$i][$j]);//This is ok because no valid column name will consist solely of digits
                    }

                    //Calculate the identifier
                    $identifier = [];
                    foreach($keyCol as $colID){
                        array_push($identifier,$res[$i][$colID]);
                    }
                    $identifier = implode($keyDelimiter,$identifier);

                    //Here we have no extra columns, or multiple ones
                    if(count($extraKeyColumns) > 0){
                        foreach($extraKeyColumns as $extraKeyColumn){
                            $identifier .= $keyDelimiter.$res[$i][$extraKeyColumn];
                        }
                    }
                    $tempRes[$identifier] = $res[$i];
                }

                //If we have extra key columns, remove original keys from the result
                if(count($extraKeyColumns) > 0){
                    foreach($keys as $i=>$keyArray){
                        $dbFormattedKeys = $keyArray[0];
                        $keys = [];
                        foreach($dbFormattedKeys as $pair)
                            array_push($keys,$pair[0]);
                        $keyToUnset = implode($keyDelimiter,$keys);
                        unset($tempRes[$keyToUnset]);
                    }
                }

                return $tempRes;
            }
            else{
                return false;
            }
        }


    }

}