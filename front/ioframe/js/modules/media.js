if(eventHub === undefined)
    var eventHub = new Vue();

//***************************
//****** MEDIA APP*******
//***************************//
var media = new Vue({
    el: '#media',
    name:'Media',
    mixins:[sourceURL],
    data: {
        configObject: document.siteConfig,
        //Modes, and array of available operations in each mode
        modes: {
            'view':{
                operations:{
                    'move':{
                        title:'Move'
                    },
                    'copy':{
                        title:'Copy'
                    },
                    'rename':{
                        title:'Rename (filename)'
                    },
                    'delete':{
                        title:'Delete'
                    },
                    'deleteMultiple':{
                        title:'Delete Multiple'
                    },
                    'create':{
                        title:'Create Folder'
                    },
                    'cancel':{
                        title:'Cancel'
                    }
                },
                title:'View Media'
            },
            'edit':{
                operations:{},
                title:'View/Edit Image'
            },
            'upload':{
                operations:{},
                title:'Upload Image'
            }
        },
        currentMode: 'view',
        currentOperation: '',
        operationInput:'',
        url: '',
        target:'',
        deleteTargets:[],
        view1Elements: {},
        view1UpToDate:false,
        view2URL: '',
        view2Elements: {},
        view2Target:'',
        view2UpToDate:false,
        isLoading:false,
        verbose:false,
        test:false
    },
    created:function(){
        //Tells viewer to load initial target
        eventHub.$on('select', this.selectElement);
        eventHub.$on('changeURLRequest', this.changeURLRequest);
        eventHub.$on('viewElementsUpdated', this.updateViewElements);
        eventHub.$on('updateViewElement', this.updateViewElement);
        eventHub.$on('imageUploadedToServer', this.updateView);
    },
    computed:{
        //We don't need the main viewer when editing or uploading
        needViewer:function(){
            const modes = ['upload','edit'];
            return modes.indexOf(this.currentMode) === -1;
        },
        //We need the second viewer only when creating a folder, moving or copying
        needSecondViewer:function(){
            const operations = ['move'];
            return operations.indexOf(this.currentOperation) !== -1;
        },
        //Main title
        title:function(){
            switch(this.currentMode){
                case 'view':
                    return 'Media';
                    break;
                case 'edit':
                    return 'Editing image';
                    break;
                case 'upload':
                    return 'Uploading image';
                    break;
                default:
            }
        },
        //Secondary title
        secondTitle:function(){
            switch(this.currentOperation){
                case 'move':
                    return 'Choose the folder to move the item into';
                    break;
                default:
                    return '';
            }
        },
        //Text for current operation
        currentOperationText:function(){
            switch(this.currentOperation){
                case 'move':
                    return 'Move to selected item?';
                    break;
                case 'copy':
                    return 'Choose new name:';
                    break;
                case 'delete':
                    return 'Delete selected?';
                    break;
                case 'rename':
                    return 'Choose a new name:';
                    break;
                case 'deleteMultiple':
                    return 'Delete selected?';
                    break;
                case 'create':
                    return 'Choose a new the folder name:';
                    break;
                default:
                    return '';
            }
        },
        //Text for current operation
        currentOperationHasInput:function(){
            switch(this.currentOperation){
                case 'copy':
                    return true;
                    break;
                case 'create':
                    return true;
                    break;
                case 'rename':
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
        }
    },
    methods:{
        //Switches to requested mode
        updateView: function(newMode){
            this.view1UpToDate = false;
        },
        //Switches to requested mode
        switchModeTo: function(newMode){
            if(this.currentMode === newMode)
                return;
            if(newMode === 'edit' && this.target===''){
                alertLog('Please select an image before you view/edit it!','info',document.querySelector('#media'));
                return;
            };
            this.currentMode = newMode;
        },
        //Initiates an operation
        operation: function(operation){
            if(this.test)
                console.log('Operation',operation);
            switch (operation){
                case 'copy':
                    let newName = this.target;
                    if(newName.indexOf('.') !== -1){
                        newName = newName.split('.');
                        let extension = newName.pop();
                        newName[0] += (' copy');
                        newName.push(extension);
                        newName = newName.join('.');
                    }
                    else
                        newName += ' copy';
                    this.operationInput = newName;
                    this.currentOperation = operation;
                    break;
                case 'rename':
                    this.operationInput = this.target;
                    this.currentOperation = operation;
                    break;
                case 'delete':
                    this.deleteTargets.push(this.target);
                    this.target = '';
                    this.currentOperation = 'deleteMultiple';
                    break;
                case 'cancel':
                    this.target = '';
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
            switch (currentOperation){
                case 'move':
                    let oldURL = this.url;
                    if(oldURL[oldURL.length-1]!=='/' && oldURL!=='')
                        oldURL += '/';
                    let newURL = this.view2URL;
                    if(newURL[newURL.length-1]!=='/' && newURL!=='')
                        newURL += '/';
                    let source = oldURL+this.target;
                    let destination =  newURL+this.target;
                    if(source === destination)
                        alertLog('Cannot move to the same folder!','warning',document.querySelector('#media'));
                    else{
                        data.append('action', 'moveImage');
                        data.append('oldAddress', source);
                        data.append('newAddress', destination);
                        data.append('copy', false);
                        if(this.verbose)
                            console.log('Moving ',source,' to ',destination);
                    }

                    break;
                case 'copy':
                    if(this.view1Elements[this.operationInput] !== undefined)
                        alertLog(this.operationInput,' already exists, cannot copy!','warning',document.querySelector('#media'));
                    else{
                        data.append('action', 'moveImage');
                        let oldURL = this.url;
                        if(oldURL[oldURL.length-1]!=='/' && oldURL!=='')
                            oldURL += '/';
                        let newURL = oldURL;
                        let source = oldURL+this.target;
                        let destination =  newURL+this.operationInput;
                        data.append('oldAddress', source);
                        data.append('newAddress', destination);
                        data.append('copy', true);
                        if(this.verbose)
                            console.log('Copying ',source,' to ',destination);
                    }
                    break;
                case 'rename':
                    if(this.view1Elements[this.operationInput] !== undefined)
                        alertLog(this.operationInput,' already exists, cannot rename!','warning',document.querySelector('#media'));
                    else{
                        data.append('action', 'moveImage');
                        let oldURL = this.url;
                        if(oldURL !== '' && oldURL!=='')
                            oldURL += '/';
                        let newURL = oldURL;
                        let source = oldURL+this.target;
                        let destination =  newURL+this.operationInput;
                        data.append('oldAddress', source);
                        data.append('newAddress', destination);
                        data.append('copy', false);
                        if(this.verbose)
                            console.log('Moving (renaming) ',source,' to ',destination);
                    }
                    break;
                case 'deleteMultiple':
                    var deletionTargets = [];
                    var url = this.url;
                    if(url!== '')
                        url +='/';
                    this.deleteTargets.forEach(function(item,index){
                        deletionTargets.push(url+item);
                    });
                    if(deletionTargets.length>0){
                        data.append('action', 'deleteImages');
                        data.append('addresses', JSON.stringify(deletionTargets));
                    }
                    if(this.verbose)
                        console.log('Deleting ',deletionTargets);
                    break;
                case 'create':
                    if(this.view1Elements[this.operationInput] !== undefined)
                        console.log(this.operationInput,' already exists, cannot create folder!');
                    else{
                        data.append('action', 'createFolder');
                        var url = this.url;
                        if(url!== '')
                            data.append('relativeAddress', this.url);
                        data.append('name', this.operationInput);
                        if(this.verbose)
                            console.log('Creating ', this.operationInput);
                    }
                    break;
                default:
            };
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
                                media.handleResponse(response, currentOperation);
                            })
                            .catch(function (error) {
                                alertLog('View initiation failed! '+error,'error',thisElement);
                                eventHub.$emit('viewInitiated', error);
                            });
                    },
                    function(reject){
                        alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                        eventHub.$emit('viewInitiated', request);
                    }
                );
            }
            this.cancelOperation();
        },
        //Cancels the operation
        cancelOperation: function(){
            if(this.test)
                console.log('Canceling operation');
            this.currentOperation = '';
            this.operationInput = '';
            Vue.set(this,'deleteTargets',[]);
        },
        shouldDisplayOperation: function(index){
            if(this.target === '' && index !== 'deleteMultiple' && index !== 'create')
                return false;
            else if(this.target !== '' && (index === 'deleteMultiple' || index === 'create') )
                return false;
            else if(this.target === '' && (index === 'cancel') )
                return false;

            return true;
        },
        shouldDisplayMode: function(index){
            if(index==='edit' && (this.target==='' || this.targetIsFolder) )
                return false;
            if(index==='upload' && this.target!=='' && !this.targetIsFolder)
                return false;

            return true;
        },
        //Selects an element, if the mode is right
        selectElement: function(request){
            if(!request.from || request.from === 'media')
                return;

            if(this.test)
                console.log('Recieved', request);

            let isFolder = request.content.folder;
            let shouldSelect = true;
            let newTarget = request.key.split('/').pop();

            if(this.currentOperation === 'deleteMultiple'){
                let oldIndex = this.deleteTargets.indexOf(newTarget);
                if(oldIndex === -1)
                    this.deleteTargets.push(newTarget);
                else
                    this.deleteTargets.slice(oldIndex);
            }
            else{
                if(request.from === 'viewer1'){

                    this.cancelOperation();

                    let oldTarget = this.target;

                    if(isFolder){
                        if(oldTarget !== newTarget)
                            this.target = newTarget;
                        else{
                            const targetFolder = newTarget;
                            let newURL = this.url;
                            if(newURL != '')
                                newURL += '/';
                            this.changeURL('viewer1',newURL+targetFolder);
                        }
                    }
                    else{
                        if(this.target !== newTarget)
                            this.target = newTarget;
                        else
                            this.switchModeTo('edit')
                    }
                }
                else if(request.from === 'viewer2'){

                    let oldTarget = this.view2Target;

                    if(isFolder){
                        if(oldTarget !== newTarget)
                            this.view2Target = newTarget;
                        else{
                            const targetFolder = newTarget;
                            let newURL = this.view2URL;
                            if(newURL != '')
                                newURL += '/';
                            this.changeURL('viewer2',newURL+targetFolder);
                        }
                    }
                    else{
                        if(this.view2Target !== request.key)
                            this.view2Target = request.key;
                        else
                            this.view2Target = '';
                    }
                }
            }
        },
        changeURLRequest: function(request){

            if(this.test)
                console.log('Recieved', request);

            this.changeURL(request.from,request.content)
        },
        changeURL: function(viewer, newURL){
            //For now, handle only single selection, not deletion
            if(viewer === 'viewer1'){
                this.cancelOperation();
                this.url = newURL;
                this.target = '';
                this.view1UpToDate = false;
            }
            else if(viewer === 'viewer2'){
                this.view2URL = newURL;
                this.view2Target = '';
                this.view2UpToDate = false;
            }
        },
        //Updates the current view with what we got from a viewer
        updateViewElements: function(request){

            if(!request.from || request.from === 'media')
                return;

            if(this.test)
                console.log('Recieved', request);

            //If we got a valid view, update the app
            if(typeof request.content === 'object'){
                if(request.from === 'viewer1'){
                    this.view1Elements = request.content;
                    this.view1UpToDate = true;
                }
                else if(request.from === 'viewer2'){
                    this.view2Elements = request.content;
                    this.view2UpToDate = true;
                }
            }
            //Handle errors
            else{
                if(this.test)
                    console.log('Error code: '+request.content);
            }
        },
        //Updates a single element of the current view
        updateViewElement: function(request){

            if(!request.from || request.from === 'media')
                return;

            if(this.test)
                console.log('Recieved', request);

            //If we got a valid view, update the app
            let element = request.content;
            let targetKey = (this.url==='')? this.target : this.url+'/'+this.target;
            for(key in element){
                this.view1Elements[targetKey][key] = element[key];
            }
            this.view1UpToDate = false;
        },
        //Handles responses of the API based on the operation
        handleResponse: function(response, currentOperation){
            console.log(response,currentOperation);
            this.isLoading = false;
            this.changeURL('viewer1',this.url);
        }
    },
    mounted: function(){
    }
});