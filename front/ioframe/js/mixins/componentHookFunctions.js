/** In the following few lines, specific code is added to each of the standard vue hooks:
 *  beforeMount, mounted, beforeUpdate, updated, beforeDestroy, destroyed
 *  It makes it so that if a module/component has in his data the following structure:
 *  '_functions':{
     *     beforeMount: function(){
     *         ...
     *     },
     *     mounted: function(){
     *         ...
     *     }
     *  }
 *  those functions will automatically be executed at the relevant part of the lifecycle.
 *  Mainly useful for parents that want to pass functions to their children via the predefined '_functions' prop.
 *  Note that the context of the functions is the child component, so you can modify its data, or select its element with "this" at will.
 *
 *  Note that created and beforeCreate are not included, since this mixin's prop simply wont be loaded that early
 * */
const componentHookFunctions = {
    props:{
        '_functions':{
            type: Object,
            default: function(){
                return {};
            }
        }
    },
    beforeMount:function(){
        if(this['_functions']['beforeMount'] && typeof this['_functions']['beforeMount'] === 'function')
            this['_functions']['beforeMount']();
    },
    mounted:function(){
        if(this['_functions']['mounted'] && typeof this['_functions']['mounted'] === 'function')
            this['_functions']['mounted']();
    },
    beforeUpdate:function(){
        if(this['_functions']['beforeUpdate'] && typeof this['_functions']['beforeUpdate'] === 'function')
            this['_functions']['beforeUpdate']();
    },
    updated:function(){
        if(this['_functions']['updated'] && typeof this['_functions']['updated'] === 'function')
            this['_functions']['updated']();
    },
    beforeDestroy:function(){
        if(this['_functions']['beforeDestroy'] && typeof this['_functions']['beforeDestroy'] === 'function')
            this['_functions']['beforeDestroy']();
    },
    destroyed:function(){
        if(this['_functions']['destroyed'] && typeof this['_functions']['destroyed'] === 'function')
            this['_functions']['destroyed']();
    }
};