if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('user-registration', {
    props:{
        needsUsername:{
            type: Boolean,
            default: true
        },
        test:{
            type: Boolean,
            default: false
        },
        verbose:{
            type: Boolean,
            default: false
        },
    },
    data: function(){return {
        u:{
            val:'',
            class:''
        },
        p:{
            val:'',
            class:''
        },
        p2:{
            val:'',
            class:''
        },
        m:{
            val:'',
            class:''
        },
        req: 'real',
        resp: ''
    }
    },
    methods:{
        reg: function(){
            let errors = 0;
            let req = this.test? 'test' : 'real';
            var context = this;
            //output user inputs for testing
            if(this.verbose)
            console.log("Username:"+this.u.val+", password:"+ this.p.val+", email:"+this.m.val+", req:"+this.req);

            //validate username
            if(this.needsUsername){
                if( (this.u.val.length>16) ||(this.u.val.length<6) || (this.u.val.match(/\W/g)!=null) ){
                    this.u.class = "error";
                    errors++;
                }
                else
                    this.u.class = "success";

            }
            //validate password
            if( (this.p.val.length>64) ||(this.p.val.length<8) || (this.p.val.match(/(\s|<|>)/g)!=null)
                || (this.p.val.match(/[0-9]/g) == null) || (this.p.val.match(/[a-z]|[A-Z]/g) == null) ){
                this.p.class = "error";
                errors++;
            }
            else
                this.p.class = "success";

            //validate 2nd pass
            if(this.p.val!=this.p2.val || this.p2.val==undefined){
                this.p2.class = "error";
                errors++;
            }
            else
                this.p2.class = "success";

            //validate email
            if(this.m.val==undefined){
                this.m.class = "error";
                errors++;
            }
            else
                this.m.class = "success";

            //if no errors - send data
            if(errors<1){
                this.resp = "Posting...";
                //Data to be sent
                var data = new FormData();
                data.append('action', 'addUser');
                if(this.needsUsername)
                    data.append('u', this.u.val);
                data.append('m', this.m.val);
                data.append('p', context.p.val);
                data.append('req', req);
                let url=document.pathToRoot+"api\/users";
                //Request itself
                fetch(url, {
                    method: 'post',
                    body: data,
                    mode: 'cors'
                })
                .then(function (json) {
                    return json.text();
                })
                .then(function (data) {
                        let respType;
                        let response = xhr.responseText;
                        // success
                        if(context.verbose)
                            console.log("Posted: "+data+" to user API"+" ,Succeeded in getting response to post.");
                        context.resp = response;
                        /*This will display messages that the addUser page could return
                         *0 - success
                         *1 - failed - incorrect input - wrong or missing
                         *2 - failed - username already in use
                         *3 - failed - email already in use
                         *4 - failed - server error
                         *5 - failed - registration not allowed!
                         **/
                        switch(response){
                            case 'INPUT_VALIDATION_FAILURE':
                                respType='warning';
                                break;
                            case 'AUTHENTICATION_FAILURE':
                                respType='warning';
                                break;
                            case 'WRONG_CSRF_TOKEN':
                                respType='warning';
                                break;
                            case '0':
                                respType='success';
                                break;
                            case '1':
                                respType='warning';
                                if(context.needsUsername)
                                    context.u.class = "warning";
                                break;
                            case '2':
                                respType='warning';
                                context.m.class = "#fcf8e3";
                                break;
                            case '3':
                                respType='warning';
                                break;
                            default:
                                respType='warning';
                        }

                        //Use AlertLog to tell the user what the result was
                        //Can be implemented differently in different apps
                        eventHub.$emit('registrationResponse',{body:response,type:respType});
                })
                .catch(function (error) {
                    if(context.verbose)
                        console.log("Posted: "+data+"to user api"+" ,Failed in getting response to post.");
                    //Can be implemented differently in different apps
                    eventHub.$emit('registrationResponse',{body:'Failed to reach API, cannot log in. Error text '+xhr.responseText,type:'danger'});
                    console.log('Error: ' + error); // An error occurred during the request.
                });
            };
        }
    },
    template: '<span class="user-registration">\
\
    <form novalidate>\
\
    <input v-if="needsUsername" :class="[u.class]" type="text" id="u_reg" name="u" placeholder="username" v-model="u.val" required>\
    <a v-if="needsUsername" href="#"  id="u_reg-tooltip">?</a><br>\
    <input :class="[p.class]" type="password" id="p_reg" name="p" placeholder="password" v-model="p.val" required>\
    <a href="#"  id="p_reg-tooltip">?</a><br>\
    <input :class="[p2.class]" type="password" id="p2_reg" placeholder="repeat password" v-model="p2.val" required><br>\
    <input :class="[m.class]" type="email" id="m_reg" name="m" placeholder="mail" v-model="m.val" required><br>\
    <button @click.prevent="reg">Register</button>\
\
                </form>\
                </span>',
    mounted: function(){
        document.popupHandler = new ezPopup("pop-up-tooltip");
        document.popupHandler.initPopup('u_reg-tooltip','Must be 6-16 characters long, Must contain numbers and latters','');
        document.popupHandler.initPopup('p_reg-tooltip',"Must be 8-64 characters long<br> Must include latters and numbers<br>Can include special characters except '>' and '<'",'');
    }
});