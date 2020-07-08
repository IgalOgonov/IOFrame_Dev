<?php
namespace IOFrame\Handlers{
    use IOFrame;
    use Monolog\Logger;
    use Monolog\Handler\IOFrameHandler;
    define('ObjectAuthHandler',true);
    if(!defined('abstractDBWithCache'))
        require 'abstractDBWithCache.php';

    /**Handles Object permissions in IOFrame.
     * Object auth is the only scheme in IOFrame that has no meaning by itself, and instead is meant to be tied to
     * different types of objects that might have permissions.
     * Think about a project management system:
     * Each project (the object) has many groups - the client(s), the architect, the project manager.. maybe some
     * those are one person, maybe some are multiple.
     * Each group/person have different permissions - for example, the project manager may see everything, while
     * the plumbing company just needs to see the project files that have the "plumbing" tag.
     * In the above case, you assign the people from the plumbing company to the "Plumbers" group, and give
     * them a specific action - akin to "VIEW_PLUMBING_FILES" - which is TIED TO THIS PROJECT.
     * If a new person from the plumbing company joined the project, he can be assigned into the "plumbing" group which has all relevant premissions.
     * Alternatively, if the project manager decides the interior designer suddenly needs to see the plumbing files, he may
     * give him the "VIEW_PLUMBING_FILES" permission individually.
     * The object auth is only meant to provide a framework for such permission systems, not have explicit meaning by itself.
     * @author Igal Ogonov <igal1333@hotmail.com>
     * @license LGPL
     * @license https://opensource.org/licenses/LGPL-3.0 GNU Lesser General Public License version 3
     */
    class ObjectAuthHandler extends IOFrame\abstractDBWithCache{

        /** @var array $objectsDetails Categories table details, array of the following form:
         *                  [
         *                      'tableName' => string - the name of the objects table
                                'cacheName'=> string - cache prefix
         *                      'keyColumns' => string[] - key column names.
         *                      'extraKeyColumns' => Columns which are key, but should not be queried (keys in one-to-many relationships, like one user having many actions).
         *                      'setColumns' => array of objects, where each object is of the form:
         *                                      <column name> => [
         *                                          'type' => 'int'/'string'/'bool'/'double' - type of the column for purposes of the SQL query,
         *                                          'default' =>  any possible value including null,
         *                                          'required' => true / false - whether this column is required when creating new objects,
         *                                          'jsonArray' => bool, default false - if set and true, will treat the field
         *                                                         as a JSON
         *                                          'autoIncrement' => bool, if set, indicates that this column auto-increments (doesn't need to be set on creation)
         *                                      ]
         *                      'moveColumns' => array of objects, where each object is of the form:
         *                                      <column name> => [
         *                                          'type' => 'int'/'string'/'bool'/'double' - type of the column for purposes of the SQL query,
         *                                          'inputName' => string, name of the input key relevant to this
         *                                      ]
         *                      'columnFilters' => object of objects, where each object is of the form:
         *                                      <filter name> => [
         *                                          'column' => string, name of relevant column
         *                                          'filter' => string, one of the filters from the abstract class abstractDBWithCache:
         *                                                      '>','<','=', '!=', 'IN', 'RLIKE' and 'NOT RLIKE'
         *                                          'default' => if set, will be the default value for this filter
         *                                          'alwaysSend' => if set to true, will always send the filter. Has to have 'default'
         *                                      ],
         *                      'extraToGet' => object of objects, extra meta-data to get when getting multiple items,
         *                                      where each object is of the form:
         *                                      <column name> => [
         *                                          'key' => string, key under which the results will be added to '@'
         *                                          'type' => string, either 'min'/'max' (range values), 'count' (the key doesn't matter here)
         *                                                    or 'distinct' (get all distinct values)
         *                                      ],
         *                      'orderColumns' => array of column names by which it is possible to order the query.
         *                      'groupByFirstNKeys' => int, default 0 - whether to group results by the first n keys (less than the total number of keys).
         *                                             relevant for stuff like user actions
         *                      'autoIncrement' => bool, default false - whether the main identifier auto-increments
         *                  ]
         * */
        protected $categoriesDetails=[
            'tableName' => 'OBJECT_AUTH_CATEGORIES',
            'cacheName'=> 'object_auth_category_',
            'keyColumns' => ['Object_Auth_Category'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true,
                    'autoIncrement' => true
                ],
                'Title' => [
                    'type' => 'string',
                    'default' => null,
                    'required' => false
                ]
            ],
            'columnFilters' => [
                'titleLike' => [
                    'column' => 'Title',
                    'filter' => 'RLIKE'
                ],
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category'],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
            ],
            'autoIncrement' => true,
        ];


        /** @var array $objectsDetails Object table details, array of the following form:
         *                  [
         *                      ...
         *                      'isPublicColumn' => string, default null - column that indicates whether the object is public (a boolean column) -
         *                                          generally used only for viewing. If null, it means no objects of this handler's type can be public.
         *                  ]
         * */
        protected $objectsDetails= [
            'tableName' => 'OBJECT_AUTH_OBJECTS',
            'cacheName'=> 'object_auth_object_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Object'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'required' => true
                ],
                'Title' => [
                    'type' => 'string',
                    'default' => null,
                    'required' => false
                ],
                'Is_Public' => [
                    'type' => 'bool',
                    'default' => false,
                    'required' => false
                ]
            ],
            'moveColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'inputName' => 'New_Category'
                ]
            ],
            'columnFilters' => [
                'titleLike' => [
                    'column' => 'Title',
                    'filter' => 'RLIKE'
                ],
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'objectLike' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'RLIKE'
                ],
                'objectIn' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'IN'
                ],
                'isPublic' => [
                    'column' => 'Is_Public',
                    'filter' => '=',
                    'default' => 1,
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object'],
            'isPublicColumn' => 'Is_Public'
        ];

        protected $actionsDetails=[
            'tableName' => 'OBJECT_AUTH_ACTIONS',
            'cacheName'=> 'object_auth_action_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Action'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Action' => [
                    'type' => 'string',
                    'required' => true
                ],
                'Title' => [
                    'type' => 'string',
                    'default' => null,
                    'required' => false
                ]
            ],
            'moveColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'inputName' => 'New_Category'
                ]
            ],
            'columnFilters' => [
                'titleLike' => [
                    'column' => 'Title',
                    'filter' => 'RLIKE'
                ],
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'actionLike' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'RLIKE'
                ],
                'actionIn' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'IN'
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object','Object_Auth_Action'],
        ];

        protected $groupsDetails=[
            'tableName' => 'OBJECT_AUTH_GROUPS',
            'cacheName'=> 'object_auth_group_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Object','Object_Auth_Group'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'required' => true
                ],
                'Object_Auth_Group' => [
                    'type' => 'int',
                    'required' => true,
                    'autoIncrement' => true
                ],
                'Title' => [
                    'type' => 'string',
                    'default' => null,
                    'required' => false
                ]
            ],
            'moveColumns' => [
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'inputName' => 'New_Object'
                ],
            ],
            'columnFilters' => [
                'titleLike' => [
                    'column' => 'Title',
                    'filter' => 'RLIKE'
                ],
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'objectLike' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'RLIKE'
                ],
                'objectIn' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'IN'
                ],
                'groupIs' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => '='
                ],
                'groupIn' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => 'IN'
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
                'Object_Auth_Object' => [
                    'key' => 'objects',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object','Object_Auth_Group'],
            'autoIncrement' => true,
        ];

        protected $objectUsersDetails=[
            'tableName' => 'OBJECT_AUTH_OBJECT_USERS',
            'cacheName'=> 'object_auth_object_user_actions_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Object','ID'],
            'extraKeyColumns' => ['Object_Auth_Action'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'required' => true
                ],
                'ID' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Action' => [
                    'type' => 'string',
                    'required' => true
                ]
            ],
            'moveColumns' => [
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'inputName' => 'New_Object'
                ],
            ],
            'columnFilters' => [
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'objectLike' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'RLIKE'
                ],
                'objectIn' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'IN'
                ],
                'userIDIs' => [
                    'column' => 'ID',
                    'filter' => '='
                ],
                'userIDIn' => [
                    'column' => 'ID',
                    'filter' => 'IN'
                ],
                'actionLike' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'RLIKE'
                ],
                'actionIn' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'IN'
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
                'Object_Auth_Object' => [
                    'key' => 'objects',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object','ID','Object_Auth_Action'],
            'groupByFirstNKeys'=>3,
        ];

        protected $objectGroupsDetails=[
            'tableName' => 'OBJECT_AUTH_OBJECT_GROUPS',
            'cacheName'=> 'object_auth_object_group_actions_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Object','Object_Auth_Group'],
            'extraKeyColumns' => ['Object_Auth_Action'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'required' => true
                ],
                'Object_Auth_Group' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Action' => [
                    'type' => 'string',
                    'required' => true
                ]
            ],
            'moveColumns' => [
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'inputName' => 'New_Object'
                ],
            ],
            'columnFilters' => [
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'objectLike' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'RLIKE'
                ],
                'objectIn' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'IN'
                ],
                'groupIs' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => '='
                ],
                'groupIn' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => 'IN'
                ],
                'actionLike' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'RLIKE'
                ],
                'actionIn' => [
                    'column' => 'Object_Auth_Action',
                    'filter' => 'IN'
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
                'Object_Auth_Object' => [
                    'key' => 'objects',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object','Object_Auth_Group','Object_Auth_Action'],
            'groupByFirstNKeys'=>3,
        ];

        protected $userGroupsDetails=[
            'tableName' => 'OBJECT_AUTH_USERS_GROUPS',
            'cacheName'=> 'object_auth_object_user_groups_',
            'keyColumns' => ['Object_Auth_Category','Object_Auth_Object','ID'],
            'extraKeyColumns' => ['Object_Auth_Group'],
            'setColumns' => [
                'Object_Auth_Category' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'required' => true
                ],
                'ID' => [
                    'type' => 'int',
                    'required' => true
                ],
                'Object_Auth_Group' => [
                    'type' => 'int',
                    'required' => true
                ],
            ],
            'moveColumns' => [
                'Object_Auth_Object' => [
                    'type' => 'string',
                    'inputName' => 'New_Object'
                ],
            ],
            'columnFilters' => [
                'categoryIs' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => '='
                ],
                'categoryIn' => [
                    'column' => 'Object_Auth_Category',
                    'filter' => 'IN'
                ],
                'objectLike' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'RLIKE'
                ],
                'objectIn' => [
                    'column' => 'Object_Auth_Object',
                    'filter' => 'IN'
                ],
                'userIDIs' => [
                    'column' => 'ID',
                    'filter' => '='
                ],
                'userIDIn' => [
                    'column' => 'ID',
                    'filter' => 'IN'
                ],
                'groupIs' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => '='
                ],
                'groupIn' => [
                    'column' => 'Object_Auth_Group',
                    'filter' => 'IN'
                ],
            ],
            'extraToGet' => [
                '#' => [
                    'key' => '#',
                    'type' => 'count'
                ],
                'Object_Auth_Category' => [
                    'key' => 'categories',
                    'type' => 'distinct'
                ],
                'Object_Auth_Object' => [
                    'key' => 'objects',
                    'type' => 'distinct'
                ],
            ],
            'orderColumns' => ['Object_Auth_Category','Object_Auth_Object','ID','Object_Auth_Group'],
            'groupByFirstNKeys'=>3,
        ];

        protected $usersDetails=[
            'tableName' => 'USERS',
            'keyColumns' => ['ID'],
        ];

        /* common filters for all tables*/
        protected $commonFilters=[
            'createdBefore' => [
                'column' => 'Created',
                'filter' => '<'
            ],
            'createdAfter' => [
                'column' => 'Created',
                'filter' => '>'
            ],
            'changedBefore' => [
                'column' => 'Last_Updated',
                'filter' => '<'
            ],
            'changedAfter' => [
                'column' => 'Last_Updated',
                'filter' => '>'
            ],
        ];

        /* common order columns for all tables*/
        protected $commonColumns=[ 'Created' , 'Last_Updated' ];

        /** @var array $objects Used when initiating specific objects - mainly for persistent use
         *             {
         *                  <object id> => [
         *                      'category' => string - object category (part of its identifier)
         *                      'users' => array of user actions of the form:
         *                          [
         *                              <user ID> => [
         *                                               <action_name> => [], //Empty array for now, but will at some point have more data
         *                                               ...,
         *                                               '@' => [
         *                                                           'updated' => int, when the request for all the user's actions was made.
         *                                                      ]
         *                                           ],
         *                              ...
         *                          ],
         *                      'groups' => array of group actions of the form:
         *                          [
         *                              <group id> => [
         *                                               <action_name> => [], //Empty array for now, but will at some point have more data
         *                                               ...,
         *                                               '@' => [
         *                                                           'updated' => int, when the request for all the user's actions was made.
         *                                                      ]
         *                                           ],
         *                              ...
         *                          ],
         *                  ]
         *              }
         * */
        protected $objects=[
            /*
             * 'object_id' =>[
                    'initiated' => true,
                    'category' => 1,
                    'users' => [
                        2 => [
                            'TEST_ACTION_2' => [],
                            'TEST_ACTION_5' => [],
                            '@' =>[
                                'updated' => 1600000000,
                            ]
                       ],
                        5 => [
                            'TEST_ACTION_1' => [],
                            'TEST_ACTION_2' => [],
                            '@' =>[
                                'updated' => 1600000000,
                            ]
                       ],
                    ]
                ];
            */
        ];

        /** @var array $userGroups Used when initiating specific objects (and checking which users are in which groups) - mainly for persistent use
         *             {
         *                  <user id> => [
         *                          <group ID> => [], //Empty array for now, but will at some point have more data
         *                          ...,
         *                          '@' => [
         *                                      'updated' => int, when the request for all the user's groups was made.
         *                                 ]
         *                  ]
         *              }
         * */
        protected $userGroups=[
            /*
             * 'user_id' =>[
                    'group_A' => [],
                    'group_B' => [],
                    '@' =>[
                        'updated' => 1600000000
                    ]
                ],
            */
        ];

        /**
         * Basic construction function
         * @param SettingsHandler $settings local settings handler.
         * @param array $params Typical default settings array
         */
        function __construct(SettingsHandler $settings, $params = []){

            /* Allows dynamically setting table details at construction.
             * As much as I hate variable variables, this is likely one of the only places where their use is for the best.
             * */
            $dynamicParams = ['categoriesDetails','objectsDetails','actionsDetails','groupsDetails','objectUsersDetails','objectGroupsDetails','userGroupsDetails'];
            $additionParams = ['commonFilters','commonColumns'];

            foreach($dynamicParams as $param){
                if(!isset($params[$param]))
                    continue;
                else foreach($this->$param as $index => $defaultValue){
                    if(isset($params[$param][$index]) && (!isset($this->$param[$index]) || gettype($params[$param][$index]) === gettype($this->$param[$index])) )
                        $this->$param[$index] = $params[$param][$index];
                }
            }

            foreach($additionParams as $param){
                if(!isset($params[$param]))
                    continue;
                else
                    $this->$param = array_merge($this->$param , $params[$param]);
            }

            parent::__construct($settings,$params);
        }

        /** Get multiple items
         * @param array $items Array of objects (arrays). Each object needs to contain the keys from they type array's "keyColumns",
         *              each key pointing to the value of the desired item to get.
         *              Defaults to [], which searches through all available items and cannot use the cache.
         * @param string $type Type of items. See the item objects at the top of the class for the parameters of each type.
         * @param array $params of the form:
         *              <valid filter name> - valid filters are found in the type array's "columnFilters" - the param name
         *                                    is the same as the key.
         *              'getAllSubItems' - bool, default false. If true, will get all sub-items and ignore limit even if
         *                                 we are getting all items ($items is [])
         *              --- Usage of the params below disables cache even when searching for specific items ---
         *              'limit' - int, standard SQL parameter
         *              'offset' - int, standard SQL parameter
         *              'orderBy' - string, default null - possible values found in the type array's "orderColumns"
         *              'orderType' - int, default null, possible values 0 and 1 - 0 is 'ASC', 1 is 'DESC'
         *
         * @return array of the form:
         *          [
         *              <identifier - string, all keys separated by "/"> =>
         *                  <DB array. If the type array had the "groupByFirstNKeys" param and we are getting specific items,
         *                   this will be an array of sub-items>,
         *                  OR
         *                  <code int - 1 if specific item that was requested is not found, -1 if there was a DB error>
         *          ]
         *          A DB error when $items is [] will result in an empty array returned, not an error.
         *
         * @throws \Exception If the item type is invalid
         *
         */
        function getItems(array $items = [], string $type, array $params = []){
            switch($type){
                case 'categories':
                case 'objects':
                case 'actions':
                case 'groups':
                case 'objectUsers':
                case 'objectGroups':
                case 'userGroups':
                    $typeArray = $this->{$type.'Details'};
                    break;
                default:
                    throw new \Exception('Invalid items type!');
            }

            $validFilters = array_merge($typeArray['columnFilters'],$this->commonFilters);

            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $getAllSubItems =  isset($params['getAllSubItems']) ? $params['getAllSubItems'] : false;
            if($getAllSubItems){
                $params['limit'] = null;
            }
            $limit = isset($params['limit'])? $params['limit'] : null;
            $offset = isset($params['offset'])? $params['offset'] : null;
            $orderBy = isset($params['orderBy'])? $params['orderBy'] : null;
            $orderType = isset($params['orderType'])? $params['orderType'] : null;
            $keyColumns = $typeArray['keyColumns'];
            $extraKeyColumns = isset($typeArray['extraKeyColumns']) ? $typeArray['extraKeyColumns'] : [];
            $groupByFirstNKeys = isset($typeArray['groupByFirstNKeys']) ? $typeArray['groupByFirstNKeys'] : 0;

            if(!isset($typeArray['orderColumns']) || !in_array($orderBy,$typeArray['orderColumns']))
                $params['orderBy'] = null;

            $retrieveParams = $params;

            //If we are using any of this functionality, we cannot use the cache
            if( $orderBy || $orderType || $offset || $limit){
                $retrieveParams['useCache'] = false;
                $retrieveParams['orderBy'] = $orderBy? $orderBy : null;
                $retrieveParams['orderType'] = $orderType? $orderType : 0;
                $retrieveParams['limit'] =  $limit? $limit : null;
                $retrieveParams['offset'] =  $offset? $offset : null;
            }

            $extraDBConditions = [];
            $extraCacheConditions = [];

            foreach($validFilters as $filterParam => $filterArray){
                if(isset($params[$filterParam])){
                    if(gettype($params[$filterParam]) === 'array'){
                        foreach($params[$filterParam] as $key => $value){
                            $params[$filterParam][$key] = [$value,'STRING'];
                        }
                    }
                    $cond = [$filterArray['column'],$params[$filterParam],$filterArray['filter']];
                    array_push($extraCacheConditions,$cond);
                    array_push($extraDBConditions,$cond);
                }
                elseif(isset($filterArray['default']) && isset($filterArray['alwaysSend'])){
                    $cond = [$filterArray['column'],[$filterArray['default'],'STRING'],$filterArray['filter']];
                    array_push($extraCacheConditions,$cond);
                    array_push($extraDBConditions,$cond);
                }
            }

            if($extraCacheConditions!=[]){
                array_push($extraCacheConditions,'AND');
                $retrieveParams['columnConditions'] = $extraCacheConditions;
            }
            if($extraDBConditions!=[]){
                array_push($extraDBConditions,'AND');
                $retrieveParams['extraConditions'] = $extraDBConditions;
            }

            if($items == []){
                $results = [];
                $selectionColumns = ($groupByFirstNKeys && !$getAllSubItems) ? ['DISTINCT '.implode(',',$keyColumns)] : [];
                $res = $this->SQLHandler->selectFromTable(
                    $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                    $extraDBConditions,
                    $selectionColumns,
                    $retrieveParams
                );
                if(is_array($res)){

                    $resCount = isset($res[0]) ? count($res[0]) : 0;
                    foreach($res as $resultArray){

                        for($i = 0; $i<$resCount/2; $i++)
                            unset($resultArray[$i]);
                        $key = '';
                        foreach($keyColumns as $keyColumn){
                            $key .= $resultArray[$keyColumn].'/';
                        }
                        $key = substr($key,0,strlen($key) - 1);

                        //Convert safeSTR columns to normal
                        foreach($typeArray['setColumns'] as $colName => $colArr){
                            if(isset($colArr['safeStr']) && $colArr['safeStr'])
                                $resultArray[$colName] = IOFrame\Util\safeStr2Str($resultArray[$colName]);
                        }
                        if($groupByFirstNKeys && $getAllSubItems){
                            if(!isset($results[$key]))
                                $results[$key] = [];
                            $results[$key][$resultArray[$extraKeyColumns[0]]] = $resultArray;
                        }
                        else
                            $results[$key] = $resultArray;
                    }

                    if(isset($typeArray['extraToGet']) && $typeArray['extraToGet']){
                        //Prepare the meta information
                        $results['@'] = [];

                        //Get all relevant stuff
                        $selectQuery = '';

                        foreach($typeArray['extraToGet'] as $columnName => $arr){
                            switch($arr['type']){
                                case 'min':
                                case 'max':
                                $selectQuery .= $this->SQLHandler->selectFromTable(
                                        $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                                        $extraDBConditions,
                                        [($arr['type'] === 'min' ? 'MIN('.$columnName.')': 'MAX('.$columnName.')').' AS Val, "'.$columnName.'" as Type'],
                                        ['justTheQuery'=>true,'test'=>false]
                                    ).' UNION ';
                                    break;
                                case 'count':
                                    $selectQuery .= $this->SQLHandler->selectFromTable(
                                            $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                                            $extraDBConditions,
                                            [(($groupByFirstNKeys && !$getAllSubItems)? 'COUNT('.$selectionColumns[0].')': 'COUNT(*)').' AS Val, "'.$columnName.'" as Type'],
                                            ['justTheQuery'=>true,'test'=>false]
                                        ).' UNION ';
                                    break;
                                case 'distinct':
                                    $selectQuery .= $this->SQLHandler->selectFromTable(
                                            $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                                            $extraDBConditions,
                                            [$columnName.' AS Val, "'.$columnName.'" as Type'],
                                            ['justTheQuery'=>true,'DISTINCT'=>true,'test'=>false]
                                        ).' UNION ';
                                    break;
                            }
                        }
                        $selectQuery = substr($selectQuery,0,strlen($selectQuery) - 7);

                        if($verbose)
                            echo 'Query to send: '.$selectQuery.EOL;

                        $response = $this->SQLHandler->exeQueryBindParam($selectQuery,[],['fetchAll'=>true]);

                        if($response){
                            foreach($response as $arr){
                                $columnName = $arr['Type'];
                                $relevantToGetInfo = $typeArray['extraToGet'][$columnName];
                                $key = $relevantToGetInfo['key'];
                                $type = $relevantToGetInfo['type'];
                                if($type !== 'distinct'){
                                    $results['@'][$key] = $arr['Val'];
                                }
                                else{
                                    if(!isset( $results['@'][$key]))
                                        $results['@'][$key] = [];
                                    array_push( $results['@'][$key],$arr['Val']);
                                }
                            }
                        }
                    }
                }
                return $results;
            }
            else{
                $results = $this->getFromCacheOrDB(
                    $items,
                    $keyColumns,
                    $typeArray['tableName'],
                    $typeArray['cacheName'],
                    [],
                    array_merge($retrieveParams,['extraKeyColumns'=>$extraKeyColumns,'groupByFirstNKeys'=>$groupByFirstNKeys])
                );

                foreach($results as $index => $res){
                    if(!is_array($res))
                        continue;
                    //Convert safeSTR columns to normal
                    foreach($typeArray['setColumns'] as $colName => $colArr){
                        if(isset($colArr['safeStr']) && $colArr['safeStr'])
                            $results[$index][$colName] = IOFrame\Util\safeStr2Str($results[$index][$colName]);
                    }
                }

                return $results;
            }
        }

        /** Set multiple items
         * @param array $inputs Array found in the type array's "setColumns". The explanation of the structure is up
         *              at the top of this class,
         * @param string $type Type of items. See the item objects at the top of the class for the parameters of each type.
         * @param array $params of the form:
         *              'update' - bool, whether to only update existing items. Overrides "override".
         *              'override' - bool, whether to allow overriding existing items. Defaults to true,.
         *
         * @returns Array|Int, if not creating new auto-incrementing items, array of the form:
         *          <identifier> => <code>
         *          Where each identifier is the contact identifier, and possible codes are:
         *         -2 - failed to create items since one of the dependencies is missing
         *         -1 - failed to connect to db
         *          0 - success
         *          1 - item does not exist (and update is true)
         *          2 - item exists (and override is false)
         *          3 - trying to create a new item with missing inputs
         *
         *          Otherwise, one of them codes:
         *         -3 - Missing inputs when creating one of the items
         *         -2 - One of the dependencies missing.
         *         -1 - unknown database error
         *          int, >0 - ID of the FIRST created item. If creating more than one items, they can be assumed
         *                    to be created in the order they were passed.
         *
         * @throws \Exception If the item type is invalid
         *
         *
         */
        function setItems(array $inputs, string $type, array $params = []){
            switch($type){
                case 'categories':
                case 'objects':
                case 'actions':
                case 'groups':
                case 'objectUsers':
                case 'objectGroups':
                case 'userGroups':
                    $typeArray = $this->{$type.'Details'};
                    break;
                default:
                    throw new \Exception('Invalid items type!');
            }
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $update = isset($params['update'])? $params['update'] : false;
            $override = $update? true : (isset($params['override'])? $params['override'] : true);
            $autoIncrement = isset($typeArray['autoIncrement']) && $typeArray['autoIncrement'];
            $autoIncrementMainKey = !$override && !$update && $autoIncrement;
            $keyColumns = $typeArray['keyColumns'];
            $extraKeyColumns = isset($typeArray['extraKeyColumns']) ? $typeArray['extraKeyColumns'] : [];
            $combinedColumns = isset($typeArray['extraKeyColumns']) ? array_merge($typeArray['keyColumns'],$typeArray['extraKeyColumns']) : $typeArray['keyColumns'];

            $identifiers = [];
            $existingIdentifiers = [];
            $indexMap = [];
            $identifierMap = [];

            $results = $autoIncrementMainKey ? -1 : [];
            $itemsToSet = [];
            $itemsToGet = [];
            $setColumns = [];
            $timeNow = (string)time();

            foreach($typeArray['setColumns'] as $colName => $colArr){
                if(
                    $autoIncrementMainKey &&
                    isset($colArr['autoIncrement']) &&
                    $colArr['autoIncrement']
                )
                    continue;
                array_push($setColumns,$colName);
            }


            $setColumns = array_merge($setColumns,$this->commonColumns);

            if(!$autoIncrementMainKey){

                foreach($inputs as $index=>$inputArr){

                    $identifier = '';
                    $identifierArr = [];

                    foreach($combinedColumns as $keyCol){
                        $identifier .= $inputArr[$keyCol].'/';
                        array_push($identifierArr,$inputArr[$keyCol]);
                    }

                    $identifier = substr($identifier,0,strlen($identifier)-1);

                    $indexMap[$identifier] = $index;
                    $identifierMap[$index] = $identifier;

                    array_push($identifiers,$identifierArr);
                    if(count($extraKeyColumns) === 0)
                        array_push($itemsToGet,$identifierArr);
                    else{
                        array_pop($identifierArr);
                        array_push($itemsToGet,$identifierArr);
                    }

                    $results[$identifier] = -1;
                }


                if(isset($params['existing']))
                    $existing = $params['existing'];
                else
                    $existing = $this->getItems($itemsToGet, $type, array_merge($params,['updateCache'=>false]));
            }
            else
                $existing = [];

            foreach($inputs as $index=>$inputArr){

                $arrayToSet = [];

                if(!$autoIncrementMainKey){
                    $identifier = '';
                    foreach($keyColumns as $keyCol){
                        $identifier .= $inputArr[$keyCol].'/';
                    }
                    $identifier = substr($identifier,0,strlen($identifier)-1);

                    if(count($extraKeyColumns) == 0){
                        $existingArr = $existing[$identifierMap[$index]];
                    }
                    else{
                        $prefix =  explode('/',$identifierMap[$index]);
                        $target = array_pop($prefix);
                        $prefix = implode('/',$prefix);
                        $existingArr =  isset($existing[$prefix][$target])? $existing[$prefix][$target] : 1;
                    }
                }
                else
                    $identifier = '';

                //In this case we are creating an auto-incrementing key, the address does not exist or we couldn't connect to db
                if($autoIncrementMainKey || !is_array($existingArr)){
                    //If we could not connect to the DB, just return because it means we wont be able to connect next
                    if(!$autoIncrementMainKey && $existingArr == -1)
                        return $results;
                    else{
                        //If we are only updating, continue
                        if($update){
                            $results[$identifierMap[$index]] = 1;
                            unset($inputs[$index]);
                            continue;
                        }

                        $missingInputs = false;

                        foreach($typeArray['setColumns'] as $colName => $colArr){
                            if(isset($colArr['autoIncrement']) && $colArr['autoIncrement'])
                                continue;
                            if(!isset($inputArr[$colName]) && !isset($colArr['default']) && $colArr['default'] !== null ){
                                if($verbose){
                                    echo 'Input '.$index.' is missing the required column '.$colName.EOL;
                                }
                                $missingInputs = true;
                                continue;
                            }
                            $val = isset($inputArr[$colName]) ? $inputArr[$colName] : $colArr['default'];

                            if(!isset($colArr['type']) || $colArr['type'] === 'string')
                                $val = [$val,'STRING'];
                            elseif($colArr['type'] === 'int')
                                $val = (int)$val;
                            elseif($colArr['type'] === 'bool')
                                $val = (bool)$val;

                            array_push($arrayToSet,$val);
                        }
                        //Add creation and update time
                        array_push($arrayToSet,[$timeNow,'STRING']);
                        array_push($arrayToSet,[$timeNow,'STRING']);

                        if($missingInputs){
                            if(!$autoIncrementMainKey){
                                $results[$identifier] = 3;
                                unset($inputs[$index]);
                                continue;
                            }
                            else{
                                $results = -3;
                                return $results;
                            }
                        }

                        //Add the resource to the array to set
                        array_push($itemsToSet,$arrayToSet);
                    }
                }
                //This is the case where the item existed
                else{
                    //If we are not allowed to override existing resources, go on
                    if(!$override && !$update){
                        $results[$identifierMap[$index]] = 2;
                        unset($inputs[$index]);
                        continue;
                    }

                    //Add the identifier to the existing identifiers - differentiates on whether we have extra key columns or not
                    if(count($extraKeyColumns) == 0)
                        array_push($existingIdentifiers,$typeArray['cacheName'].$identifier);
                    else{
                        $commonIdentifier = '';
                        foreach($typeArray['keyColumns'] as $keyCol){
                            $commonIdentifier .= $inputArr[$keyCol].'/';
                        }
                        $commonIdentifier = substr($commonIdentifier,0,strlen($commonIdentifier)-1);
                        if(!in_array($typeArray['cacheName'].$commonIdentifier,$existingIdentifiers))
                            array_push($existingIdentifiers,$typeArray['cacheName'].$commonIdentifier);
                    }


                    foreach($typeArray['setColumns'] as $colName => $colArr){

                        $existingVal = $existingArr[$colName];

                        if(isset($inputArr[$colName]) && $inputArr[$colName] !== null){
                            if(
                                isset($colArr['jsonArray']) &&
                                $colArr['jsonArray']&&
                                IOFrame\Util\is_json($inputArr[$colName]) &&
                                IOFrame\Util\is_json($existingVal)
                            ){
                                $inputJSON = json_decode($inputArr[$colName],true);
                                $existingJSON = json_decode($existingVal,true);
                                if($inputJSON == null)
                                    $inputJSON = [];
                                if($existingJSON == null)
                                    $existingJSON = [];
                                $val =
                                    json_encode(IOFrame\Util\array_merge_recursive_distinct($existingJSON,$inputJSON,['deleteOnNull'=>true]));
                                if($val == '[]')
                                    $val = null;
                                //Here we convert back to safeString
                                if(isset($colArr['safeStr']) && $colArr['safeStr'] && $val !== null)
                                    $val = IOFrame\Util\str2SafeStr($val);
                            }
                            elseif($inputArr[$colName] === '@'){
                                $val = null;
                            }
                            else{
                                $val = $inputArr[$colName];
                            }
                        }
                        else{
                            $val = $existingVal;
                        }

                        if(!isset($colArr['type']) || $colArr['type'] === 'string')
                            $val = [$val,'STRING'];
                        elseif($colArr['type'] === 'int')
                            $val = (int)$val;
                        elseif($colArr['type'] === 'bool')
                            $val = (bool)$val;

                        array_push($arrayToSet,$val);

                    }

                    //Add creation and update time
                    $created = isset($typeArray['extraKeyColumns'])?
                        $existingArr['Created'] :
                        $existingArr['Created'];

                    array_push($arrayToSet,[$created,'STRING']);
                    array_push($arrayToSet,[$timeNow,'STRING']);

                    //Add the resource to the array to set
                    array_push($itemsToSet,$arrayToSet);
                }
            }

            //If we got nothing to set, return
            if($itemsToSet==[])
                return $results;

            $res = $this->SQLHandler->insertIntoTable(
                $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                $setColumns,
                $itemsToSet,
                array_merge($params,['returnError'=>true,'onDuplicateKey'=>!$autoIncrementMainKey,'returnRows'=>$autoIncrementMainKey])
            );

            if(!$autoIncrementMainKey){
                //This means we either succeeded or got an error code returned
                if($res === true){
                    foreach($identifiers as $identifier){
                        $identifier = implode('/',$identifier);
                        if($results[$identifier] == -1)
                            $results[$identifier] = 0;
                    }
                    //If we succeeded, set results to success and remove them from cache
                    if($existingIdentifiers != []){
                        if(count($existingIdentifiers) == 1)
                            $existingIdentifiers = $existingIdentifiers[0];

                        if($verbose)
                            echo 'Deleting objects of type "'.$type.'" '.json_encode($existingIdentifiers).' from cache!'.EOL;

                        if(!$test)
                            $this->RedisHandler->call('del',[$existingIdentifiers]);
                    }
                }
                //This is the code for missing dependencies
                elseif($res === '23000'){
                    foreach($identifiers as $identifier){
                        $identifier = implode('/',$identifier);
                        if($results[$identifier] == -1)
                            $results[$identifier] = -2;
                    }
                }
                else
                    return $res;
            }
            else{
                //This means we either succeeded or got an error code returned
                if($res === '23000')
                    return -2;
                //This is the code for missing dependencies
                elseif($res === true)
                    return -1;
                else
                    return $res;
            }

            return $results;
        }

        /** Delete multiple items
         * @param array $items Array of objects (arrays). Each object needs to contain the keys from they type array's "keyColumns",
         *              each key pointing to the value of the desired item to get.
         * @param string $type Type of items. See the item objects at the top of the class for the parameters of each type.
         * @param array $params
         * @return Int codes:
         *          -1 server error (would be the same for all)
         *           0 success (does not check if items do not exist)
         *
         * @throws \Exception If the item type is invalid
         *
         */
        function deleteItems(array $items, string $type, array $params){
            switch($type){
                case 'categories':
                case 'objects':
                case 'actions':
                case 'groups':
                case 'objectUsers':
                case 'objectGroups':
                case 'userGroups':
                    $typeArray = $this->{$type.'Details'};
                    break;
                default:
                    throw new \Exception('Invalid items type!');
            }
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $keyColumns = isset($typeArray['extraKeyColumns']) ? array_merge($typeArray['keyColumns'],$typeArray['extraKeyColumns']) : $typeArray['keyColumns'];

            $existingIdentifiers = [];
            $identifiers = [];

            foreach($items as $index=>$inputArr){
                $identifier = [];
                //Add the identifier to the existing identifiers - differentiates on whether we have extra key columns or not
                if(!isset($typeArray['extraKeyColumns'])){
                    $commonIdentifier = '';
                    foreach($keyColumns as $keyCol){
                        $commonIdentifier .= $inputArr[$keyCol].'/';
                        array_push($identifier,[$inputArr[$keyCol],'STRING']);
                    }
                    $commonIdentifier = substr($commonIdentifier,0,strlen($commonIdentifier)-1);
                    array_push($existingIdentifiers,$typeArray['cacheName'].$commonIdentifier);
                }
                else{
                    $commonIdentifier = '';
                    foreach($typeArray['keyColumns'] as $keyCol){
                        $commonIdentifier .= $inputArr[$keyCol].'/';
                        array_push($identifier,[$inputArr[$keyCol],'STRING']);
                    }
                    $commonIdentifier = substr($commonIdentifier,0,strlen($commonIdentifier)-1);
                    if(!in_array($typeArray['cacheName'].$commonIdentifier,$existingIdentifiers))
                        array_push($existingIdentifiers,$typeArray['cacheName'].$commonIdentifier);
                }
                array_push($identifiers,$identifier);
            }

            if(count($identifiers) === 0)
                return 1;
            else
                array_push($identifiers,'CSV');

            $res = $this->SQLHandler->deleteFromTable(
                $typeArray['tableName'],
                [
                    $keyColumns,
                    $identifiers,
                    'IN'
                ],
                $params
            );

            if($res){
                if($verbose)
                    echo 'Deleting  cache of '.json_encode($existingIdentifiers).EOL;
                if(!$test)
                    $this->RedisHandler->call( 'del', [$existingIdentifiers] );

                //Ok we're done
                return 0;
            }
            else
                return -1;
        }

        /** Move multiple items (to a different category or object)
         * $items  Array of objects (arrays). Each object needs to contain the keys from they type array's "keyColumns",
         *         each key pointing to the value of the desired item to move.
         * $inputs Array of objects (arrays). Each object needs to contain the keys from they type array's "moveColumns" -
         *         the values are the new identifiers.
         * @param string $type Type of items. See the item objects at the top of the class for the parameters of each type.
         * @param array $params of the form:
         *
         * @returns Int, one of the following codes:
         *      -2 dependency error
         *      -1 db error
         *      0 success
         *      1 input error
         *
         * @throws \Exception If the item type is invalid
         */
        function moveItems(array $items, array $inputs, string $type, array $params){

            switch($type){
                case 'categories':
                case 'objects':
                case 'actions':
                case 'groups':
                case 'objectUsers':
                case 'objectGroups':
                case 'userGroups':
                    $typeArray = $this->{$type.'Details'};
                    break;
                default:
                    throw new \Exception('Invalid items type!');
            }
            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $keyColumns = isset($typeArray['extraKeyColumns']) ? array_merge($typeArray['keyColumns'],$typeArray['extraKeyColumns']) : $typeArray['keyColumns'];

            if(!isset($typeArray['moveColumns']) || count($typeArray['moveColumns']) < 1){
                if($verbose)
                    echo 'Move columns not set for type!'.EOL;
                return 1;
            }

            $identifiers = [];
            $existingIdentifiers = [];
            $timeNow = (string)time();
            $result = -1;
            $assignments = [];


            foreach($typeArray['moveColumns'] as $columnName=>$columnArr){
                if(isset($inputs[$columnName])){
                    array_push($assignments, $columnName.' = '.($columnArr['type'] === 'string' ? '\''.$inputs[$columnName].'\'' : $inputs[$columnName]) );
                }
            }

            if(!count($assignments))
                return $result;
            else
                array_push($assignments,'Last_Updated = \''.$timeNow.'\'');


            foreach($items as $index=>$inputArr){
                $identifier = [];
                //Add the identifier to the existing identifiers - differentiates on whether we have extra key columns or not
                if(!isset($typeArray['extraKeyColumns'])){

                    $commonIdentifier = '';

                    foreach($keyColumns as $keyCol){
                        if(!isset($inputArr[$keyCol])){
                            if($verbose)
                                echo 'Input '.$index.' missing identifier column!'.EOL;
                            return 1;
                        }
                        $commonIdentifier .= $inputArr[$keyCol].'/';
                        array_push($identifier,[$inputArr[$keyCol],'STRING']);
                    }

                    $commonIdentifier = substr($commonIdentifier,0,strlen($commonIdentifier)-1);
                    array_push($existingIdentifiers,$typeArray['cacheName'].$commonIdentifier);

                }
                else{

                    $commonIdentifier = '';

                    foreach($typeArray['keyColumns'] as $keyCol){
                        if(!isset($inputArr[$keyCol])){
                            if($verbose)
                                echo 'Input '.$index.' missing identifier column!'.EOL;
                            return 1;
                        }
                        $commonIdentifier .= $inputArr[$keyCol].'/';
                    }
                    foreach($keyColumns as $keyCol){
                        if(!isset($inputArr[$keyCol])){
                            if($verbose)
                                echo 'Input '.$index.' missing identifier column!'.EOL;
                            return 1;
                        }
                        array_push($identifier,[$inputArr[$keyCol],'STRING']);
                    }

                    $commonIdentifier = substr($commonIdentifier,0,strlen($commonIdentifier)-1);
                    if(!in_array($typeArray['cacheName'].$commonIdentifier,$existingIdentifiers))
                        array_push($existingIdentifiers,$typeArray['cacheName'].$commonIdentifier);

                }

                array_push($identifier,'CSV');
                array_push($identifiers,$identifier);
            }
            if(!count($identifiers))
                return $result;
            else
                array_push($identifiers,'CSV');

            $conditions = [
                [
                    array_merge($keyColumns,['CSV']),
                    $identifiers,
                    'IN'
                ]
            ];

            $res = $this->SQLHandler->updateTable(
                $this->SQLHandler->getSQLPrefix().$typeArray['tableName'],
                $assignments,
                $conditions,
                array_merge($params,['returnError'=>true])
            );

            if($res === true){
                if($verbose)
                    echo 'Deleting  cache of '.json_encode($existingIdentifiers).EOL;
                if(!$test)
                    $this->RedisHandler->call( 'del', [$existingIdentifiers] );

                return 0;
            }
            //This is the code for missing dependencies
            elseif($res === '23000'){
                return -2;
            }
            else
                return -1;

        }

        /** Checks whether a user has actions (or a single one) inside an object. Also searches to see if user is in any groups
         *  with the required actions.
         * @param int $category Category ID
         * @param string $object Object identifier
         * @param int $id User ID
         * @param string[] $actions Array of specific actions we are searching for.
         * @param array $params of the form:
         *              'actionSeparator' - string, default 'AND', whether the user needs to have at least one of the actions, or all of them
         *                                  for this function to return true.
         *
         * @returns Int code:
         *              -1 server error
         *               0 User has one/all of the actions in the specified category/object.
         *               1 User does not have one/all of the actions in the specified category/object.
         */
        function useHasActions(int $category, string $object, int $id, array $actions, array $params){

            $test = isset($params['test'])? $params['test'] : false;
            $verbose = isset($params['verbose'])?
                $params['verbose'] : $test ? true : false;
            $actionSeparator = isset($params['actionSeparator'])? $params['actionSeparator'] : 'AND';

            $existingActions = [];
            $existingGroups = [];

            $userParams = array_merge($params,[
                'categoryIs' => $category,
                'objectIn' => [$object],
                'userIDIs' => $id,
                'actionIn' => $actions,
                'getAllSubItems'=>true
            ]);
            $userActions = $this->getItems([],'objectUsers',$userParams);
            if(!isset($userActions['@'])){
                if($verbose)
                    echo 'Database error getting user actions!'.EOL;
                return -1;
            }

            if($userActions['@']['#'] != 0 && isset($userActions[$category.'/'.$object.'/'.$id])){
                foreach($userActions[$category.'/'.$object.'/'.$id] as $actionArray){
                    array_push($existingActions,$actionArray['Object_Auth_Action']);
                }
            }

            if($actionSeparator === 'OR'){
                $success = count(array_diff($actions,$existingActions)) < count($actions);
            }
            else{
                $success = count(array_diff($actions,$existingActions)) === 0;
            }

            if($success)
                return 0;

            $groupParams = array_merge($params,[
                'categoryIs' => $category,
                'objectIn' => [$object],
                'userIDIs' => $id,
                'actionIn' => $actions,
                'getAllSubItems'=>true
            ]);
            $userGroups = $this->getItems([],'userGroups',$groupParams);

            if(!isset($userGroups['@'])){
                if($verbose)
                    echo 'Database error getting user groups!'.EOL;
                return -1;
            }

            if($userGroups['@']['#'] != 0 && isset($userGroups[$category.'/'.$object.'/'.$id])){
                foreach($userGroups[$category.'/'.$object.'/'.$id] as $actionArray){
                    array_push($existingGroups,(int)$actionArray['Object_Auth_Group']);
                }
            }

            if(count($existingGroups) > 0){

                $groupParams = array_merge($params,[
                    'categoryIs' => $category,
                    'objectIn' => [$object],
                    'groupIn' => $existingGroups,
                    'actionIn' => $actions,
                    'getAllSubItems'=>true
                ]);
                $objectGroups = $this->getItems([],'objectGroups',$groupParams);

                if(!isset($objectGroups['@'])){
                    if($verbose)
                        echo 'Database error getting group actions!'.EOL;
                    return -1;
                }

                foreach($objectGroups as $identifier => $groupsArray){
                    if($identifier === '@')
                        continue;
                    foreach($groupsArray as $actionArray){
                        if(!in_array($actionArray['Object_Auth_Action'],$existingActions))
                            array_push($existingActions,$actionArray['Object_Auth_Action']);
                    }
                }

                if($actionSeparator === 'OR'){
                    $success = count(array_diff($actions,$existingActions)) < count($actions);
                }
                else{
                    $success = count(array_diff($actions,$existingActions)) === 0;
                }

                if($success)
                    return 0;

            }

            return 1;
        }

    }



}

?>