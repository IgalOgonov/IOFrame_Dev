var CPMenu = new Vue({
    el: '#menu',
    name:'Side Menu',
    data: {
        configObject: document.siteConfig,
        selected: '',
        logo:{
            imgURL: '',
            url:''
        },
        otherCP:{
            imgURL: '',
            url:'',
            title:''
        },
        menu:[
            /*
                {
                'id':   id of the page,
                'title': name of the page,
                url:    url of the page
                position: default -2 (append). Other possible values are -1 (prepend), or the index in the original array
                          to which you want to PREPEND the item (so 0 first inserts the item, then the original first menu item).
                          Multiple items with the same position will be inserted into their right place in the order they appear here.
                          Values lower than -3 will DECREASE priority of appending (so something with -3 will be inserted later than -2)
                }
             */
        ],
        open:false
    },
    created:function(){

        /*Global config check - can be hardcoded or dynamically aquired from the DB*/
        if(this.configObject === undefined)
            this.configObject = {};
        if(this.configObject.cp === undefined)
            this.configObject.cp = {};

        /* Defaults*/
        //Link to other CP menu
        if(this.configObject.cp.otherCP === undefined)
            this.configObject.cp.otherCP = {};
        if(this.configObject.cp.otherCP.imgURL === undefined)
            this.configObject.cp.otherCP.imgURL = '';
        if(this.configObject.cp.otherCP.url === undefined)
            this.configObject.cp.otherCP.url = '';
        if(this.configObject.cp.otherCP.title === undefined)
            this.configObject.cp.otherCP.title = '';
        this.otherCP = JSON.parse(JSON.stringify(this.configObject.cp.otherCP));

        //Currently selected page -
        if(this.configObject.page === undefined)
            this.configObject.page = {};
        if(this.configObject.page.id === undefined)
            this.configObject.page.id = '';

        this.selected = this.configObject.page.id;

        //Logo
        if(this.configObject.cp.logo === undefined)
            this.configObject.cp.logo = {};
        if(this.configObject.cp.logo.imgURL === undefined)
            this.configObject.cp.logo.imgURL = document.rootURI + 'front/ioframe/img/icons/logo.png';
        if(this.configObject.cp.logo.url === undefined)
            this.configObject.cp.logo.url = document.rootURI;
        this.logo = this.configObject.cp.logo;

        //Menu
        let defaultMenu = [
            {
                id: 'users',
                title: 'Users',
                url: 'users',
                position: 1,
            },
            {
                id: 'settings',
                title: 'Settings',
                url: 'settings',
                position: 2,
            },
            {
                id: 'plugins',
                title: 'Plugins',
                url: 'plugins',
                position: 3,
            },
            {
                id: 'contacts',
                title: 'Contacts',
                url: 'contacts',
                position: 4,
            },
            {
                id: 'media',
                title: 'Media',
                url: 'media',
                position: 5,
            },
            {
                id: 'galleries',
                title: 'Galleries',
                url: 'galleries',
                position: 6,
            },
            {
                id: 'mails',
                title: 'Mails',
                url: 'mails',
                position: 7,
            },
            {
                id: 'objects',
                title: 'Objects',
                url: 'objects',
                position: 8,
            },
            {
                id: 'auth',
                title: 'Permissions',
                url: 'auth',
                position: 9,
            },
            {
                id: 'securityEvents',
                title: '(Security) Events',
                url: 'securityEvents',
                position: 10,
            },
            {
                id: 'securityIP',
                title: '(Security) IP',
                url: 'securityIP',
                position: 11,
            },
            {
                id: 'tokens',
                title: 'Tokens',
                url: 'tokens',
                position: 12,
            },
            {
                id: 'login',
                title: 'Login Page',
                url: 'login',
                position: -3,
            }
        ];
        /* Extra menu items - needs to be an array similar to Menu, will be appended to the end.
         */
        if(this.configObject.cp.extraMenu === undefined)
            this.configObject.cp.extraMenu = [];

        let newMenu = [...defaultMenu, ...this.configObject.cp.extraMenu];

        newMenu.sort(function(a, b) {
            if(b.position == a.position)
                return 0;
            else if(a.position < -1 && b.position < -1)
                return (a.position > b.position ? -1 : 1);
            else if(a.position < -1)
                return 1;
            else if(b.position < -1)
                return -1;
            else
                return a.position < b.position ? -1 : 1;
        });

        this.menu = newMenu;
    }
});