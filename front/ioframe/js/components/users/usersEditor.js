if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('users-editor', {
    mixins: [sourceURL,eventHubManager,IOFrameCommons],
    props: {
        //Item
        item: {
            type: Object
        },
        //App Identifier
        identifier: {
            type: String,
            default: ''
        },
        //Test Mode
        test: {
            type: Boolean,
            default: false
        },
        //Verbose Mode
        verbose: {
            type: Boolean,
            default: false
        },
    },
    data: function(){
        return {
            configObject: JSON.parse(JSON.stringify(document.siteConfig)),
            //Main item focused on in this component
            mainItem:{
            },
            //Sometimes, you need to manially recompute Vue computed properties
            recompute:{
                changed:false,
                paramMap: false
            },
            //Map of parameters, and vaios properties of each.
            paramMap:{
                /*
                'paramName':{
                     //bool, whether to ignore this param completely on get, defaults to false
                     ignore: false,
                     //string, title to display, defaults to parameter name
                     title: 'paramName',
                     //bool, whether it can be edited, default true
                     edit: true,
                     //string, type (if editable). Valid types are "text"(default), "textArea", "boolean", "date", "number" and "email"
                     type: "text",
                     //bool, whether the item should be displayed (if it's not editable), default true
                     display: true,
                     //What to do on item update
                     onUpdate: {
                        //bool, default false - do no send this key on update
                         ignore: false,
                         //function, if this item is sent, parse the value with this function before sending
                         parse: function(value){
                            return value;
                         },
                         //Validates value and either suceeds or returns false
                         validate: function(value){
                            return true;
                         },
                         //The name to send. Defaults to <paramName>
                         setName: 'paramName'
                         //Custom message on validation failure (if null, default message is "<paramName> failed validation")
                        validateFailureMessage: 'Parameter '+paramName+' failed validation!',
                     },
                     //function, parsing function on item get
                     parseOnGet: function(value){
                         return value;
                     },
                     //function, parsing function on item only when displaying
                     parseOnDisplay: function(value){
                     return value;
                     },
                     //function, parsing function on item change (if it can be edited)
                     parseOnChange: function(value){
                         return value;
                     },
                     //bool, displays item (after parsing) as HTML. Only if the item is displayed and not editable. Defaults to false
                     displayHTML: false
                    }
                * */
                'id':{
                    title: 'User ID',
                    edit: false,
                    display: true
                },
                'created':{
                    title: 'Date Created',
                    edit: false,
                    display: true,
                    parseOnDisplay: function(timestamp){
                        timestamp *= 1000;
                        return timestampToDate(timestamp).split('-').reverse().join('-');
                    },
                    onUpdate:{
                        ignore:true
                    }
                },
                'rank':{
                    title: 'User Auth Rank',
                    edit: false,
                    display: true,
                    onUpdate:{
                        ignore:true
                    }
                },
                'username':{
                    title: 'Username',
                    edit: true,
                    type: 'text',
                    onUpdate:{
                        validate: function(value){
                            return value.match(/^[a-zA-Z][a-zA-Z0-9]{5,15}/)
                        },
                        validateFailureMessage: 'Username must be between 6 and 16 characters long, numbers and letters. Cannot start with a number!',
                    }
                },
                'email':{
                    title: 'Email',
                    edit: true,
                    type: 'email',
                    onUpdate:{
                        validate: function(value){
                            return value.match(/^[a-z0-9!#$%&'*+\/=?^_`{|}~.-]+@[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$/)
                        },
                        validateFailureMessage: 'A valid email must be provided!'
                    }
                },
                'active':{
                    title: 'User Active?',
                    edit: true,
                    type: 'boolean',
                    onUpdate:{
                    }
                },
                'bannedUntil':{
                    title: 'Banned Until',
                    edit: true,
                    type: 'date',
                    parseOnGet: function(timestamp){
                        timestamp *= 1000;
                        return timestamp? timestampToDate(timestamp) : '';
                    },
                    onUpdate:{
                        setName:'bannedDate',
                        parse: function(timestamp){
                            return timestamp !== ''? dateToTimestamp(timestamp) / 1000 : 0;
                        },
                        validate: function(value){
                            return value === 0 || (value * 1000 > Date.now());
                        },
                        validateFailureMessage: 'Provided ban date must be larger than now, or not provided at all!'
                    }
                },
                'suspiciousUntil':{
                    title: 'Suspicious Until',
                    edit: true,
                    type: 'date',
                    parseOnGet: function(timestamp){
                        timestamp *= 1000;
                        return timestamp? timestampToDate(timestamp) : '';
                    },
                    onUpdate:{
                        setName:'suspiciousDate',
                        parse: function(timestamp){
                            return timestamp !== ''? dateToTimestamp(timestamp) / 1000 : 0;
                        },
                        validate: function(value){
                            return value === 0 || value * 1000 > Date.now();
                        },
                        validateFailureMessage: 'Provided suspicious date must be larger than now, or not provided at all!'
                    }
                },
                'identifier':{
                    ignore: true
                }
            },
            //Whether we are currently updating the item
            updating: false
        }
    },
    created:function(){
        //Register eventhub
        this.registerHub(eventHub);
        //Register events
        this.registerEvent('setResponse' ,this.handleItemSet);

        this.setMainItem(this.item);
    },
    mounted:function(){
    },
    updated: function(){
    },
    computed:{
        changed: function(){
            if(this.recompute.changed)
                ;//Do nothing
            for(let i in this.mainItem){
                if(this.mainItem[i].original !== undefined && this.mainItem[i].original != this.mainItem[i].current)
                    return true;
            }
            return false;
        },
        itemHasInfo: function(){
            if(this.paramMap)
                ;//Do nothing

            for(let i in this.paramMap){
                if(!this.paramMap[i].edit && this.paramMap[i].display)
                    return true;
            }
            return false;
        },
    },
    methods:{
        //What to do if an item was changed
        itemChanged: function(key){
            console.log(key);
        },
        //Sets main item
        setMainItem(item){
            for(let i in item){
                if(!this.paramMap[i])
                    this.paramMap[i] ={};
                this.paramMap[i].ignore = this.paramMap[i].ignore !== undefined ? this.paramMap[i].ignore : false;
                this.paramMap[i].title = this.paramMap[i].title !== undefined ? this.paramMap[i].title : i;
                this.paramMap[i].edit = this.paramMap[i].edit !== undefined ? this.paramMap[i].edit: true;
                this.paramMap[i].type = this.paramMap[i].type !== undefined ? this.paramMap[i].type : "text";
                this.paramMap[i].display = this.paramMap[i].display !== undefined ?  this.paramMap[i].display: true;

                if(!this.paramMap[i].onUpdate)
                    this.paramMap[i].onUpdate = {};
                this.paramMap[i].onUpdate.ignore = this.paramMap[i].onUpdate.ignore !== undefined ? this.paramMap[i].onUpdate.ignore : false;
                this.paramMap[i].onUpdate.parse = this.paramMap[i].onUpdate.parse !== undefined ? this.paramMap[i].onUpdate.parse : function(value){
                    return value;
                };
                this.paramMap[i].onUpdate.validate = this.paramMap[i].onUpdate.validate !== undefined ? this.paramMap[i].onUpdate.validate : function(value){
                    return true;
                };
                this.paramMap[i].onUpdate.validateFailureMessage = this.paramMap[i].onUpdate.validateFailureMessage !== undefined ? this.paramMap[i].onUpdate.validateFailureMessage : 'Parameter '+i+' failed validation!';
                this.paramMap[i].onUpdate.setName = this.paramMap[i].onUpdate.setName !== undefined ? this.paramMap[i].onUpdate.setName : i;

                this.paramMap[i].parseOnGet = this.paramMap[i].parseOnGet !== undefined ? this.paramMap[i].parseOnGet : function(value){
                    return value;
                };
                this.paramMap[i].parseOnDisplay = this.paramMap[i].parseOnDisplay !== undefined ? this.paramMap[i].parseOnDisplay : function(value){
                    return value;
                };
                this.paramMap[i].parseOnChange = this.paramMap[i].parseOnChange !== undefined ? this.paramMap[i].parseOnChange : function(value){
                    return value;
                };
                this.paramMap[i].displayHTML = this.paramMap[i].displayHTML !== undefined ? this.paramMap[i].displayHTML : false;


                if(!this.paramMap[i].ignore)
                    this.mainItem[i] =
                        this.paramMap[i].edit ?
                        {
                            original:this.paramMap[i].parseOnGet(item[i]),
                            current:this.paramMap[i].parseOnGet(item[i])
                        }
                        :
                        this.paramMap[i].parseOnGet(item[i]);
            }
        },
        //Tries to update the item
        setItem: function(){

            if(this.updating){
                if(this.verbose)
                    console.log('Still updating item info!');
                return;
            }

            //Data to be sent
            var data = new FormData();
            data.append('action', 'updateUser');
            if(this.test)
                data.append('req','test');

            let sendParams = {};

            for(let paramName in this.paramMap){

                let param = this.paramMap[paramName];
                let item = this.mainItem[paramName];

                if(param.ignore || param.onUpdate.ignore || (item.current !== undefined && item.current === item.original))
                    continue;
                else if(item.current === undefined){
                    data.append(param.onUpdate.setName, item);
                    sendParams[param.onUpdate.setName] = item;
                    continue;
                }

                let paramValue = param.onUpdate.parse(item.current);

                if(!param.onUpdate.validate(paramValue)){
                    alertLog(param.onUpdate.validateFailureMessage,'warning',this.$el);
                    return;
                }

                data.append(param.onUpdate.setName, paramValue);
                sendParams[param.onUpdate.setName] = paramValue;
            }

            if(this.verbose)
                console.log('Setting item with parameters ',sendParams);

            this.apiRequest(
                data,
                'api/users',
                'setResponse',
                {
                    'verbose': this.verbose,
                    'parseJSON':true,
                    'identifier':this.identifier
                }
            );
        },
        //Handles item  update
        handleItemSet: function(response){

            if(this.verbose)
                console.log('Received handleItemSet',response);

            if(this.identifier && (response.from !== this.identifier))
                return;

            if(response.from)
                response = response.content;

            if (response === 'AUTHENTICATION_FAILURE') {
                alertLog('Not authorized to update user! Check to see if you are logged in.','error',this.$el);
                return;
            }

             switch (response) {
                case -1:
                    alertLog('Server error!','error',this.$el);
                    break;
                 case 0:
                     alertLog('User updated!','success',this.$el);
                     this.setInputsAsCurrent();
                     break;
                 case 1:
                     alertLog('Bad identifier type - unexpected error!','error',this.$el);
                     break;
                 case 2:
                     alertLog('Bad identifier - unexpected error!','error',this.$el);
                     break;
                 case 3:
                     alertLog('User cannot be updated without new assignments!','warning',this.$el);
                     break;
                default:
                    break;
            }
        },
        //Resets inputs
        resetInputs: function(){
            for(let key in this.mainItem){
                if(this.mainItem[key]['original'] !== undefined){
                    this.mainItem[key]['current'] = this.mainItem[key]['original'];
                }
            }
            this.recompute.changed = ! this.recompute.changed;
            this.$forceUpdate();
        },
        //Saves inputs as the actual data (in case of a successful update or whatnot)
        setInputsAsCurrent: function(){
            for(let key in this.mainItem){
                if(this.mainItem[key]['original'] !== undefined){
                    this.mainItem[key]['original'] = this.mainItem[key]['current'];
                }
            }
            this.recompute.changed = ! this.recompute.changed;
            this.$forceUpdate();
        }
    },
    watch: {
    },
    template: `
    <div class="users-editor">
        <div class="wrapper">

            <div class="info message-info-2" v-if="this.itemHasInfo">
                <div
                 v-for="(item, key) in mainItem"
                 v-if="!paramMap[key].edit && paramMap[key].display ">

                    <span class="title" v-text="paramMap[key].title? paramMap[key].title : key"></span>

                    <span class="value" v-if="!paramMap[key].displayHTML" v-text="paramMap[key].parseOnDisplay(item)"></span>
                    <span class="value" v-else="" v-html="paramMap[key].parseOnDisplay(item)"></span>

                </div>
            </div>

            <form>
                <div
                v-for="(item, key) in mainItem"
                v-if="paramMap[key].edit"
                :class="{changed:item.current !== item.original}"
                >

                    <span class="title" v-text="paramMap[key].title? paramMap[key].title : key"></span>

                    <input
                     v-if="!paramMap[key].type || ['text','date','number','email'].indexOf(paramMap[key].type) !== -1"
                     class="item-param"
                     :type="paramMap[key].type"
                     v-model:value="item.current"
                     @change="item.current = paramMap[key].parseOnChange($event.target.value);recompute.changed = ! recompute.changed"
                    >
                    <button
                    v-else-if="paramMap[key].type === 'boolean'"
                    class="item-param"
                    :class="{'positive-1':item.current,'cancel-1':!item.current}"
                    v-text="item.current?'Yes':'No'"
                     @click.prevent="item.current = paramMap[key].parseOnChange(!item.current);recompute.changed = ! recompute.changed"
                     ></button>

                    <textarea
                    v-else-if="paramMap[key].type === 'textArea'"
                    class="item-param"
                     v-model:value="item.current"
                     @change="itemChanged(key)"
                     ></textarea>

                </div>
            </form>

            <div class="control-buttons" v-if="changed">
                <button  v-text="'Update'" @click.prevent="setItem()" class="positive-1"></button>
                <button v-text="'Reset'" @click.prevent="resetInputs()" class="cancel-1"></button>
            </div>

        </div>
    </div>
    `
});