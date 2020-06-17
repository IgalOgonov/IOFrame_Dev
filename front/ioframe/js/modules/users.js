if(eventHub === undefined)
    var eventHub = new Vue();

var users = new Vue({
    el: '#users',
    name: 'users',
    mixins:[sourceURL,eventHubManager,IOFrameCommons],
    data(){
        return {
            configObject: JSON.parse(JSON.stringify(document.siteConfig)),
            //Modes, and array of available operations in each mode
            modes: {
                search:{
                    operations:{
                        'cancel':{
                            title:'Cancel',
                            button:'cancel-1'
                        }
                    },
                    title:'View users'
                },
                edit:{
                    operations:{},
                    title:'Edit user'
                }
            },
            //Filters to display for the search list
            filters:[
                {
                    type:'Group',
                    group: [
                        {
                            name:'usernameLike',
                            title:'Username',
                            placeholder:'Text username includes',
                            type:'String',
                            min:0,
                            max: 64,
                            validator: function(value){
                                return value.match(/^[\w\.\-\_ ]{1,64}$/) !== null;
                            }
                        },
                        {
                            name:'emailLike',
                            title:'Email',
                            placeholder:'Text email excludes',
                            type:'String',
                            min:0,
                            max: 64,
                            validator: function(value){
                                return value.match(/^[\w\.\-\_ ]{1,64}$/) !== null;
                            }
                        }
                    ]
                },
                {
                    type:'Group',
                    group: [
                        {
                            name:'createdAfter',
                            title:'Created After',
                            type:'Datetime',
                            parser: function(value){ return value ? Math.round(value/1000) : null; }
                        },
                        {
                            name:'createdBefore',
                            title:'Created Before',
                            type:'Datetime',
                            parser: function(value){ return value ? Math.round(value/1000) : null; }
                        }
                    ]
                },
                {
                    type:'Group',
                    group: [
                        {
                            name:'orderBy',
                            title:'Order By Column',
                            type:'Select',
                            list:[
                                {
                                    value:'ID',
                                    title:'User ID'
                                },
                                {
                                    value:'Created_On',
                                    title:'Creation Date'
                                },
                                {
                                    value:'Email',
                                    title:'Email'
                                },
                                {
                                    value:'Username',
                                    title:'Username'
                                }
                            ],
                        },
                        {
                            name:'orderType',
                            title:'Order',
                            type:'Select',
                            list:[
                                {
                                    value:'0',
                                    title:'Ascending'
                                },
                                {
                                    value:'1',
                                    title:'Descending'
                                }
                            ],
                        }
                    ]
                },
            ],
            //Result columns to display, and how to parse them
            columns:[
                {
                    id:'identifier',
                    title:'ID'
                },
                {
                    id:'email',
                    title:'Email'
                },
                {
                    id:'username',
                    title:'Username'
                },
                {
                    id:'rank',
                    title:'Rank'
                },
                {
                    id:'active',
                    title:'Active?',
                    parser:function(active){
                        return active? 'Yes' : 'No';
                    }
                },
                {
                    id:'bannedUntil',
                    title:'Banned?',
                    parser:function(timestamp){
                        timestamp *= 1000;
                        return Date.now() >= timestamp? 'No' : 'Yes';
                    }
                },
                {
                    id:'suspiciousUntil',
                    title:'Suspicious?',
                    parser:function(timestamp){
                        timestamp *= 1000;
                        return Date.now() >= timestamp? 'No' : 'Yes';
                    }
                },
                {
                    id:'created',
                    title:'Date Created',
                    parser:function(timestamp){
                        timestamp *= 1000;
                        let date = timestampToDate(timestamp).split('-').reverse().join('-');
                        let hours = Math.floor(timestamp%(1000 * 60 * 60 * 24)/(1000 * 60 * 60));
                        let minutes = Math.floor(timestamp%(1000 * 60 * 60)/(1000 * 60));
                        let seconds = Math.floor(timestamp%(1000 * 60)/(1000));
                        if(hours < 10)
                            hours = '0'+hours;
                        if(minutes < 10)
                            minutes = '0'+minutes;
                        if(seconds < 10)
                            seconds = '0'+seconds;
                        return date + ', ' + hours+ ':'+ minutes+ ':'+seconds;
                    }
                }
            ],
            //SearchList API
            url: document.pathToRoot+ 'api/users',
            //Current page
            page:0,
            //Go to page
            pageToGoTo: 1,
            //Limit
            limit:50,
            //Total available results
            total: 0,
            //Main items
            items: [],
            extraParams: {},
            selected:-1,
            //Current Mode of operation
            currentMode:'search',
            //Current operation
            currentOperation: '',
            //Current operation input
            operationInput: '',
            //Whether we are currently loading
            initiated: false,
            verbose:false,
            test:false
        }
    },
    created:function(){
        this.registerHub(eventHub);
        this.registerEvent('requestSelection', this.selectElement);
        this.registerEvent('searchResults', this.parseSearchResults);
        this.registerEvent('goToPage', this.goToPage);
    },
    computed:{
        //Main title TODO
        title:function(){
            switch(this.currentMode){
                case 'search':
                    return 'Browsing Users';
                    break;
                case 'edit':
                    return 'Editing User';
                    break;
                default:
            }
        },
        //Text for current operation TODO
        currentOperationPlaceholder:function(){
            if(this.currentOperationHasInput){
                switch(this.currentOperation){
                    case 'temp':
                        return 'temp';
                    default:
                        return '';
                }
            }
            return '';
        },
        //Text for current operation TODO
        currentOperationText:function(){
            switch(this.currentOperation){
                default:
                    return '';
            }
        },
        //Whether current operation has input TODO
        currentOperationHasInput:function(){
            switch(this.currentOperation){
                default:
                    return false;
            }
        },
        //Whether the current mode has operations
        currentModeHasOperations:function(){
            return Object.keys(this.modes[this.currentMode].operations).length>0;
        },
    },
    watch:{
    },
    methods:{
        //Searches again (meant to be invoked after relevant changes) TODO Remove if no searchlist
        searchAgain: function(){
            this.items = [];
            this.total = 0;
            this.page = 0;
            this.selected = -1;
            this.initiated = false;
        },
        //Parses search results returned from a search list TODO Remove if no searchlist
        parseSearchResults: function(response){
            if(this.verbose)
                console.log('Received response',response);

            if(!response.from || response.from !== 'search')
                return;

            //Either way, the items should be considered initiated
            this.items = [];
            this.initiated = true;

            //In this case the response was an error code, or the page no longer exists
            if(response.content['@'] === undefined)
                return;

            this.total = (response.content['@']['#'] - 0) ;
            delete response.content['@'];

            for(let k in response.content){
                response.content[k].identifier = k;
                this.items.push(response.content[k]);
            }
        },
        //Goes to relevant page  TODO Remove if no searchlist
        goToPage: function(page){
            if(!this.initiating && page.from == 'search'){
                let newPage;
                page = page.content;

                if(page === 'goto')
                    page = this.pageToGoTo-1;

                if(page < 0)
                    newPage = Math.max(this.page - 1, 0);
                else
                    newPage = Math.min(page,Math.ceil(this.total/this.limit));

                if(this.page === newPage)
                    return;

                this.page = newPage;

                this.initiated = false;

                this.selected = -1;
            }
        },
        //Element selection from search list  TODO Remove if no searchlist
        selectElement: function(request){

            if(!request.from || request.from !== 'search')
                return;

            request = request.content;

            if(this.verbose)
                console.log('Selecting item ',request);

            if(this.currentMode === 'search'){
                if(this.selected === request){
                    this.switchModeTo('edit');
                }
                else{
                    this.selected = request;
                }
            }
        },
        shouldDisplayMode: function(index){
            if(index==='edit' && (this.selected === -1) )
                return false;

            return true;
        },
        //Switches to requested mode
        switchModeTo: function(newMode){
            if(this.currentMode === newMode)
                return;
            if(newMode === 'edit' && this.selected===-1){
                alertLog('Please select an item before you view/edit it!','warning',this.$el);
                return;
            };

            if(newMode==='edit'){
                switch (this.currentMode) {
                    case 'search':
                        this.currentMode = 'edit';
                        return;
                    default:
                        return
                }
            }else {
                this.selected=-1;
            }
            this.currentMode = newMode;
            this.currentOperation = '';
        },
        //Executes the operation
        confirmOperation: function(payload){
        },
        //Initiates an operation
        operation: function(operation){

            if(this.test)
                console.log('Operation',operation);
            switch (operation){
                case 'cancel':
                    this.cancelOperation();
                    this.selected = -1;
                    this.currentOperation = '';
                    break;
                default:
                    this.currentOperation = operation;
            }
        },
        shouldDisplayOperation: function(index){
            //Search mode
            if(this.currentMode === 'search'){
                if(this.selected === -1)
                    return false;
            }
            //Edit mode
            else if(this.currentMode === 'edit'){
            }

            return true;
        },
        //Cancels the operation
        cancelOperation: function(){

            if(this.test)
                console.log('Canceling operation');
            if(this.currentMode === 'search'){
                this.selected = -1;
            }
            else if(this.currentMode === 'edit'){
                this.currentMode = 'search';
                this.selected = -1;
            };
            this.operationInput= '';
            this.currentOperation = '';

        }
    },
});