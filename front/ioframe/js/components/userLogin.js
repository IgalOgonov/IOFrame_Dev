if(eventHub === undefined)
    var eventHub = new Vue();

Vue.component('user-login', {
    props:{
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
        m:{
            val:'',
            class:''
        },
        p:{
            val:'',
            class:''
        },
        rMe: true,
        resp: ''
    }
    },
    methods:{
        log: function(){
            let errors = 0;

            //output user inputs for testing
            if(this.verbose)
                console.log('Inputs are ' + "Email:"+this.m.val+", password:"+this.p.val);
            //validate email
            if(this.m.val==undefined || this.m.val==""){
                this.m.class = "error";
                errors++;
            }
            else
                this.m.class = "";

            //validate password
            if( (this.p.val.length>64) ||(this.p.val.length<8) || (this.p.val.match(/(\s|<|>)/g)!=null)
                || (this.p.val.match(/[0-9]/g) == null) || (this.p.val.match(/[a-z]|[A-Z]/g) == null) ){
                this.p.class = "warning";
                errors++;
            }
            else
                this.p.class = "";

            //If no errors, log in
            var context = this;
            if(errors<1){
                this.resp = "Logging in...";
                //Data to be sent

                updateCSRFToken().then(
                    function(token){
                        let req = context.test? 'test' : 'real';
                        var data = new FormData();
                        data.append('action', 'logUser');
                        data.append('m', context.m.val);
                        data.append('p', context.p.val);
                        data.append('log', 'in');
                        data.append('req', req);
                        data.append('CSRF_token', token);
                        if(context.rMe)
                            data.append('userID', localStorage.getItem('deviceID'));
                        //Api url
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
                                let response = data;
                                // success
                                if(context.verbose)
                                    console.log( "Posted: "+data+"to user API"+" ,Succeeded in getting response to post.");
                                context.resp = response;
                                /*This will display messages that the API could return
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
                                        //If we specifically don't want to be remembered - we wont be.
                                        if(context.rMe){
                                            localStorage.removeItem("sesID");
                                            localStorage.removeItem("sesIV");
                                        }
                                        //Remember to udate session info!
                                        if(!context.test)
                                            updateSesInfo(document.pathToRoot,{
                                                'sessionInfoUpdated': function(){
                                                    location.reload();
                                                }
                                            });
                                        break;
                                    case '1':
                                        respType='danger';
                                        break;
                                    case '2':
                                        respType='warning';
                                        break;
                                    case '3':
                                        respType='warning';
                                        break;
                                    //TODO Drop auto-login cached data if it exists
                                    default:
                                        let loginSuccess = false;
                                        if(response.length >= 32){
                                            //This means we got both sesID and IV
                                            if(IsJsonString(response) ){
                                                let resp = JSON.parse(response);
                                                if(resp['sesID'].length == 32){
                                                    localStorage.setItem("sesID",resp['sesID']);
                                                    loginSuccess = true;
                                                }
                                                if(resp['iv'].length == 32){
                                                    localStorage.setItem("sesIV",resp['iv']);
                                                    loginSuccess = true;
                                                }
                                            }
                                            //This means we just got a new ID
                                            else{
                                                if(response.length == 32){
                                                    localStorage.setItem("sesID",response);
                                                    loginSuccess = true;
                                                }
                                            }
                                            if(loginSuccess){
                                                context.resp = '0';
                                                respType='success';
                                                //Remember to udate session info!
                                                updateSesInfo(document.pathToRoot,{
                                                    'sessionInfoUpdated': function(){
                                                        location.reload();
                                                    }
                                                });
                                            }
                                        }
                                        //Means this is something else...
                                        if(!loginSuccess){
                                            context.resp = 'Illegal response: '+response;
                                            respType='danger';
                                        }
                                }

                                //Use AlertLog to tell the user what the resault was
                                //Can be implemented differently in different apps
                                eventHub.$emit('loginResponse',{body:context.resp,type:respType});
                                context.m.class = respType;
                                context.p.class = respType;
                            })
                            .catch(function (error) {
                                if(context.verbose)
                                    console.log("Posted: "+data+"to user api"+" ,Failed in getting response to post.");
                                //Can be implemented differently in different apps
                                eventHub.$emit('loginResponse',{body:'Failed to reach API, cannot log in. Error text '+xhr.responseText,type:'danger'});
                                console.log('Error: ' + error); // An error occurred during the request.
                            });
                    },
                    function(reject){
                        console.log(reject);
                        eventHub.$emit('loginResponse',{body:'CSRF token expired. Please refresh the page to submit the form.',type:'danger'});
                    }
                );
            }
        }
    },
    template: '<span class="user-login">\
    <form novalidate>\
    \
    \
    <input :class="[m.class]" type="email" id="m_log" name="m" placeholder="email" v-model="m.val" required>\
        <input :class="[p.class]" type="password" id="p_log" name="p" placeholder="password" v-model="p.val" required>\
            <label><input type="checkbox" name="rMe" v-model="rMe" checked>Remember Me!</label>\
                <button @click.prevent="log">Login</button>\
            \
            </form>\
        </span>'
});