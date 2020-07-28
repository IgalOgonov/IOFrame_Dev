const windowSize = {
    data(){
        return{
            windowSize:{
                //An array of objects, sorted by item.width, that represents the window width levels corresponding to the modes
                levels: [
                    {
                        width:0,
                        mode:'small-phone'
                    },
                    {
                        width:600,
                        mode:'big-phone'
                    },
                    {
                        width:800,
                        mode:'small-tablet'
                    },
                    {
                        width:1000,
                        mode:'tablet-phone'
                    },
                    {
                        width:1200,
                        mode:'small-desktop'
                    },
                    {
                        width:1450,
                        mode:'desktop'
                    }
                ],
                mode:'',
                windowWidth: 0
            }
        }
    },
    mounted(){
        this.$nextTick(() => {
            window.addEventListener('resize', () => {
                this.windowSize.windowWidth = window.innerWidth
            });
        });
        this.windowSize.windowWidth = window.innerWidth;
    },
    watch:{
        'windowSize.windowWidth': function(newWidth) {
            for(let i in this.windowSize.levels){
                if(this.windowSize.levels[i+1] === undefined || newWidth < this.windowSize.levels[i].width){
                    this.windowSize.mode = this.windowSize.levels[i].mode;
                    return;
                }
            }
        }
    },
};
