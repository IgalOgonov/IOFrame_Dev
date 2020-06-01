if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('settings-editor', {
    mixins: [sourceURL,eventHubManager,IOFrameCommons],
    props: {
        //Item Identifier
        id: {
            type: String,
            default: ''
        },
        //The settings item from getSettingsMeta
        item: {
            type: Object,
            default: function(){
                return null;
            }
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
                changed:false
            },
            //The setting we are currently changing
            changing: '',
            //Whether the item is up to date
            upToDate: false,
            //Whether we are currently updating the item
            initiating: false
        }
    },
    created:function(){
        //Register eventhub
        this.registerHub(eventHub);
        //Register events
        this.registerEvent('getResponse' ,this.handleItemGet);
        this.registerEvent('setResponse' ,this.handleItemSet);

        //Global config
        if(this.configObject === undefined)
            this.configObject = {};

        this.getItemInfo();

    },
    mounted:function(){
    },
    updated: function(){
        if(!this.upToDate && !this.initiating)
            this.getItemInfo();
    },
    computed:{
        changed: function(){

            if(this.recompute.changed)
                ;//Just to recompute

            if(this.mainItem)
                for(let index in this.mainItem){
                    let settingItem = this.mainItem[index];
                    if(settingItem.original !== settingItem.current)
                        return true;
                }

            return false;
        }
    },
    methods:{
        //Gets the info of the main item
        getItemInfo: function(){

            if(this.initiating){
                if(this.verbose)
                    console.log('Already getting main item info!!');
                return;
            }

            /* ---- TODO Add validity checks if relevant ---- */

            this.initiating = true;

            if(this.verbose)
                console.log('Getting item information!');

            //Data to be sent
            var data = new FormData();
            data.append('action', 'getSettings');
            data.append('target', this.id);

            this.apiRequest(
                data,
                'api/settings',
                'getResponse',
                {
                    'verbose': this.verbose,
                    'parseJSON':true,
                    'identifier':this.identifier
                }
            );
        },
        //Tries to update the item
        setItem: function(key){

            if(this.changing){
                if(this.verbose)
                    alertLog('Still updating setting '+this.changing,'error',this.$el);
                return;
            }

            //Data to be sent
            var data = new FormData();
            data.append('action', 'setSetting');
            data.append('target', this.item.identifier);
            if(this.test)
                data.append('req','test');

            //What we're changing
            this.changing = key;

            //Params
            let params = {
                settingName: key,
                settingValue: this.mainItem[key].current
            };

            data.append('params', JSON.stringify(params));

            if(this.verbose)
                console.log('Setting '+key+'to '+this.mainItem[key].current);

            this.apiRequest(
                data,
                'api/settings',
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
                alertLog('Not authorized to update setting! Check to see if you are logged in.','error',this.$el);
                return;
            }

            switch (response) {
                case 1:
                    alertLog('Setting '+this.changing+' updated!','success',this.$el);
                    this.setInputsAsCurrent(this.changing);
                    break;
                case 0:
                    alertLog('Could not update setting!','error',this.$el);
                    break;
                default:
                    alertLog('Unknown response: '+response,'error',this.$el);
                    break;
            }

            //Either way we are done
            this.changing = '';

        },
        //Handles the response to the get request
        handleItemGet: function(response){

            if(this.verbose)
                console.log('Recieved handleItemGet',response);

            if(this.identifier && response.from !== this.identifier)
                return;

            if(response.from)
                response = response.content;

            if(typeof response === 'object'){
                this.mainItem = {};

                for(let setting in response){
                    this.mainItem[setting] = {
                        'setting':setting,
                        'original':response[setting],
                        'current':response[setting],
                        type: typeof response[setting]
                    };
                }
            }

            this.initiating = false;
            this.upToDate = true;
        },
        //Resets inputs
        resetInputs: function(){
            for(let index in this.mainItem){
                this.mainItem[index].current = this.mainItem[index].original;
            }
            this.recompute.changed = !this.recompute.changed;
        },
        //Saves inputs as the actual data (in case of a successful update or whatnot)
        setInputsAsCurrent: function(key = ''){
            if(key === '')
                for(let index in this.mainItem){
                    this.mainItem[index].original = this.mainItem[index].current;
                }
            else
                this.mainItem[key].original = this.mainItem[key].current;

            this.recompute.changed = !this.recompute.changed;
        }
    },
    watch: {
    },
    template: `
    <div class="settings-editor">
        <div class="wrapper">

            <h4 v-if="item.local" class="message message-warning-2">
                This is a <u>local</u> settings file.<br>
                Generally, local setting files should <u>NOT be edited</u> through this API.<br>
                Editing here will also <u>NOT affect any of the other nodes</u> in the system, potentially leading to <u>system inconsistencies</u>.<br>
                Do not touch this file unless you know what you're doing.
            </h4>

            <h1 v-text="item.title"></h1>

            <form>
                <div v-for="(item, key) in mainItem" :class="{changed:item.current !== item.original}">
                    <span class="title" v-text="key"></span>
                    <input v-if="item.type === 'string'" type="text" v-model:value="item.current" @change="recompute.changed = !recompute.changed">
                    <input v-else-if="item.type === 'number'" type="number" v-model:value="item.current" @change="recompute.changed = !recompute.changed">
                    <input v-else-if="item.type === 'boolean'" type="checkbox" v-model:value="item.current" @change="recompute.changed = !recompute.changed">
                    <button v-if="item.current !== item.original" v-text="'Update'" @click.prevent="setItem(key)" class="positive-1"></button>
                </div>
            </form>

            <div class="control-buttons" v-if="changed">
                <button v-text="'Reset'" @click.prevent="resetInputs()" class="cancel-1"></button>
            </div>

        </div>
    </div>
    `
});