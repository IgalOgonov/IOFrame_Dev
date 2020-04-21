const windowSize = {
    data(){
        return{
            mode:'desktop',
            windowWidth: 0
        }
    },
    mounted(){
        this.$nextTick(() => {
            window.addEventListener('resize', () => {
                this.windowWidth = window.innerWidth
            });
        });
        this.windowWidth = window.innerWidth;
    },
    watch:{
        windowWidth(newWidth) {
            if(newWidth>1450){
                //for cart component only
                if(this.mode!=='desktop')
                    this.mode = 'desktop';
            }
            else if(newWidth>1250){
                if(this.mode!=='small-desktop')
                    this.mode = 'small-desktop';
            }
            else if(newWidth>1150){
                if(this.mode!=='huge-tablet')
                    this.mode = 'huge-tablet';
            }
            else if(newWidth>1000){
                if(this.mode!=='tablet')
                    this.mode = 'tablet';
            }
            else if(newWidth>800){
                if(this.mode!=='small-tablet')
                    this.mode = 'small-tablet';
            }
            else if(newWidth>600){
                if(this.mode!=='big-phone')
                    this.mode = 'big-phone';
            }
            else{
                if(this.mode!=='small-phone')
                    this.mode = 'small-phone';
            }
        }
    },
};
