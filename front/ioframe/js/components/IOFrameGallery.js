if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('ioframe-gallery', {
    props:{
        //Array of URLs - images to display
        images: {
            type: Array,
            default: function(){
                return [
                /* array of objects of the form:
                     {
                        url: image url,
                        alt: alt text
                        //TODO add captions, and more
                     }
                 */
                ];
            }
        },
        //Instead of changing "selected", always keeps it as the middle member of the gallery (rounded up) and rotates the
        //gallery to match it
        centerGallery:{
            type: Boolean,
            default: false
        },
        //Whether the preview div should be displayed
        hasPreview:{
            type: Boolean,
            default: false
        },
        //TODO Whether to go into full-screen display mode when one of the images is clicked
        fullScreenOnClick:{
            type: Boolean,
            default: false
        },
        //If this is set, all images will link to this URL while the assets are loading.
        loadingImageUrl:{
            type: String,
            default: ''
        },
        //If this is set, all images that are missing will link to this.
        missingImageUrl:{
            type: String,
            default: ''
        },
        //URLs to images of left/right buttons. If not provided, buttons will be styled or not styled according to styledNavigationButtons
        navigationButtons:{
            type: Object,
            default:  function(){
                return {
                    prev: '',
                    next: ''
                };
            }
        },
        //TODO If set to false, navigation buttons will be empty and not styled, left for any external CSS to style them
        styledNavigationButtons:{
            type: Boolean,
            default: true
        },
        //If set to false, will not allow looping
        infiniteLoop:{
            type: Boolean,
            default: true
        },
        /** When emitting events, if identifier is '', just the resulting object would be emitted.
         *  If an identifier is set, the emitted object would be of the form {from:this.identifier,content:<whatever would be emitted without identifier>}
         *  This is useful for when multiple galleries might exist on one page.**/
        identifier:{
            type: String,
            default: ''
        },
        //test mode will currently not do much - reserved for future use
        test:{
            type: Boolean,
            default: false
        },
        //Verbose mode will log various runtime debug messages into the console
        verbose:{
            type: Boolean,
            default: true
        },
    },
    data: function(){
        return {
            //Offset (0 to gallery end, then it just loops)
            offset: 0,
            //Currently selected item
            selected: 0,
            //Array of image objects
            gallery: [
                /* Objects of the form:
                *  {
                *       url: image url (taken from the prop)
                *       loaded: false (whether the image was successfully loaded)
                *  }
                * */
            ],
            finishedMounting: false
        }
    },
    created: function(){
    },
    beforeMount: function(){
        this.constructGallery();
    },
    mounted: function(){
        this.finishedMounting = true;
    },
    methods:{
        //Constructs the gallery from given images
        constructGallery: function(){
            /*//Has map to see which images exist
            let imagesHashMap = {};
            let galleryHashMap = {};
            for(let index in this.images){
                imagesHashMap[this.images[index].url] = true;
            }
            //Check what exists in gallery that isn't in images
            for(let index in this.gallery){
                galleryHashMap[this.gallery[index].url] = true;
                //If an image no longer exists in the gallery, it needs to be removed
                if(imagesHashMap[this.gallery[index].url] !== true)
                    delete this.gallery;
            }
            //Check what exists in images that isn't in gallery
            for(let index in this.images){
                //Add anything that wasn't in the gallery
                if(galleryHashMap[this.images[index].url] !== true)
                    this.gallery.push({url:this.images[index].url,loaded:false});
            }

            this.gallery.filter(x => x);*/

            this.gallery = [];
            for(let index in this.images){
                this.gallery.push({url:this.images[index].url,alt:this.images[index].alt,loaded:false});
            }

            //Remember currently selected
            if(this.centerGallery)
                this.selected =  Math.ceil(this.gallery.length / 2) -1;

            this.initImages(250,10);
        },
        /*Loads all images (if loadingImageURL is provided), and fixes all missing images (if missingImageURL is provided)
        * delay and count are used for recursion - count tries, with delay in MS between each try. This is due to render timing*/
        initImages: function(delay, count){
            if(!this.finishedMounting && count > 0){
                setTimeout(this.initImages,delay,delay,(count -1));
                return;
            }

            //Iterate over each member
            for(let index in this.gallery){
                let hasPreview = this.hasPreview;
                //No need to do anything with loaded images
                if(this.gallery[index].loaded)
                    continue;
                let preview;
                let image = this.$el.querySelector('.gallery-member-'+index);
                if(hasPreview)
                    preview = this.$el.querySelector('.gallery-member-preview-'+index);

                //This means we might be too early
                if(image === null){
                    if(count > 0)
                        setTimeout(this.initImages,delay,delay,(count -1));
                    return;
                }
                //An image is invalid if it failed to load, or if the missing icon was loaded from earlier but the actual image
                //address isn't the missing icon
                let valid = (
                    image.naturalHeight !== 0 &&
                    !(image.attributes.src === this.missingImageUrl && this.gallery[index].url !== this.missingImageUrl)
                );
                if(!valid && this.missingImageUrl !== ''){
                    this.gallery[index].url = this.missingImageUrl;
                    this.gallery[index].loaded = true;
                }
                //We could still have a leftover valid image from earlier
                else{
                    let context = this;
                    let placeholder;
                    let previewPlaceholder;
                    placeholder = this.$el.querySelector('.gallery-member-placeholder-'+index);
                    if(hasPreview)
                        previewPlaceholder = this.$el.querySelector('.gallery-member-preview-placeholder-'+index);
                    let hasMissingUrl = this.missingImageUrl;

                    //Image starts loading
                    image.onloadstart = function(){
                        //Make the placeholder visible and move the image away
                        if(context.loadingImageUrl !== ''){
                            image.style.height = '0';
                            image.style.width = '0';
                            image.style.opacity = '0';
                            placeholder.style.display = 'initial';
                            if(hasPreview){
                                preview.style.position = 'fixed!important';
                                preview.style.left = '100vw!important';
                                previewPlaceholder.style.display = 'initial';
                            }
                        }
                    };

                    //Image finished loading
                    image.onloadend = function(){
                        //Image was loaded
                        context.gallery[index].loaded = true;

                        //Remove placeholder, return image to normal position
                        if(context.loadingImageUrl !== ''){
                            image.style = {};
                            placeholder.style.display = 'none';
                            if(hasPreview){
                                preview.style = {};
                                previewPlaceholder.style.display = 'none';
                            }
                        }
                        //If the image isn't valid, and missingImageUrl is set, set the image to that Url
                        let valid = (
                            image.naturalHeight !== 0 &&
                            !(image.attributes.src === context.missingImageUrl && context.gallery[index].url !== context.missingImageUrl)
                        );
                        if(!valid && context.missingImageUrl !== '')
                            context.gallery[index].url = context.missingImageUrl;
                    };
                }
            }
        },
        //Moves selection to the next/previous image
        moveSelection: function(next = true){
            if(!this.centerGallery){
                if(this.infiniteLoop)
                    this.selected = (next? (this.selected + 1)%this.gallery.length : (this.selected != 0) ? this.selected - 1 : this.gallery.length - 1);
                else
                    this.selected = Math.max(0, Math.min(this.gallery.length - 1, this.selected + (next? 1 : -1)));
                let request = this.identifier !== ''? {from:this.identifier,content:this.selected}: this.selected ;
                eventHub.$emit('selectInGallery',request);
                if(this.verbose)
                    console.log('Emitting selectInGallery',request);
            }
            else{
                this.rotateGallery(next? 1 : -1);
            }
        },
        //Selects an image
        select: function(index){
            if(!this.centerGallery){
                this.selected = Math.max(0, Math.min(this.gallery.length - 1, index));
                let request = this.identifier !== ''? {from:this.identifier,content:this.selected}: this.selected ;
                eventHub.$emit('selectInGallery',request);
                if(this.verbose)
                    console.log('Emitting selectInGallery',request);
            }
            else{
                let requestedOffset = index - this.selected;
                this.rotateGallery(requestedOffset);
            }
        },
        //Rotates gallery
        rotateGallery: function(offset){
            offset = offset - 0;
            let tempGallery = [];
            let galleryArrLength = this.gallery.length;
            for(let i in this.gallery){
                i = i - 0;
                console.log(i, offset);
                let newIndex = i+offset;
                if(newIndex > galleryArrLength - 1)
                    newIndex -= galleryArrLength;
                else if(newIndex < 0)
                    newIndex += galleryArrLength;

                tempGallery.push(JSON.parse(JSON.stringify(this.gallery[newIndex])));
                console.log(JSON.parse(JSON.stringify(this.gallery[newIndex])),newIndex);
            }
            for(let j in tempGallery){
                for(let property in tempGallery[j]){
                    this.gallery[j][property] = tempGallery[j][property];
                }
            }
        }
    },
    computed:{
        //whether navigation button URLs were provided or not
        navigationButtonsProvided: function(){
            return this.navigationButtons.left && this.navigationButtons.right;
        }
    },
    watch: {
        images:{
            handler: function(val, oldVal){
                if(this.verbose)
                    console.log('Images changed!');
                this.constructGallery();
            },
            deep:true
        }
    },
    template: `
        <div class="ioframe-gallery">

            <div v-if="hasPreview" class="gallery-preview">

                <div v-for="(item, index) in gallery" class="preview-container" :class="[{selected:selected === index}, 'preview-'+index]">
                    <img v-if="loadingImageUrl" :src="loadingImageUrl" class="gallery-member-preview" :class="'gallery-member-preview-placeholder-'+index" style="display:none;">
                    <img :src="item.url" :alt="item.alt? item.alt : ''" class="gallery-member-preview" :class="'gallery-member-preview-'+index">
                </div>

            </div>

            <div class="slider">

                <button class="prev" @click="moveSelection(false)">
                    <img v-if="navigationButtons.prev" :src="navigationButtons.prev">
                    <div v-else="">&#60</div>
                </button>

                <div class="gallery-container">

                    <div v-for="(item, index) in gallery" class="image-container gallery" :class="[{selected:selected === index}, 'image-'+index]" @click="select(index)">
                        <img v-if="loadingImageUrl" :src="loadingImageUrl" class="gallery-member" :class="'gallery-member-placeholder-'+index" style="display:none;">
                        <img :src="item.url" :alt="item.alt? item.alt : ''" class="gallery-member" :class="'gallery-member-'+index">
                    </div>

                </div>

                <button class="next" @click="moveSelection(true)">
                    <img v-if="navigationButtons.next" :src="navigationButtons.next">
                    <div v-else="">&#62</div>
                </button>

            </div>

        </div>
    `
});