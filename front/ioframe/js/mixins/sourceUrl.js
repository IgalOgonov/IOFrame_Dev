const sourceURL = {
    methods: {
        //Returns image root url
        sourceURL: function(siteName = 'ioframe'){
            if(siteName === 'ioframe' && this.baseSiteURL !== undefined)
                siteName = this.baseSiteURL;
            return document.rootURI + 'front/'+siteName+'/';
        }
    }
};
