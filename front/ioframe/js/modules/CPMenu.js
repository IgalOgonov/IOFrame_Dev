var CPMenu = new Vue({
    el: '#menu',
    data: {
        configObject: document.siteConfig,
        selected: '',
        logo:{
            imgURL: '',
            url:''
        },
        menu:[
            /*
                {
                'id':   id of the page,
                'title': name of the page,
                url:    url of the page
                }
             */
        ]
    },
    created:function(){

        /*Global config check - can be hardcoded or dynamically aquired from the DB*/
        if(this.configObject === undefined)
            this.configObject = {};

        /* Defaults*/
        //Currently selected page -
        if(this.configObject.page === undefined)
            this.configObject.page = {};
        if(this.configObject.page.id === undefined)
            this.configObject.page.id = '';

        this.selected = this.configObject.page.id;

        //logo
        this.logo = {
            imgURL: document.rootURI + 'front/ioframe/img/icons/logo.png',
            url: document.rootURI
        };

        //--Menu
        this.menu = [
            {
                id: 'users',
                title: 'Users',
                url: 'users'
            },
            {
                id: 'settings',
                title: 'Settings',
                url: 'settings'
            },
            {
                id: 'plugins',
                title: 'Plugins',
                url: 'plugins'
            },
            {
                id: 'contacts',
                title: 'Contacts',
                url: 'contacts'
            },
            {
                id: 'media',
                title: 'Media',
                url: 'media'
            },
            {
                id: 'galleries',
                title: 'Galleries',
                url: 'galleries'
            },
            {
                id: 'mails',
                title: 'Mails',
                url: 'mails'
            },
            {
                id: 'resources',
                title: 'Resources',
                url: 'resources'
            },
            {
                id: 'objects',
                title: 'Objects',
                url: 'objects'
            },
            {
                id: 'permissions',
                title: 'Permissions',
                url: 'permissions'
            },
            {
                id: 'security',
                title: 'Security',
                url: 'security'
            },
            {
                id: 'tokens',
                title: 'Tokens',
                url: 'tokens'
            },
            {
                id: 'routing',
                title: 'Routing',
                url: 'routing'
            },
            {
                id: 'login',
                title: 'Login Page',
                url: 'login'
            },
        ]

    }
});