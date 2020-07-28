const componentSize = {
    data(){
        return{
            componentSize:{
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
                width: 0,
                //Allows disabling this
                disable:false
            }
        }
    },
    mounted(){
        if(!this.componentSize.disable)
            this.$nextTick(() => {
                window.addEventListener('resize', () => {
                    this.componentSize.width = this.$el.offsetWidth ;
                });
            });
        this.componentSize.width = this.$el.offsetWidth ;
    },
    watch:{
        'componentSize.width': function(newWidth) {
            for(let i in this.componentSize.levels){
                if(this.componentSize.levels[i+1] === undefined || newWidth < this.componentSize.levels[i].width){
                    this.componentSize.mode = this.componentSize.levels[i].mode;
                    return;
                }
            }
        }
    },
};
