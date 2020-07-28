if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('media-uploader', {
    mixins:[eventHubManager,IOFrameCommons,sourceURL],
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
        //Type
        type: {
            type: String,
            default: 'local' //other possibility is 'remote'
        },
        //The current url which is viewed
        url: {
            type: String,
            default: ''
        }
    },
    data: function(){
        return {
            languages: JSON.parse(JSON.stringify(document.languages)),
            newImageInfo:{
                identifier:this.randomIdentifier(),
                link: '',
                name:'',
                alt:'',
                caption:'',
                quality:100
            },
            expectedMeta:{
                name:{
                    text:'Name',
                    placeholder:'Image name',
                    type:'input'
                },
                alt:{
                    text:'Alt',
                    placeholder:'Image ALT',
                    type:'input'
                },
                caption:{
                    text:'Caption',
                    placeholder:'Image description',
                    type:'textarea'
                },
            },
            //Info of the uploaded image
            uploadedInfo:{
                size:0,
                W:0,
                H:0
            },
            uploaded:false,
            //Galleries the image belongs to
            galleries: [],
            //Whether the galleries have been initiated
            galleriesInitiated: false,
            //Whether we are uploading to the DB or posting a link
            remoteType: 'db' //can be 'db' or 'link'
        }
    },
    template: `
        <div class="image-uploader">
            <button
            v-if="type !== 'local'"
            class="remote-type positive-3"
            @click.prevent="toggleType()"
            v-text="'Toggle Media Type - Current type is '+(remoteType === 'db'? 'Database' : 'Link')"
             ></button>
            <div :style="remoteType === 'link' ? 'display:none' : ''" class="image-container">
                <img class="upload-preview" :src="imageURL('general/upload-image.png')">
                <input class="upload-address" name="upload" type="file" style="display:none">
            </div>
            <div :style="remoteType !== 'link' ? 'display:none' : ''" class="link-container properties">
                    <label for="link" v-text="'Image Link'"></label>
                    <textarea name="link" class="link property" type="string" v-model:value="newImageInfo.link"></textarea>
                    <img class="link-preview" :src="newImageInfo.link">
            </div>
            <div class="info-container">
                <div class="properties">
                    <label v-if="type === 'remote' && remoteType === 'db'" for="identifier" v-text="">
                        <div v-text="'Item Identifier'"></div>
                    <input name="identifier" class="identifier property" type="text" v-model:value="newImageInfo.identifier" placeholder="Image identifier">
                    </label>

                    <label v-for="(itemArr, item) in expectedMeta"
                    >
                        <div v-text="itemArr.text"></div>
                        <input
                        v-if="itemArr.type === 'input'"
                        :name="item"
                        class="property"
                        :class="[item]"
                        type="text"
                        v-model:value="newImageInfo[item]"
                        :placeholder="itemArr.placeholder">

                        <textarea
                        v-if="itemArr.type === 'textarea'"
                        :name="item"
                        class="property"
                        :class="[item]"
                        v-model:value="newImageInfo[item]"
                        :placeholder="itemArr.placeholder"
                        ></textarea>
                    </label>

                </div>
                <div class="properties" v-if="type !== 'remote' || remoteType === 'db'">
                    <label for="quality" v-text="'Quality %'"></label>
                    <input name="quality" class="quality property" type="number" min="1" max="100" v-model:value="newImageInfo.quality">
                    <label for="size" v-text="'Size'"></label>
                    <div name="size"" class="size property"  v-text="uploadedInfo.size"></div>
                    <label for="dimensions" v-text="'Dimensions (W x H)'"></label>
                    <div name="dimensions" class="dimensions property"  v-text="uploadedInfo.W + ' x ' + uploadedInfo.H"></div>
                </div>
                <div class="galleries-container">
                </div>
            </div>
            <div class="operations" v-if="uploaded && (type !== 'remote' || remoteType === 'db') || (type === 'remote' && remoteType === 'link'  && newImageInfo.link)"">
                <button class="update positive-1" @click.prevent="uploadImage"">
                    <div v-text="'Upload'"></div>
                    <img :src="imageURL('icons/confirm-icon.svg')">
                </button>
                <button class="reset cancel-1" @click.prevent="resetImage">
                    <div v-text="'Reset'"></div>
                    <img :src="imageURL('icons/cancel-icon.svg')">
                </button>
            </div>
        </div>
        `,
    methods: {
        //Gets the relative URL for an image
        imageURL: function(image){
            return this.sourceURL() + '/img/'+image;
        },
        //Emits an event when the user-uploaded image was loaded
        updateImageDetailsWhenLoaded: function(){
            const image = this.$el.querySelector('.image-uploader .upload-preview');
            var identifier = this.identifier;
            image.onload = function(){
                const request = {
                    from:identifier
                };
                eventHub.$emit('imageInitiated', request);
            };
        },
        //Updates image details after client side upload
        updateImageDetails: function(){
            const image = this.$el.querySelector('.image-uploader .upload-preview');
            const file = this.$el.querySelector('.image-uploader .upload-address').files[0];
            this.uploadedInfo.W = image.naturalWidth;
            this.uploadedInfo.H = image.naturalHeight;
            this.uploadedInfo.size = this.renderSize( file? file.size : 0);
            this.uploaded = true;
        },
        //Returns a "pretty" string from size in bytes
        renderSize: function(size){
            //Render a "pretty" size
            size = "" + size;
            let result = [];
            for(let i = size.length-1; i>=0; i--){
                result.push(result,size[i]);
                if( ( (size.length-1 - i) % 3 === 2 ) && i!==0)
                    result.push(result,',');
            }
            const prettySize = result.reverse().join('');

            //Calculate GB/KB/Etc
            let magnitude = 0;
            let bytes = size;
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
        //Resets client side
        resetImage: function(){
            if(this.verbose)
                console.log('Resetting image..');

            for(let i in this.expectedMeta){
                this.newImageInfo[i] = '';
            }
            this.newImageInfo['quality'] = 100;
            this.newImageInfo['link'] = '';
            this.newImageInfo['identifier'] = this.randomIdentifier();

            //Info of the uploaded image
            this.uploadedInfo = {
                size:0,
                    W:0,
                    H:0
            };

            this.uploaded = false;
            const image = this.$el.querySelector('.image-uploader .upload-preview');
            image.onload = function(){};
            image.src = this.imageURL('general/upload-image.png');
        },
        //Happens when the user image was uploaded
        imageUploaded: function(response){
            if(this.verbose)
                console.log('imageUploaded even with response ',response);

            if(!response.from || response.from !== this.identifier)
                return;

            response = response.content;

            if(typeof response !== 'object'){
                switch(response){
                    case 'INPUT_VALIDATION_FAILURE':
                        alertLog('Something wrong with the inputs!','error',this.$el);
                        break;
                    case 'AUTHENTICATION_FAILURE':
                        alertLog('You are not authorized to perform the action! Check to see if you are still logged in.','error',this.$el);
                        break;
                    case 'WRONG_CSRF_TOKEN':
                        alertLog('CSRF Token incorrect. Try refreshing, and if this continues, contact the system administrator.','error',this.$el);
                        break;
                    case 'SECURITY_FAILURE':
                        alertLog('Security related error, generally related to your account\'s behaviour. Contact the system administrator.','error',this.$el);
                        break;
                    default:
                        alertLog('Unknown response '+response,'error',this.$el);
                }
            }
            else{
                //There is only one upload
                for(let uploadName in response){
                    if(this.type === 'local'){
                        switch(response[uploadName]){
                            case -1:
                            case 0:
                            case 104:
                                alertLog('Server error!','error',this.$el);
                                break;
                            case 1:
                                alertLog('Image of incorrect size/format!','error',this.$el);
                                break;
                            case 2:
                                alertLog('Could not move image to requested path!','error',this.$el);
                                break;
                            case 3:
                                alertLog('Could not overwrite existing image!','error',this.$el);
                                break;
                            case 4:
                                alertLog('Could not upload a file because safeMode is true and the file type isn\'t supported!','error',this.$el);
                                break;
                            case 105:
                                alertLog('Image upload would work, but requested gallery does not exist!','error',this.$el);
                                break;
                            default:
                                alertLog('Image successfully uploaded <a href="'+document.rootURI+response[uploadName]+'">here</a>','success',this.$el);
                                this.resetImage();
                        }
                    }
                    else{
                        //DB
                        if(this.remoteType === 'db'){
                            switch(response[uploadName]){
                                case -1:
                                case 2:
                                case 104:
                                    alertLog('Server error!','error',this.$el);
                                    break;
                                case 1:
                                    alertLog('Image of incorrect size/format!','error',this.$el);
                                    break;
                                case 3:
                                    alertLog('Could not overwrite existing image!','error',this.$el);
                                    break;
                                case 4:
                                    alertLog('Could not upload a file because safeMode is true and the file type isn\'t supported!','error',this.$el);
                                    break;
                                case 0:
                                    alertLog('Image successfully uploaded <a href="'+document.rootURI+'api/media?action=getDBMedia&address='+this.newImageInfo.identifier+'">here</a>','success',this.$el);
                                    this.resetImage();
                                    break;
                                case 105:
                                    alertLog('Image upload would work, but requested gallery does not exist!','error',this.$el);
                                    break;
                                default:
                                    alertLog('Unknown response '+response[uploadName],'error',this.$el);
                            }
                        }
                        //Link
                        else{
                            switch(response[uploadName]){
                                case -1:
                                case 0:
                                case 1:
                                case 2:
                                case 4:
                                case 104:
                                    alertLog('Server error!','error',this.$el);
                                    break;
                                case 3:
                                    alertLog('Could not create new link, because it already exists! Edit the existing one to change things.','info',this.$el);
                                    break;
                                    this.resetImage();
                                    break;
                                case 105:
                                    alertLog('Image upload would work, but requested gallery does not exist!','error',this.$el);
                                    break;
                                default:
                                    alertLog('Image successfully uploaded <a href="'+response[uploadName]+'">here</a>','success',this.$el);
                                    this.resetImage();
                            }
                        }
                    }
                }
            }

        },
        //Uploads the image to the server
        uploadImage: function(){
            //Data to be sent
            var data = new FormData();
            data.append('action', 'uploadMedia');
            if(this.type === 'local'){
                if(this.url !== '')
                    data.append('address', this.url);
                data.append('imageQualityPercentage', this.newImageInfo.quality);
                let imageInfo = {};

                for(let i in this.expectedMeta){
                    if(this.newImageInfo[i] !== '')
                        imageInfo[i] = this.newImageInfo[i];
                }

                data.append('items', JSON.stringify(
                    {
                        upload:imageInfo
                    }
                ));
                const file = this.$el.querySelector('.image-uploader .upload-address').files[0];
                data.append('upload', file);
            }
            else{
                //DB
                if(this.remoteType === 'db'){
                    data.append('type', 'db');

                    //Validate identifier
                    if(!this.newImageInfo.identifier.match(/^[a-zA-Z][\w \/]{0,63}$/)){
                        alertLog('Invalid image identifier 1-64 valid laetters, numbers, underscores, the symbol "/" or spaces!','warning',this.$el);
                        return;
                    }

                    data.append('imageQualityPercentage', this.newImageInfo.quality);
                    let imageInfo = {};

                    for(let i in this.expectedMeta){
                        if(this.newImageInfo[i] !== '')
                            imageInfo[i] = this.newImageInfo[i];
                    }
                    let payload = { };
                    payload[this.newImageInfo.identifier] = imageInfo;
                    data.append('items', JSON.stringify(payload));
                    const file = this.$el.querySelector('.image-uploader .upload-address').files[0];
                    data.append(this.newImageInfo.identifier, file);
                }
                //Link
                else{
                    data.append('type', 'link');

                    let imageInfo = {};
                    //Validate link
                    if(!this.newImageInfo.link.match(/^(?:(?:https?|ftp):\/\/)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/\S*)?$/)){
                        alertLog('Invalid link!','warning',this.$el);
                        return;
                    }
                    imageInfo.filename = this.newImageInfo.link;

                    for(let i in this.expectedMeta){
                        if(this.newImageInfo[i] !== '')
                            imageInfo[i] = this.newImageInfo[i];
                    }
                    let payload = { };
                    payload['link'] = imageInfo;
                    data.append('items', JSON.stringify(payload));
                }
            }


            //TODO Let the user choose a gallery
            if(this.test)
                data.append('req', 'test');

            this.apiRequest(
                data,
                "api/media",
                'imageUploadedToServer',
                {
                    'verbose': this.verbose,
                    'parseJSON':true,
                    'identifier':this.identifier
                }
            );
        },
        //Creates a random identifier for the image (db upload)
        randomIdentifier: function () {
            var result = '';
            var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            var charactersLength = characters.length;
            result += characters.charAt(Math.floor(Math.random() * (charactersLength - 10)));
            for (var i = 0; i < 63; i++) {
                result += characters.charAt(Math.floor(Math.random() * charactersLength));
            }
            return result;
        },
        //Toggles remote type
        toggleType: function(){
            this.remoteType=(this.remoteType === 'db'? 'link' : 'db');
        }
    },
    computed:{
    },
    mounted: function(){
        if(this.verbose){
            console.log('Uploader ',this.identifier,' mounted!');
        }
        var identifier = this.identifier;
        bindImagePreview(
            this.$el.querySelector('.image-uploader .upload-address'),
            this.$el.querySelector('.image-uploader .upload-preview'),
            {
                callback:function(){
                    const request = {
                        from:identifier
                    };
                    eventHub.$emit('imageUploadedToBrowser', request);
                },
                bindClick:this.$el.querySelector('.image-uploader .image-container')
            }
        );
    },
    created: function(){
        this.registerHub(eventHub);
        this.registerEvent('imageUploadedToBrowser',this.updateImageDetailsWhenLoaded);
        this.registerEvent('imageUploadedToServer',this.imageUploaded);
        this.registerEvent('imageInitiated',this.updateImageDetails);
        //Add all right properties depending on languages
        for(let i in this.languages){
            let lang = this.languages[i];
            Vue.set(this.newImageInfo,lang+'_caption','');
            Vue.set(this.newImageInfo,lang+'_name','');
            Vue.set(this.expectedMeta,lang+'_name',{
                text:'Name ['+lang+']',
                placeholder:'Image '+lang+' name',
                type:'input'
            });
            Vue.set(this.expectedMeta,lang+'_caption',{
                text:'Caption ['+lang+']',
                placeholder:'Image '+lang+' caption',
                type:'textarea'
            });
        }
    }
});