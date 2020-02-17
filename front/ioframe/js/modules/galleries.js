if(eventHub === undefined)
    var eventHub = new Vue();

//***************************
//******GALLERIES APP*******
//***************************//
var galleries = new Vue({
    el: '#galleries',
    mixins:[sourceURL],
    data: {
        configObject: JSON.parse(JSON.stringify(document.siteConfig)),
        //Modes, and array of available operations in each mode
        modes: {
            search:{
                operations:{
                    create:{
                        title:'Create New Gallery'
                    },
                    'delete':{
                        title:'Delete'
                    },
                    'cancel':{
                        title:'Cancel'
                    }
                },
                title:'View Galleries'
            },
            edit:{
                operations:{
                    'remove':{
                        title:'Remove From Gallery'
                    },
                    'cancel':{
                        title:'Cancel'
                    },
                    'add':{
                        title:'Add Image To Gallery'
                    },
                },
                title:'View/Edit Gallery'
            }
        },
        //Filters to display for the search list
        filters:[
            {
                type:'Group',
                group: [
                    {
                        name:'createdAfter',
                        title:'Created After',
                        type:'Datetime',
                        parser: function(value){ return Math.round(value/1000); }
                    },
                    {
                        name:'createdBefore',
                        title:'Created Before',
                        type:'Datetime',
                        parser: function(value){ return Math.round(value/1000); }
                    }
                ]
            },
            {
                type:'Group',
                group: [
                    {
                        name:'changedAfter',
                        title:'Changed After',
                        type:'Datetime',
                        parser: function(value){ return Math.round(value/1000); }
                    },
                    {
                        name:'changedBefore',
                        title:'Changed Before',
                        type:'Datetime',
                        parser: function(value){ return Math.round(value/1000); }
                    }
                ]
            },
            {
                type:'Group',
                group: [
                    {
                        name:'includeRegex',
                        title:'Include',
                        placeholder:'Text gallery name includes',
                        type:'String',
                        min:0,
                        max: 64,
                        validator: function(value){
                            return value.match(/^[\w\.\-\_ ]{1,64}$/) !== null;
                        }
                    },
                    {
                        name:'excludeRegex',
                        title:'Exclude',
                        placeholder:'Text gallery name excludes',
                        type:'String',
                        min:0,
                        max: 64,
                        validator: function(value){
                            return value.match(/^[\w\.\-\_ ]{1,64}$/) !== null;
                        }
                    },
                ]
            }
        ],
        //Result comunts to display, and how to parse them
        columns:[
            {
                id:'identifier',
                title:'Gallery Name',
                parser:function(name){
                    return name;
                }
            },
            {
                id:'created',
                title:'Date Created',
                parser:function(timestamp){
                    timestamp *= 1000;
                    return timestampToDate(timestamp).split('-').reverse().join('-');
                }
            },
            {
                id:'lastChanged',
                title:'Last Changed',
                parser:function(timestamp){
                    timestamp *= 1000;
                    return timestampToDate(timestamp).split('-').reverse().join('-');
                }
            }
        ],
        //Current page
        page:0,
        //Limit
        limit:50,
        //Total available results
        total: 0,
        //Galleries (on this page)
        galleries: [],
        //Whether the search list is initiated
        galleriesInitiated: false,
        //Selected gallery - search list
        selected:-1,
        //Currently selected gallery object
        gallery: {},
        //Members of currently selected gallery
        galleryMembers: [],
        //Whether currently selected gallery is initiated
        galleryInitiated: false,
        //Selected gallery - current gallery in editor
        selectedGalleryMembers:[],
        //View 2 elements - editor
        viewElements: {},
        //View 2 selected - editor
        viewSelected: [],
        //Whether view2 is up-to-date  - editor
        viewUpToDate:false,
        //View 2 target - editor
        target:'',
        //View 2 url - editor
        url:'',
        //Current operation mode
        currentMode: 'search',
        //Current operation
        currentOperation: '',
        //Current operation input
        operationInput:'',
        //Targets to move
        moveTargets:[],
        //Whether we are currently loading
        isLoading:false,
        verbose:false,
        test:false
    },
    created:function(){
        eventHub.$on('searchResults',this.parseSearchResults);
        eventHub.$on('parseGallery',this.parseGalleryResponse);
        eventHub.$on('requestSelection',this.selectElement);
        eventHub.$on('requestSelectionGallery',this.selectGalleryElement);
        eventHub.$on('goToPage',this.goToPage);
        eventHub.$on('viewElementsUpdated', this.updateSecondView);
        eventHub.$on('changeURLRequest', this.changeViewURL);
        eventHub.$on('select', this.selectElement);
        eventHub.$on('drop', this.moveGalleryElement);
    },
    computed:{
        //Gets the selected gallery
        getSelectedGallery: function(){
            if(this.selected !== -1)
                return this.galleries[this.selected];
            else
                return {};
        },
        //Main title
        title:function(){
            switch(this.currentMode){
                case 'search':
                    return 'Galleries';
                    break;
                case 'edit':
                    return 'Viewing Gallery';
                    break;
                case 'create':
                    return 'Creating Gallery';
                    break;
                default:
            }
        },
        //Secondary title
        secondTitle:function(){
            switch(this.currentOperation){
                case 'add':
                    return 'Choose an image to add to the gallery';
                    break;
                default:
                    return '';
            }
        },
        //Text for current operation
        currentOperationText:function(){
            switch(this.currentOperation){
                case 'delete':
                    return 'Delete selected?';
                    break;
                case 'remove':
                    return 'Remove selected images from gallery?';
                    break;
                case 'create':
                    return 'New gallery name:';
                    break;
                case 'add':
                    return 'Add selected images to gallery?:';
                    break;
                default:
                    return '';
            }
        },
        //Text for current operation
        currentOperationHasInput:function(){
            switch(this.currentOperation){
                case 'create':
                    return true;
                    break;
                default:
                    return false;
            }
        },
        //Whether the current mode has operations
        currentModeHasOperations:function(){
            return Object.keys(this.modes[this.currentMode].operations).length>0;
        },
        targetIsFolder:function(){
            return this.target!== '' && (this.target.indexOf('.') === -1);
        },
        mediaURL: function(){
            return document.pathToRoot + 'api/media';
        }
    },
    methods:{
        //Parses search results returned from a search list
        parseSearchResults: function(response){
            if(this.verbose)
                console.log('Recieved response',response);

            if(!response.from || response.from !== 'search')
                return;

            //Either way, the galleries should be considered initiated
            this.galleries = [];
            this.galleriesInitiated = true;

            //In this case the response was an error code, or the page no longer exists
            if(response.content['@'] === undefined)
                return;

            this.total = (response.content['@']['#'] - 0) ;
            delete response.content['@'];

            for(let k in response.content){
                response.content[k].identifier = k;
                this.galleries.push(response.content[k]);
            }
        },
        //Parses API response for gallery initiation
        parseGalleryResponse: function(request){

            if(!request.from || request.from !== 'editor')
                return;

            this.galleryInitiated = true;

            let response = request.content;

            if(typeof response !== 'object'){
                alertLog('Gallery initiation failed with response '+response,'error',this.$el);
                return;
            }

            //From here on out, we assume a valid gallery
            this.galleryMembers = [];
            for(let key in response){
                if(key === '@')
                    continue;
                response[key].identifier = key;
                this.galleryMembers.push(response[key]);
            }
        },
        //Moves gallery element to a new position
        moveGalleryElement: function(request){
            if(!request.from || request.from !== 'editor-viewer1')
                return;
            this.currentOperation = 'move';
            this.moveTargets = request.content;
            this.confirmOperation();
        },
        //Goes to a different page
        goToPage: function(response){
            if(this.verbose)
                console.log('Recieved response',response);

            if(!response.from || response.from !== 'search')
                return;

            this.page = response.content;

            this.galleriesInitiated = false;
        },
        //Resets editor
        resetEditor: function(newMode){
            this.selectedGalleryMembers = [];
            this.galleryMembers = [];
            this.galleryInitiated = false;
            this.viewElements = {};
            this.viewSelected = [];
            this.moveTargets = [];
            this.viewUpToDate = false;
        },
        //Switches to requested mode
        switchModeTo: function(newMode){
            if(this.currentMode === newMode)
                return;
            if(newMode === 'edit' && this.selected===-1){
                alertLog('Please select an image before you view/edit it!','warning',document.querySelector('#galleries'));
                return;
            };
            this.currentMode = newMode;
            this.currentOperation = '';
        },
        //Initiates an operation
        operation: function(operation){
            if(this.test)
                console.log('Operation',operation);
            switch (operation){
                case 'delete':
                    this.currentOperation = 'delete';
                    break;
                case 'cancel':
                    if(this.currentMode === 'search'){
                        this.target = '';
                    }
                    else if(this.currentMode === 'edit'){
                        this.selectedGalleryMember = [];
                    }
                    this.cancelOperation();
                    break;
                default:
                    this.currentOperation = operation;
            }
        },
        //Executes the operation
        confirmOperation: function(){
            if(this.test)
                console.log('Current Operation ', this.currentOperation ,'Current input ',this.operationInput);
            var data = new FormData();
            var apiURL = document.pathToRoot+"api/media";
            var test = this.test;
            var verbose = this.verbose;
            var currentOperation = this.currentOperation;
            var thisElement = this.$el;
            if(this.currentMode === 'search'){
                switch (currentOperation){
                    case 'delete':
                        data.append('action','deleteGallery');
                        data.append('gallery',this.galleries[this.selected].identifier);
                        break;
                    case 'create':
                        if(this.operationInput === ''){
                            alertLog('Gallery to be created must have a name!','warning',this.$el);
                            return;
                        }
                        if(this.operationInput.match(/^[\w ]{1,128}$/)  === null){
                            alertLog('Gallery name may contain characters, latters, and space!','warning',this.$el);
                            return;
                        }
                        data.append('action','setGallery');
                        data.append('gallery',this.operationInput);
                        break;
                    default:
                };
            }
            else if(this.currentMode === 'edit'){
                switch (currentOperation){
                    case 'remove':
                        let stuffToRemove = [];
                        let index = 0;
                        for(let k in this.selectedGalleryMembers){
                            index = this.selectedGalleryMembers[k];
                            stuffToRemove.push(this.galleryMembers[index].identifier);
                        }

                        if(stuffToRemove.length > 0){
                            data.append('action','removeFromGallery');
                            data.append('gallery',this.galleries[this.selected].identifier);
                            data.append('addresses' , JSON.stringify(stuffToRemove) );
                        }
                        break;
                    case 'move':
                        data.append('action','moveImageInGallery');
                        data.append('gallery',this.galleries[this.selected].identifier);
                        data.append('from' , this.moveTargets[0]);
                        data.append('to' , this.moveTargets[1] );
                        break;
                    case 'add':
                        let stuffToAdd = [];
                        for(let k in this.viewSelected){
                            stuffToAdd.push( (this.url==='') ? this.viewSelected[k] : this.url+'/'+this.viewSelected[k] );
                        }
                        if(stuffToAdd.length > 0){
                            data.append('action','addToGallery');
                            data.append('gallery',this.galleries[this.selected].identifier);
                            data.append('addresses' , JSON.stringify(stuffToAdd) );
                        }
                        break;
                    default:
                };
            }
            //Handle the rest of the request if it should be sent
            if(data.get('action')){
                this.isLoading = true;
                if(this.test){
                    data.append('req','test');
                };
                updateCSRFToken().then(
                    function(token){
                        data.append('CSRF_token', token);
                        fetch(
                            apiURL,
                            {
                                method: 'post',
                                body: data,
                                mode: 'cors'
                            }
                        )
                            .then(function (json) {
                                return json.text();
                            })
                            .then(function (data) {
                                let response = data;
                                if(verbose)
                                    console.log('Response data',response);
                                galleries.handleResponse(response, currentOperation);
                            })
                            .catch(function (error) {
                                alertLog('View initiation failed! '+error,'error',thisElement);
                            });
                    },
                    function(reject){
                        alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                    }
                );
            }
            this.cancelOperation();
        },
        //Cancels the operation
        cancelOperation: function(){
            if(this.test)
                console.log('Canceling operation');
            if(this.currentMode === 'search'){
                this.selected = -1;
            }
            else if(this.currentMode === 'edit'){
                this.selectedGalleryMembers = [];
                this.viewSelected = [];
            };
            this.operationInput = '';
            this.currentOperation = '';
        },
        shouldDisplayOperation: function(index){
            //Search mode
            if(this.currentMode === 'search'){
                if(this.selected === -1 && index !== 'create')
                    return false;
                else if(this.selected !== -1 && index === 'create')
                    return false;
            }
            //Edit mode
            else if(this.currentMode === 'edit'){
                //Always display 'cancel' when there are selected members
                if(this.selectedGalleryMembers.length !== 0 &&  index === 'cancel')
                    return true;

                if(this.selectedGalleryMembers.length === 0 && index !== 'add')
                    return false;
                else if(this.selectedGalleryMembers.length > 0 && index !== 'remove')
                    return false;
            }

            return true;
        },
        shouldDisplayMode: function(index){
            if(index==='edit' && (this.selected === -1) )
                return false;
            if(index==='create' && (this.selected !== -1))
                return false;

            return true;
        },
        //Selects an element, if the mode is right
        selectElement: function(request){
            if(this.verbose)
                console.log('Selecting item ',request);
            if(this.currentMode === 'search'){
                this.resetEditor();
                if(this.selected === request){
                    this.switchModeTo('edit');
                }
                else{
                    this.selected = request;
                }
            }
            else if(this.currentMode === 'edit'){
                if(!request.from || request.from !== 'editor-viewer2')
                    return;

                let newTarget = request.key;
                let targetName = newTarget.split('/').pop();
                let element = this.viewElements[newTarget];
                // Select/Unselect an image
                if(!element.folder){
                    if(this.viewSelected.indexOf(targetName) !== -1){
                        this.viewSelected.splice(this.viewSelected.indexOf(targetName),1);
                    }
                    else{
                        this.viewSelected.push(targetName);
                    }
                }
                //Open a folder
                else{
                    this.changeViewURL({from:'editor',content:newTarget});
                }

            }
        },
        //Selects a gallery element
        selectGalleryElement: function(request){
            if(this.verbose)
                console.log('Selecting gallery item ',request);
            if(this.selectedGalleryMembers.indexOf(request) !== -1){
                this.selectedGalleryMembers.splice(this.selectedGalleryMembers.indexOf(request),1);
            }
            else{
                this.selectedGalleryMembers.push(request);
            }
        },
        //Updates the galleries list
        updateGalleries: function(request){
        },
        //Handles responses of the API based on the operation
        handleResponse: function(response, currentOperation){
            this.isLoading = false;
            if(typeof response === 'string' && response.match(/^\d+$/))
                response = response - 0;
            if(this.currentMode === 'search')
                switch (currentOperation){
                    case 'delete':
                        switch (response){
                            case -1:
                                alertLog('Database connection failed!','warning',this.$el);
                                break;
                            case 0:
                                alertLog('Gallery deleted!','success',this.$el);
                                this.galleriesInitiated = false;
                                eventHub.$emit('refreshSearchResults');
                                break;
                            default :
                                alertLog('Operation failed with response: '+response,'error',this.$el);
                                break;
                        }
                        break;
                    case 'create':
                        switch (response){
                            case -1:
                                alertLog('Database connection failed!','warning',this.$el);
                                break;
                            case 1:
                                alertLog('Gallery name already exists!','info',this.$el);
                                break;
                            case 0:
                                alertLog('Gallery created!','success',this.$el);
                                this.galleriesInitiated = false;
                                eventHub.$emit('refreshSearchResults');
                                break;
                            default :
                                alertLog('Operation failed with response: '+response,'error',this.$el);
                                break;
                        }
                        break;
                }
            else if(this.currentMode === 'edit'){
                switch (currentOperation){
                    case 'remove':
                        switch (response){
                            case -1:
                                alertLog('Database connection failed!','warning',this.$el);
                                break;
                            case 0:
                                alertLog('Images removed from gallery!','success',this.$el);
                                break;
                            default :
                                alertLog('Operation failed with response: '+response,'error',this.$el);
                                break;
                        }
                        this.resetEditor();
                        break;

                    case 'add':

                        //First, handle invalid responses
                        if(!IsJsonString(response)){
                            alertLog('Operation failed with response: '+response,'error',this.$el);
                            return;
                        }
                        else
                            response = JSON.parse(response);

                        let responseBody = '';
                        let responseType = 'success';
                        let allAdded = true;
                        let serverError = false;
                        let failedItems = {};
                        for(let index in response){
                            let code = response[index];
                            switch (code){
                                case -1:
                                    serverError = true;
                                    allAdded = false;
                                    break;
                                case 0:
                                    break;
                                case 1:
                                    allAdded = false;
                                    failedItems[index] = 'Resource no longer exists';
                                    break;
                                case 2:
                                    serverError = true;
                                    allAdded = false;
                                    break;
                                case 3:
                                    allAdded = false;
                                    failedItems[index] = 'Resource already in collection';
                                    break;
                                default :
                                    allAdded = false;
                                    failedItems[index] = 'Failed with code '+code;
                                    break;
                            }
                        }
                        if(allAdded){
                            responseBody += 'All images added to gallery!';
                        }
                        else if(serverError){
                            responseBody += 'A server error occurred! Items were not added.';
                            responseType = 'error';
                        }
                        else{
                            responseType = 'info';
                            responseBody += '<div>Some resources were not added, for the following reasons:</div>';
                            for(let resourceName in failedItems){
                                responseBody += '<div>';
                                responseBody += '<span>' + resourceName + '</span>' +' : ' + '<span>' + failedItems[resourceName] + '</span>';
                                responseBody += '</div>';
                            }
                        }

                        alertLog(responseBody,responseType,this.$el);
                        this.resetEditor();
                        break;

                    case 'move':
                        switch (response){
                            case -1:
                                alertLog('Database connection failed!','warning',this.$el);
                                break;
                            case 0:
                                alertLog('Image moved!','success',this.$el);
                                //In this specific case, we only re-render the front end, not refresh the gallery.
                                let from = this.moveTargets[0];
                                let to = this.moveTargets[1];
                                let elementToMove = this.galleryMembers.splice(from,1)[0];
                                this.galleryMembers.splice(to,0,elementToMove);
                                break;
                            case 1:
                                alertLog('One of the images no longer exists in the gallery!','success',this.$el);
                                break;
                            case2:
                                alertLog('Gallery no longer exists!','success',this.$el);
                                break;
                            default :
                                alertLog('Operation failed with response: '+response,'error',this.$el);
                                break;
                        }
                        //In this specific case, we assume all worked well on the success code and dont refresh the gallery.
                        if(response !== 0)
                            this.resetEditor();
                        break;
                }
            }
        },
        //Initiates the 2nd view
        updateSecondView: function(request){
            if(!request.from || request.from !== 'editor-viewer2')
                return;

            if(this.verbose)
                console.log('Recieved', request);

            const response = request.content;

            //If we got a valid view, update the app
            if(typeof response === 'object'){
                this.viewElements = response;
                this.viewUpToDate = true;
            }
            //Handle errors
            else{
                if(this.test)
                    console.log('Error code: '+response);
            }
        },
        //Changes the view URL
        changeViewURL: function(request){

            if(!request.from || !(request.from === 'editor-viewer2' || request.from === 'editor' ) )
                return;

            if(this.verbose)
                console.log('Recieved', request);

            this.url = request.content;
            this.viewSelected = [];
            this.viewUpToDate = false;
        }
    },
    mounted: function(){
    }
});