const multipleLanguages = {
    mixins:[eventHubManager],
    data:{
        currentLanguage:document.selectedLanguage
    },
    created:function(){
        this.registerHub(eventHub);
        if((this.languageChanged !== undefined) && (typeof this.languageChanged === 'function') )
            this.registerEvent('newLanguage',this.languageChanged);
    },
    methods:{
        //Preloads main menu
        languageChanged: function(newLanguage){
            if(newLanguage !== this.currentLanguage)
                this.currentLanguage = newLanguage;
        },
    },
};
