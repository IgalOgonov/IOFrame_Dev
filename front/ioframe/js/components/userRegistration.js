if(eventHub === undefined)
    var eventHub = new Vue();

/*Captcha functions, since we must call global ones*/
if(captchaRegistrationSuccess === undefined)
    var captchaRegistrationSuccess = function(response){
        eventHub.$emit('registrationSuccess',response)
    }
if(captchaRegistrationExpired === undefined)
    var captchaRegistrationExpired = function(response){
        eventHub.$emit('registrationExpired',response)
    }
if(captchaRegistrationError === undefined)
    var captchaRegistrationError = function(response){
        eventHub.$emit('registrationError',response)
    }

Vue.component('user-registration', {
    props:{
        //Up to the parent to enforce that if you are REQUIRED to have a username, you also CAN have it
       canHaveUsername:{
            type: Boolean,
            default: true
        },
        requiresUsername:{
            type: Boolean,
            default: true
        },
        //Whether a captcha is required. Is irrelevant if the site does not have a captcha site key at document.captchaSiteKey.
        requireCaptcha:{
            type: Boolean,
            default: true
        },
        //Various captcha options
        captchaOptions:{
            type: Object,
            default: function(){
                return {
                    siteKey: document.captchaSiteKey ? document.captchaSiteKey : false, /*if not provided from anywhere, wont use captcha*/
                    theme: 'light', /*light or dark*/
                    size: 'normal' /*noraml or compact*/
                };
            }
        },
        text: {
            type: Object,
            default: function(){
                return {
                    username: this.requiresUsername? 'Username' : '[Optional] Username',
                    userNameHelp: (
                        this.requiresUsername?
                        'Must be 6-16 characters long, Must contain numbers and letters' :
                        '{OPTIONAL} Must be 6-16 characters long, Must contain numbers and letters'
                    ),
                    password: 'Password',
                    passwordHelp: "Must be 8-64 characters long<br> Must include latters and numbers<br>Can include special characters except '>' and '<'",
                    repeatPassword: 'Repeat password',
                    email: 'Email',
                    captcha:{
                        expired: 'Registration captcha expired! Please revalidate.',
                        error: 'Registration captcha error! Captcha reset.',
                        validation: 'Please complete the captcha!',
                        serverError: 'Server error trying to validate registration captcha!',
                        invalid: 'Captcha does not appear to be valid!',
                        alreadyValidated: 'Captcha has already been validated! Captcha reset, validate again.',
                    },
                    registrationButton: 'Register'
                };
            }
        },
        customTooltips:{
            type: Object,
            default: function(){
                return {
                    username:'',
                    password:'',
                    activityClass:''
                }
            }
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
    data: function(){
        return {
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
            captcha: '',
            captchaID: '',
            req: 'real',
            resp: ''
        }
    },
    computed:{
    },
    created:function(){
        eventHub.$on('registrationSuccess',this.captchaSuccess);
        eventHub.$on('registrationExpired',this.captchaExpired);
        eventHub.$on('registrationError',this.captchaError);
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
            if(this.canHaveUsername && this.u.val.length > 0){
                if( (this.u.val.length>16) ||(this.u.val.length<6) || (this.u.val.match(/\W/g)!=null) ){
                    this.u.class = "error";
                    errors++;
                }
                else
                    this.u.class = "success";

            }
            else if(this.requiresUsername && this.u.val.length == 0){
                this.u.class = "error";
                errors++;
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

            //validate captcha
            if(this.requireCaptcha && this.captchaOptions.siteKey && (this.captcha === '')){
                alertLog(this.text.captcha.validation,'warning');
                errors++;
            }

            //if no errors - send data
            if(errors<1){
                this.resp = "Posting...";
                //Data to be sent
                var data = new FormData();
                data.append('action', 'addUser');
                if(this.captcha)
                    data.append('captcha', this.captcha);
                if(this.canHaveUsername && this.u.val.length > 0)
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
                        let response = data;
                        // success
                        if(context.verbose)
                            console.log("Posted: to user API"+" ,Succeeded in getting response ",response," to post.");
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
                            case 'CAPTCHA_SERVER_FAILURE':
                                respType='error';
                                response = context.text.captcha.serverError;
                                break;
                            case 'CAPTCHA_INVALID':
                                respType='warning';
                                response = context.text.captcha.invalid;
                                break;
                            case 'CAPTCHA_ALREADY_VALIDATED':
                                respType='info';
                                response = context.text.captcha.alreadyValidated;
                                hcaptcha.reset(context.captchaID);
                                break;
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
                                if(context.canHaveUsername)
                                    context.u.class = "warning";
                                hcaptcha.reset(context.captchaID);
                                break;
                            case '2':
                                context.m.class = "#fcf8e3";
                                respType='warning';
                                hcaptcha.reset(context.captchaID);
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
                        console.log("Posted: ",data,"to user api"+" ,Failed in getting response to post.");
                    //Can be implemented differently in different apps
                    eventHub.$emit('registrationResponse',{body:'Failed to reach API, cannot log in. Error text '+error});
                    console.log('Error: ' + error); // An error occurred during the request.
                });
            };
        },
        //Captcha related functions
        captchaSuccess: function(response){
            if(this.verbose)
                console.log('Captcha succeeded!',response);
            this.captcha = response;
        },
        captchaExpired: function(response){
            if(this.verbose)
                console.log('Captcha expired!',response);
            alertLog(this.text.captcha.expired,'warning');
            this.captcha = '';
        },
        captchaError: function(response){
            if(this.verbose)
                console.log('Captcha error!',response);
            alertLog(this.text.captcha.error,'warning');
            this.captcha = '';
            hcaptcha.reset(this.captchaID);
        }
    },
    mounted: function(){
        document.popupHandler = new ezPopup("pop-up-tooltip");
        if(this.canHaveUsername)
            document.popupHandler.initPopup('u_reg-tooltip',this.text.userNameHelp,this.customTooltips.username,this.customTooltips.activityClass);
        document.popupHandler.initPopup('p_reg-tooltip',this.text.passwordHelp,this.customTooltips.password,this.customTooltips.activityClass);
        if(this.verbose)
            console.log(this.captchaOptions.siteKey,this.requireCaptcha);
        if(this.requireCaptcha && this.captchaOptions.siteKey){
            if(this.verbose)
                console.log('Rendering registration captcha!');
            this.captchaID = hcaptcha.render(this.$el.querySelector('.h-captcha'),JSON.parse(JSON.stringify(this.captchaOptions)));
        }
    },
    template: `
    <span class="user-registration">
        <form novalidate>
    
        <label>
            <input v-if="canHaveUsername" :class="[u.class]" type="text" id="u_reg" name="u" :placeholder="text.username" v-model="u.val" required>
            <a v-if="canHaveUsername" href="#"  id="u_reg-tooltip">?</a>
        </label>
    
        <label>
            <input :class="[p.class]" type="password" id="p_reg" name="p" :placeholder="text.password" v-model="p.val" required>
            <a href="#"  id="p_reg-tooltip">?</a>
        </label>
    
        <input :class="[p2.class]" type="password" id="p2_reg" :placeholder="text.repeatPassword" v-model="p2.val" required>
    
        <input :class="[m.class]" type="email" id="m_reg" name="m" :placeholder="text.email" v-model="m.val" required>
        
        <div v-if="requireCaptcha && captchaOptions.siteKey" class="h-captcha" :data-sitekey="captchaOptions.siteKey" data-callback="captchaRegistrationSuccess" data-expired-callback="captchaRegistrationExpired" data-error-callback="captchaRegistrationError"></div>
    
        <button @click.prevent="reg" v-text="text.registrationButton"></button>
    
        </form>
    </span>`
});