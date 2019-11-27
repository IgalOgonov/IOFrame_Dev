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
            if(newWidth>1100){
                if(this.mode!=='desktop')
                    this.mode = 'desktop';
            }
            if(newWidth>1600){
                //for cart component only
                if(this.mode!=='cart-desktop')
                    this.mode = 'cart-desktop';
            }
            else if(newWidth>787){
                if(this.mode!=='tablet')
                    this.mode = 'tablet';
            }
            else if(newWidth>500){
                if(this.mode!=='mobile2')
                    this.mode = 'mobile2';
            }
            else{
                if(this.mode!=='mobile1')
                    this.mode = 'mobile1';
            }
        }
    },
};
