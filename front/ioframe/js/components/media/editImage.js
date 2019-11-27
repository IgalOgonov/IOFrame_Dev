if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('media-editor', {
    mixins:[sourceIcon],
    props: {
        //Identifier
        identifier: {
            type: String
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
        //Elements we are displaying
        image: {
            type: Object,
            default: function () {
                return {}
            }
        },
        //The current url which is viewed
        url: {
            type: String,
            default: ''
        },
        //Current target, if any
        target: {
            type: String,
            default: ''
        }
    },
    data: function(){
        return {
            newImageInfo:{
                name:'',
                alt:'',
                caption:''
            },
            h: 0,
            w: 0,
            edited:false,
            //Galleries the image belongs to
            galleries: [],
            //Whether the galleries have been initiated
            galleriesInitiated: false
        }
    },
    template: '\
         <div class="image-editor">\
            <div class="image-container">\
                <img :src="imageURL">\
            </div>\
            <div class="info-container">\
                <div class="properties">\
                    <label for="name" v-text="\'Name\'"></label>\
                    <input name="name" class="name property" type="text" v-model:value="newImageInfo.name" placeholder="Image has no name">\
                    <label for="alt" v-text="\'ALT Tag\'"></label>\
                    <input name="alt" class="alt property" type="text" v-model:value="newImageInfo.alt" placeholder="Image has no ALT">\
                    <label for="description" v-text="\'Description\'"></label>\
                    <textarea name="description" class="description property" v-model:value="newImageInfo.caption" placeholder="Image has no description"></textarea>\
                </div>\
                <div class="properties">\
                    <label for="size" v-text="\'Size\'"></label>\
                    <div name="size"" class="size property"  v-text="getImageSize"></div>\
                    <label for="dimensions" v-text="\'Dimensions (W x H)\'"></label>\
                    <div name="dimensions" class="dimensions property"  v-text="w + \' x \' + h"></div>\
                    <label for="address" v-text="\'Address\'"></label>\
                    <div name="address" class="address property" v-text="getImageAddress"></div>\
                </div>\
                <div class="galleries-container">\
                    <h1 class="gallery-title" v-if="galleriesInitiated" v-text="\'Galleries\'">\
                    </h1>\
                    <div class="gallery" v-if="galleriesInitiated" v-for="(item,index) in galleries">\
                        {{item}} \
                    </div>\
                    <button class="initiate-galleries" v-if="!galleriesInitiated" v-text="\'Show Galleries\'" @click="initiateGalleriesRequest">\
                    </button>\
                </div>\
            </div>\
            <div class="operations" v-if="edited">\
                <button class="update positive" @click="updateImage"">\
                    <div v-text="\'Confirm\'"></div>\
                    <img :src="sourceIcon(\'confirm\')">\
                </button>\
                <button class="reset cancel" @click="resetImage">\
                    <div v-text="\'Reset\'"></div>\
                    <img :src="sourceIcon(\'cancel\')">\
                </button>\
            </div>\
         </div>\
        ',
    methods: {
        updateImage: function(){

            if(!this.imageChanged){
                if(this.verbose)
                    console.log('Image has not changed, will not update!');
                return;
            }

            //Data to be sent
            var data = new FormData();
            data.append('action', 'updateImage');
            var address =  (this.url === '')? this.url : this.url+'/';
            address += this.target;
            data.append('address', address);
            data.append('deleteEmpty', true);
            data.append('name', this.newImageInfo.name);
            data.append('alt', this.newImageInfo.alt);
            data.append('caption', this.newImageInfo.caption);
            if(this.test)
                data.append('req', 'test');

            //Api url
            var apiURL = document.pathToRoot+"api/media";
            var verbose = this.verbose;
            var identifier = this.identifier;
            var thisElement = this.$el;
            var newImageInfo = this.newImageInfo;
            var test = this.test;
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
                            let response = data;
                            if(verbose)
                                console.log('Request data',response);

                            if(response == 0 || test){
                                const request = {
                                    from:identifier,
                                    content:newImageInfo
                                };
                                if(verbose)
                                    console.log('Emitting updateViewElement', request);
                                eventHub.$emit('updateViewElement', request);
                            }
                            //TODO Handle other responses
                        })
                        .catch(function (error) {
                            alertLog('View initiation failed! '+error,'error',thisElement);
                        });
                },
                function(reject){
                    alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                }
            );
        },
        resetImage: function(){

            if(this.image.name !== undefined)
                this.newImageInfo.name = this.image.name;
            else
                this.newImageInfo.name = '';

            if(this.image.alt !== undefined)
                this.newImageInfo.alt = this.image.alt;
            else
                this.newImageInfo.alt = '';

            if(this.image.caption !== undefined)
                this.newImageInfo.caption = this.image.caption;
            else
                this.newImageInfo.caption = '';

            this.edited = false;
        },
        initiateGalleries: function(request){
            if(!request.from || request.from !== this.identifier)
                return;
            let response = request.content;
            if(typeof response !== 'object'){
                alertLog('Galleries could not be initiated!','warning',this.$el.querySelector('.galleries-container'));
                return;
            }
            if(response.length === 0)
                response = ['*No Galleries Found'];
            this.galleries = response;
            this.galleriesInitiated = true;
        },
        initiateGalleriesRequest: function(){
            if(this.verbose)
                console.log('Querying API for '+this.url);

            //Data to be sent
            var data = new FormData();
            data.append('action', 'getImageGalleries');
            var address =  (this.url === '')? this.url : this.url+'/';
            address += this.target;
            data.append('address', address);

            //Api url
            var apiURL = document.pathToRoot+"api/media";
            var test = this.test;
            var verbose = this.verbose;
            var identifier = this.identifier;
            var thisElement = this.$el;

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
                                console.log('Emitting initiateGalleries', request);
                            eventHub.$emit('initiateGalleries', request);
                        })
                        .catch(function (error) {
                            alertLog('View initiation failed! '+error,'error',thisElement);
                        });
                },
                function(reject){
                    alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                }
            );
        },
        checkIfImagePropertiessChanged: function(){
            this.edited = this.imageChanged;
        },
        updateImageDimensions: function(request){
            if(request.from === this.identifier){
                this.w = request.w;
                this.h = request.h;
            }
        }
    },
    computed:{
        imageURL: function(){
            let result = this.sourceURL() + 'img/';
            result += (this.url === '')? this.url : this.url+'/';
            result += this.target;
            return result;
        },
        getImageName: function(){

        },
        getImageALT: function(){

        },
        getImageDesc: function(){

        },
        getImageSize: function(){
            //Render a "pretty" size
            const size = "" + this.image.size;
            let result = [];
            for(let i = size.length-1; i>=0; i--){
                result.push(result,size[i]);
                if( ( (size.length-1 - i) % 3 === 2 ) && i!==0)
                    result.push(result,',');
            }
            const prettySize = result.reverse().join('');

            //Calculate GB/KB/Etc
            let magnitude = 0;
            let bytes = this.image.size;
            while(bytes > 1000 && magnitude < 5){
                bytes = bytes/1000;
                magnitude++;
            }
            let suffix;
            switch (magnitude){
                case 1:
                    suffix = 'KB';
                    break;
                case 2:
                    suffix = 'MB';
                    break;
                case 3:
                    suffix = 'GB';
                    break;
                case 4:
                    suffix = 'TB';
                    break;
                default:
                    suffix = 'B';
            }
            const approx = Math.round(bytes)+suffix;

            return  prettySize + ' (' + approx + ')';
        },
        getImageAddress: function(){
            let url = 'Media Folder';
            if(this.url!=='')
                url += '/'+this.url;
            url += '/'+this.target;
            return url;
        },
        imageChanged: function(){
            return this.nameChanged || this.altChanged || this.captionChanged;
        },
        nameChanged: function(){
            return (this.image.name !== undefined && this.newImageInfo.name !== this.image.name) ||
                (this.image.name === undefined && this.newImageInfo.name !== '') ;
        },
        altChanged: function(){
            return (this.image.alt !== undefined && this.newImageInfo.alt !== this.image.alt) ||
                (this.image.alt === undefined && this.newImageInfo.alt !== '') ;
        },
        captionChanged: function(){
            return (this.image.caption !== undefined && this.newImageInfo.caption !== this.image.caption) ||
                (this.image.caption === undefined && this.newImageInfo.caption !== '') ;
        }
    },
    created:function(){
        if(this.verbose)
            console.log('Viewer ',this.identifier,' created');
        //Checks if image properties were changed
        eventHub.$on('changed',this.checkIfImagePropertiessChanged);
        eventHub.$on('updateImageDimensions',this.updateImageDimensions);
        eventHub.$on('initiateGalleries',this.initiateGalleries);
    },
    mounted: function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' mounted');
        this.resetImage();
        var image = this.$el.querySelector('.image-container > img');
        var identifier = this.identifier;
        var verbose = this.verbose;
        image.onload = function(){
            const request = {
                from:identifier,
                w:this.naturalWidth,
                h:this.naturalHeight
            };
            if(verbose)
                console.log('Emitting updateImageDimensions', request);
            eventHub.$emit('updateImageDimensions', request);
        };
    },
    updated: function(){
        if(this.verbose)
            console.log('Editor ',this.identifier,' updated');
    },
    watch: {
        newImageInfo:{
            handler: function(val, oldVal){

                this.edited = this.imageChanged;
                /*
                 TODO Fix this
                 var identifier = this.identifier;
                 var verbose = this.verbose;
                 const changeFunc = function(){
                 const request = {
                 from:identifier
                 };
                 if(verbose)
                 console.log('Emitting changed', request);
                 eventHub.$emit('changed', request);
                 };
                 debounce(
                 changeFunc,
                 500,
                 this.identifier+'_image_editing_debounce'
                 );
                 */
            },
            deep:true
        },
        image:{
            handler: function(val, oldVal){
                if(this.verbose)
                    console.log('Image changed!');
                this.resetImage();
            },
            deep:true
        }
    }
});