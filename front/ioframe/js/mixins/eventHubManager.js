/** Manages event hubs
 * This class helps register, and clean up events for components.
 * Without using this mixin, event registration will happen at each and every component creation, and the
 * events will be executed as many times as a component was created.
 * Using this class helps clean up that mess.
 * The only restriction - this mixin assumes components are created and destroyed in a form of a stack - first in last out.
 * If similar components are created one after the other, but not destroyed in a similar order, this mixin will behave
 * incorrectly.
 * **/
const eventHubManager = {
    data: function(){
        return{
            events:[],
            eventHub:null
        }
    },
    created: function(){
        if(this.verbose)
            console.log('Event hub manager mixin added!');
    },
    methods: {
        //Registers an event hub to use
        registerHub: function(eventHub){
            this.eventHub = eventHub;
        },
        //Registers an event at the hub
        registerEvent: function(eventName, eventFunction){
            this.eventHub.$on(eventName,eventFunction);
            this.events.push(eventName);
            const identifier = this.identifier ? this.identifier+' - ' : '';
            if(this.verbose)
                console.log(identifier + eventName + ' registered to hub.');
        }
    },
    //Cleans up the hub
    destroyed: function(){
        for(let i = 0; i<this.events.length; i++){
            this.eventHub._events[this.events[i]].pop();
            if(this.eventHub._events[this.events[i]].length === 0)
                delete this.eventHub._events[this.events[i]];
        }
        const identifier = this.identifier ? this.identifier+' - ' : '';
        if(this.verbose)
            console.log(identifier+'events cleaned from hub.');
    }
};
