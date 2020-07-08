if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('gallery-editor', {
    mixins:[
        eventHubManager
    ],
    props: {
        //Gallery we are displaying. May be {} if nothing is selected. Remember, this is a Vue object, no clean prototype!
        gallery: {
            type: Object
        },
        //Identifier
        identifier: {
            type: String
        },
        //Gallery members
        galleryMembers: {
            type: Array,
            default: function(){
                return [];
            }
        },
        //Current operation
        currentOperation: {
            type: String,
            default:''
        },
        //Currently selected gallery member
        selected: {
            type: Array,
            default: function(){
                return [];
            }
        },
        //Whether the gallery info is initiated
        initiated: {
            type: Boolean,
            default: false
        },
        view:{
            type: Object,
            default: function(){
                return {
                    elements: {},
                    selected: {},
                    upToDate: {},
                    target: {},
                    url: {}
                };
            }
        },
        searchList:{
            type: Object,
            default: function(){
                return {
                    elements: {},
                    selected: {},
                    upToDate: {},
                    target: {},
                    url: {}
                };
            }
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
        }
    },
    data: function(){
        return {
            //Whether we are currently initiating
            initiating: false,
            //Type of media viewer - 'local' or 'db'
            viewerType: 'local',
        };
    },
    template: `
         <div class="gallery-editor">
            <div>
                <div v-if="galleryMembers.length === 0">
                Nothing to display!
                </div>

                <div  v-else=""
                is="media-viewer"
                class="gallery-viewer"
                :display-elements-ordered="galleryMembers"
                :multiple-targets="selected"
                :select-multiple="allowSelectMultiple"
                :allow-searching="false"
                :show-sizes="false"
                :show-names="false"
                :draggable="true"
                :test="test"
                :verbose="verbose"
                :identifier="identifier+'-viewer1'"
                ></div>

                <div v-if="needViewer">
                    <h1 >Select images from bellow:</h1>

                    <div class="types">
                        <button class="positive-3" :class="{selected:viewerType === 'local'}" @click="viewerType = 'local'">Local</button>
                        <button class="positive-3" :class="{selected:viewerType === 'db'}" @click="viewerType = 'db'">Remote</button>
                    </div>

                    <div  v-if="viewerType === 'local'"
                    is="media-viewer"
                    :url="view.url"
                    :target="view.target"
                    :display-elements="view.elements"
                    :select-multiple="allowSelectMultiple"
                    :multiple-targets="view.selected"
                    :initiate="!view.upToDate"
                    :verbose="verbose"
                    :test="test"
                    :identifier="identifier+'-viewer2'"
                    ></div>
                    <div    v-if="viewerType === 'db'"
                    is="search-list"
                    :_functions="searchList.functions"
                    :api-url="searchList.url"
                    :extra-params="searchList.extraParams"
                    :extra-classes="searchList.extraClasses"
                    api-action="getImages"
                    :page="searchList.page"
                    :limit="searchList.limit"
                    :total="searchList.total"
                    :items="searchList.items"
                    :initiate="!searchList.initiated"
                    :columns="searchList.columns"
                    :filters="searchList.filters"
                    :selected="searchList.selected"
                    :test="test"
                    :verbose="verbose"
                    :identifier="identifier+'-search'"
                    ></div>
                </div>
            </div>
         </div>
        `,
    methods: {
        //Initiates the gallery info from the API
        initiateGallery: function(){
            //Make sure we're not initiating already
            if(this.initiating){
                if(this.verbose)
                    console.log('Gallery already initiating!');
                return;
            }
            else
                this.initiating = true;

            if(this.verbose)
                console.log('Querying API for gallery '+this.gallery.identifier);

            //Data to be sent
            var data = new FormData();
            data.append('action', 'getGallery');
            data.append('gallery', this.gallery.identifier);
            //Api url
            let apiURL = document.pathToRoot+"api/media";
            var test = this.test;
            var verbose = this.verbose;
            var thisElement = this.$el;
            var identifier = this.identifier;
            //Assume request succeeded and images are not gonna be cropped
            this.imagesNeedCropping = true;
            //Request itself
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
                            if(verbose)
                                console.log('Request succeeded!');
                            let response;
                            //A valid response would be a JSON
                            if(IsJsonString(data)){
                                response = JSON.parse(data);
                                if(response.length === 0)
                                    response = {};
                            }
                            //Any non-json response is invalid
                            else
                                response = data;
                            if(verbose)
                                console.log('Request data',response);
                            const request = {
                                from:identifier,
                                content:response
                            };
                            if(verbose)
                                console.log('Emitting parseGallery', request);
                            eventHub.$emit('parseGallery', request);
                        })
                        .catch(function (error) {
                            alertLog('View initiation failed! '+error,'error',thisElement);
                            eventHub.$emit('parseGallery', {});
                        });
                },
                function(reject){
                    alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                    eventHub.$emit('parseGallery', {});
                }
            );
        },
        //Selects a picture inside the main or secondary gallery
        selectElement: function(request){
            if(!request.from || request.from !== this.identifier+'-viewer1')
                return;

            if(this.test)
                console.log('Recieved', request);

            let newTarget =  request.key - 0;

            eventHub.$emit('requestSelectionGallery',newTarget);
        },
        //Signifies the query for the gallery is done
        parseGalleryResponse: function(){
            this.initiating = false;
        },
        //Returns absolute media URL
        absoluteMediaURL:function(relativeURL){
            return this.sourceURL() + 'img/'+relativeURL;
        }
    },
    computed:{
        allowSelectMultiple: function(){
            if(this.currentOperation === 'remove'){

            }
        },
        //We only need the viewer when adding a picture from media to a gallery.
        needViewer:function(){
            return this.currentOperation === 'add';
        },
    },
    created:function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' created, current gallery: ',this.gallery);
        this.registerHub(eventHub);
        this.registerEvent('select', this.selectElement);
        this.registerEvent('parseGallery', this.parseGalleryResponse);
    },
    beforeMount:function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' beforeMount');
    },
    mounted:function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' mounted');
        if(!this.initiated && !this.initiating){
            if(this.verbose)
                console.log('Initiating at mount!');
            this.initiateGallery();
        }
    },
    beforeUpdate: function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' beforeUpdate');
    },
    updated: function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' updated');
        if(!this.initiated && !this.initiating){
            if(this.verbose)
                console.log('Initiating at update!');
            this.initiateGallery();
        }
    },
    watch:{
        viewerType: function(){
            eventHub.$emit('resetEditorView');
        }
    }
});