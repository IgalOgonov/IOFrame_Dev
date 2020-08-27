<?php

namespace IOFrame\Util{
    define('frontEndResourceTemplateManager',true);
    /**A tool to output FrontEndResourceHandler items into pages as actual  resource (JS, CSS) links
     * @author Igal Ogonov <igal1333@hotmail.com>
     * @license LGPL
     * @license https://opensource.org/licenses/LGPL-3.0 GNU Lesser General Public License version 3
     */
    class frontEndResourceTemplateManager
    {
        /**
         * @var Array The result of $FrontEndResourceHandler->getJS()
         */
        public $JSResources = [];

        /**
         * @var Array The result of $FrontEndResourceHandler->getCSS()
         */
        public $CSSResources = [];

        /**
         * @var Array Order in which the JS resources should be displayed'
         */
        public $JSOrder = [];

        /**
         * @var Array Order in which the CSS resources should be displayed'
         */
        public $CSSOrder = [];

        /**
         * @var String The root of JS resources relative to server address - defaults to 'front/ioframme/js/'
         */
        public $JSResourceRoot = [];

        /**
         * @var String The root of CSS resources relative to server address - defaults to 'front/ioframme/css/'
         */
        public $CSSResourceRoot = [];

        /**
         * @var string, default '' - relative URI from this page to server root (relevant with local resources)
         */
        public $dirToRoot = '';


        /** @param Array $params optionally initiate $JSResources and $CSSResources with parameters SResources and CSSResources
         */
        function __construct(array $params = []){
            $validParams = ['JSResources','CSSResources','dirToRoot','JSResourceRoot','CSSResourceRoot','JSOrder','CSSOrder'];
            foreach($validParams as $param){
                if(isset($params[$param]))
                    $this->{$param} = $params[$param];
            }
        }

        /** Adds resources to the resource array
         *  @param string $type Name of the array (JSResources,CSSResources, etc)
         *  @param Array $resources Resources to add
         */
        function addResourcesToArray(string $type, array $resources){
            $this->{$type} = array_merge($this->{$type},$resources);
        }

        /** Outputs resources of a specific type.
         *  @param string $type Resource type (JS and CSS for now)
         *  @param string[] $resources, default [] - if set, will output resources from this array, in the order of this array.
         *  @param array $params of the form:
         *              'appendLastChanged' - bool, default true - whether to append 'lastChanged' to the end of the
         *                                    resource address as "?changed=$lastChangedValue"
         *              'appendVersion' - bool, default false - whether to append 'version' to the end of the
         *                                    resource address as "?v=$version" (generally not used as lastChanged is modified automatically)
         */
        function printResources(string $type, array $resources = [], array $params = []){
            $appendLastChanged = isset($params['appendLastChanged'])? $params['appendLastChanged'] : true;
            $appendVersion = isset($params['appendVersion'])? $params['appendVersion'] : false;

            switch($type){
                case 'JS':
                case 'CSS':
                    $resourceArray = $this->{$type.'Resources'};
                    $resourceRoot = $this->{$type.'ResourceRoot'};
                    $resourceOrder = $this->{$type.'Order'};
                    break;
                default:
                    return;
            }
            if(!count($resources)){
                if(!count($resourceOrder)){
                    foreach($resourceArray as $identifier => $arr){
                        if(is_array($arr))
                            array_push($resources,$identifier);
                    }
                }
                elseif(count($resourceOrder)){
                    foreach($resourceOrder as $identifier){
                        array_push($resources,$identifier);
                    }
                }
            }

            foreach($resources as $resourceIdentifier){
                if(!empty($resourceArray[$resourceIdentifier]) && is_array($resourceArray[$resourceIdentifier])){
                    $resource = $resourceArray[$resourceIdentifier];
                    $resourceAddress = $resource['local']? $this->dirToRoot.$resourceRoot .$resource['relativeAddress'] : $resource['address'];
                    if($appendLastChanged || $appendVersion){
                        $resourceAddress .= '?';
                    }
                    if($appendLastChanged && !empty($resource['lastChanged'])){
                        $resourceAddress .= 'changed='.$resource['lastChanged'].'&';
                    }
                    if($appendVersion && !empty($resource['version'])){
                        $resourceAddress .= 'v='.$resource['version'].'&';
                    }
                    if($appendLastChanged || $appendVersion){
                        $resourceAddress = substr($resourceAddress,0,strlen($resourceAddress)-1);
                    }
                    if($type === 'JS')
                        echo '<script src="'.$resourceAddress.'"></script>';
                    else
                        echo '<link rel="stylesheet" href="' . $resourceAddress . '">';
                }
            }
        }


    }

}

?>