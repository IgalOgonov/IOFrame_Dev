const persistentSettings = {
    mixins:[],
    data:{
        persistentSettings:{
            //prefix of each localStorage setting
            prefix: '@setting_'+(this.identifier? this.identifier + '_' : ''),
            //Used to identify this specific module/component when sending events - highly recommended, at least so a module wont refresh a setting in response to its own changes
            identifier: (this.identifier? this.identifier + '_' : ''),
            //Array of relevant settings
            settings:{
            /* Objects of the following form:
             * <string of the same form as a "watch" key, referring to the module/component data the same way> : {
             *   saveAs: <string of the same form as a "watch" key, referring to the localStorage name the setting is saved under.
             *           If this contains dots, will assume the localStorage item is an object, and will create a new one.
             *           Defaults to the key.
             *   prefix: <string, additional prefix. Added AFTER the prefix above.>
             *   default: <mixed, default to set if we get null/undefined from existing setting>
             *   changeEventName: <string, event to be emitted when the setting is changed. Defaults to 'changePersistentSetting'>
             *   changeEventValue: <object, takes the context as the 1st parameter, and the target setting as 2nd parameter, defaults
             *                      to returning an object of the form:
             *                      {
             *                          _prefix: this.persistentSettings.prefix,
             *                          prefix: this.persistentSettings['settingName'].prefix,
             *                          saveAs: this.persistentSettings['settingName'].saveAs,
             *                          [optional]from: this.identifier (if one is set)
             *                      }
             *                      which is all that's needed to identify which settings should be updated in the other modules.
             *                      >
            * }
            * */
            }
        }
    },

    created:function(){
        //Defaults
        if(!persistentSettings.prefix)
            persistentSettings.prefix =  '@setting_'+(this.identifier? this.identifier : '');
        //Get settings from storage and initiate the page
        for(let target in this.persistentSettings.settings){

            if(!this.persistentSettings.settings[target].saveAs)
                this.persistentSettings.settings[target].saveAs = target;

            if(!this.persistentSettings.settings[target].prefix)
                this.persistentSettings.settings[target].prefix = '';

            if(!this.persistentSettings.settings[target].changeEventName)
                this.persistentSettings.settings[target].changeEventName = 'changePersistentSetting';

            if(!this.persistentSettings.settings[target].changeEventValue){
                this.persistentSettings.settings[target].changeEventValue = {
                    _prefix: this.persistentSettings.prefix,
                    prefix: this.persistentSettings.settings[target].prefix,
                    saveAs: this.persistentSettings.settings[target].saveAs,
                    from:this.persistentSettings.identifier
                };
            }

            let setting = target.split('.');
            let settingIdentifier = '';
            let appSetting = this;
            for(let i = 0; i < setting.length - 1; i++){
                appSetting = appSetting[setting[i]];
            }
            settingIdentifier = setting[setting.length-1];

            let localSetting = this.persistentSettings.prefix+this.persistentSettings.settings[target].prefix;
            let localSettingArr = this.persistentSettings.settings[target].saveAs.split('.');
            let localSettingName = localSetting+localSettingArr[0];
            localSetting = localStorage.getItem(localSettingName);
            if(localSettingArr.length > 1){
                localSetting = (localSetting !== null  && IsJsonString(localSetting) ) ? JSON.parse(localSetting) : {};
                for(let i = 1; i < localSettingArr.length; i++){
                    if(localSetting[localSettingArr[i]] === undefined || localSetting[localSettingArr[i]] === null)
                        localSetting[localSettingArr[i]] = {};
                    localSetting = localSetting[localSettingArr[i]];
                }
            }
            if(localSetting === null || localSetting === undefined)
                localSetting = this.persistentSettings.settings[target].default;

            //Initiate the setting
            if(this.verbose)
                console.log('Setting persistent setting '+setting+' as ')
            Vue.set(appSetting,settingIdentifier,localSetting);

            //Watch for changes
            this.$watch(setting.join('.'), function (newVal) {

                //Launch relevant event
                eventHub.$emit(
                    this.persistentSettings.settings[target].changeEventName,
                    this.persistentSettings.settings[target].changeEventValue
                );

                //Update setting in local storage
                let existingSetting = localStorage.getItem(localSettingName);
                if(localSettingArr.length > 1){
                    existingSetting = (existingSetting !== null  && IsJsonString(existingSetting) ) ? JSON.parse(existingSetting) : {};
                    let targetInSetting = existingSetting;
                    for(let i = 1; i < localSettingArr.length - 1; i++){
                        if(targetInSetting[localSettingArr[i]] === undefined || targetInSetting[localSettingArr[i]] === null)
                            targetInSetting[localSettingArr[i]] = {};
                        targetInSetting = existingSetting[localSettingArr[i]];
                    }
                    targetInSetting[localSettingArr[localSettingArr.length-1]] = newVal;
                    localStorage.setItem(localSettingName,JSON.stringify(existingSetting));
                }
                else{
                    localStorage.setItem(localSettingName,newVal)
                }

            });

        }
    },
    methods:{
        //Changes the setting on this module/component when it was changed elsewhere.
        changePersistentSetting: function(object){
            if(this.persistentSettings.identifier && (object.from === this.this.persistentSettings.identifier))
                return;
        }
    },
};
