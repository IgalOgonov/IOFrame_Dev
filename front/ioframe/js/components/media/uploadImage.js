if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('media-uploader', {
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
        //The current url which is viewed
        url: {
            type: String,
            default: ''
        }
    },
    data: function(){
        return {
            newImageInfo:{
                name:'',
                alt:'',
                caption:'',
                quality:100
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
            galleriesInitiated: false
        }
    },
    template: '\
        <div class="image-uploader">\
            <div class="image-container">\
                <img class="upload-preview" :src="imageURL(\'general/upload-image.png\')">\
                <input class="upload-address" name="upload" type="file" style="display:none">\
            </div>\
            <div class="info-container">\
                <div class="properties">\
                    <label for="name" v-text="\'Name\'"></label>\
                    <input name="name" class="name property" type="text" v-model:value="newImageInfo.name" placeholder="Image name">\
                    <label for="alt" v-text="\'ALT Tag\'"></label>\
                    <input name="alt" class="alt property" type="text" v-model:value="newImageInfo.alt" placeholder="Image ALT">\
                    <label for="description" v-text="\'Description\'"></label>\
                    <textarea name="description" class="description property" v-model:value="newImageInfo.caption" placeholder="Image caption"></textarea>\
                </div>\
                <div class="properties">\
                    <label for="quality" v-text="\'Quality %\'"></label>\
                    <input name="quality" class="quality property" type="number" min="1" max="100" v-model:value="newImageInfo.quality">\
                    <label for="size" v-text="\'Size\'"></label>\
                    <div name="size"" class="size property"  v-text="uploadedInfo.size"></div>\
                    <label for="dimensions" v-text="\'Dimensions (W x H)\'"></label>\
                    <div name="dimensions" class="dimensions property"  v-text="uploadedInfo.W + \' x \' + uploadedInfo.H"></div>\
                </div>\
                <div class="galleries-container">\
                </div>\
            </div>\
            <div class="operations" v-if="uploaded">\
                <button class="update positive" @click="uploadImage"">\
                    <div v-text="\'Upload\'"></div>\
                    <img :src="imageURL(\'icons/confirm-icon.svg\')">\
                </button>\
                <button class="reset cancel" @click="resetImage">\
                    <div v-text="\'Reset\'"></div>\
                    <img :src="imageURL(\'icons/cancel-icon.svg\')">\
                </button>\
            </div>\
        </div>\
        ',
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
            this.uploadedInfo.size = this.renderSize(file.size);
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

            this.newImageInfo = {
                name:'',
                    alt:'',
                    caption:'',
                    quality:100
            };
            //Info of the uploaded image
            this.uploadedInfo = {
                size:0,
                    W:0,
                    H:0
            };
            this.uploaded = false;
            const image = this.$el.querySelector('.image-uploader .upload-preview');
            image.onload = function(){};
            image.src = this.imageURL('back/upload-image.png');
        },
        //Happens when the user image was uploaded
        imageUploaded: function(){
            if(this.verbose)
                console.log('image uploaded!');
            this.resetImage();
            alertLog('Image Uploaded','success',this.$el);
        },
        //Uploads the image to the server
        uploadImage: function(){
            //Data to be sent
            var data = new FormData();
            data.append('action', 'uploadImages');
            if(this.url !== '')
                data.append('address', this.url);
            data.append('imageQualityPercentage', this.newImageInfo.quality);
            //TODO Let the user choose a gallery
            let imageInfo = {};
            if(this.newImageInfo.alt !== '')
                imageInfo.alt = this.newImageInfo.alt;
            if(this.newImageInfo.caption !== '')
                imageInfo.caption = this.newImageInfo.caption;
            if(this.newImageInfo.name !== '')
                imageInfo.name = this.newImageInfo.name;
            data.append('items', JSON.stringify(
                {
                    upload:imageInfo
                }
            ));
            const file = this.$el.querySelector('.image-uploader .upload-address').files[0];
            data.append('upload', file);
            if(this.test)
                data.append('req', 'test');


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
                                console.log('Emitting imageUploadedToServer', request);
                            eventHub.$emit('imageUploadedToServer', request);
                        })
                        .catch(function (error) {
                            alertLog('Upload failed! '+error,'error',thisElement);
                        });
                },
                function(reject){
                    alertLog('CSRF token expired. Please refresh the page to submit the form.','error',thisElement);
                }
            );
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
        eventHub.$on('imageUploadedToBrowser',this.updateImageDetailsWhenLoaded);
        eventHub.$on('imageUploadedToServer',this.imageUploaded);
        eventHub.$on('imageInitiated',this.updateImageDetails);
    }
});