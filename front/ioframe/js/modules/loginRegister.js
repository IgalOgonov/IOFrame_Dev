if(eventHub === undefined)
    var eventHub = new Vue();

var loginRegister = new Vue({
    el: '#login-register',
    name: 'Login or Register',
    mixins:[eventHubManager,IOFrameCommons],
    data(){
        return {
            configObject: JSON.parse(JSON.stringify(document.siteConfig)),
            loggedIn: document.loggedIn,
            //Modes, and array of available operations in each mode
            modes: {
                login:{
                    title:'Please log in',
                    hasRememberMe:true,
                    switchToRegistration: true
                },
                logout:{
                    title:'Welcome! You are logged in.'
                },
                register:{
                    title:'Register',
                    canHaveUsername:true,
                    requiresUsername:true
                }
            },
            currentMode:'login',
            verbose:false,
            test:false
        }
    },
    created:function(){
        this.registerHub(eventHub);
        this.registerEvent('loginResponse', this.parseLoginResponse);
        this.registerEvent('registrationResponse', this.parseRegistrationResponse);

        if(!this.configObject.login)
            this.configObject.login = [];
        if(this.configObject.login.hasRememberMe !== undefined)
            this.modes.login.hasRememberMe = this.configObject.login.hasRememberMe;
        if(this.configObject.login.switchToRegistration !== undefined)
            this.modes.login.switchToRegistration = this.configObject.login.switchToRegistration;


        if(!this.configObject.register)
            this.configObject.register = [];
        if(this.configObject.register.canHaveUsername !== undefined)
            this.modes.register.canHaveUsername = this.configObject.register.canHaveUsername;
        if(this.configObject.register.requiresUsername !== undefined)
            this.modes.register.requiresUsername = this.configObject.register.requiresUsername;

        if(this.loggedIn)
            this.currentMode = 'logout';
    },
    computed:{
    },
    watch:{
    },
    methods:{
        parseLoginResponse: function(response){
            let responseBody = response.body;
            let responseType = response.type;
            /*This will display messages that the API could return
             **/
            switch(responseBody){
                case 'INPUT_VALIDATION_FAILURE':
                    responseBody = 'User login failed - incorrect input';
                    responseType='warning';
                    break;
                case 'AUTHENTICATION_FAILURE':
                    responseBody = 'User login failed - authentication failure';
                    responseType='warning';
                    break;
                case 'WRONG_CSRF_TOKEN':
                    responseBody = 'User login failed - CSRF token wrong';
                    responseType='warning';
                    break;
                case '0':
                    responseBody = 'User logged in successfully!';
                    responseType='success';
                    break;
                case '1':
                    responseBody = 'User login failed - username and password combination is wrong!';
                    responseType='danger';
                    break;
                case '2':
                    responseBody = 'User login failed - expired auto-login';
                    responseType='warning';
                    break;
                case '3':
                    responseBody = 'User login failed - login type not allowed  (why you using this API?!)';
                    responseType='warning';
                    break;
                default:
            }
            alertLog(responseBody, responseType);
        },
        parseRegistrationResponse: function(response){
            let responseBody = response.body;
            let responseType = response.type;
            /*This will display messages that the API could return
             **/
            switch(responseBody){
                case 'INPUT_VALIDATION_FAILURE':
                    responseBody = 'User creation failed - incorrect input';
                    break;
                case 'AUTHENTICATION_FAILURE':
                    responseBody = 'User creation failed - authentication failure';
                    break;
                case 'WRONG_CSRF_TOKEN':
                    responseBody = 'User creation failed - CSRF token wrong';
                    break;
                case '0':
                    responseBody = 'User created successfully!';
                    break;
                case '1':
                    responseBody = 'User creation failed - username already in use!';
                    break;
                case '2':
                    responseBody = 'User creation failed - email already in use!';
                    break;
                case '3':
                    responseBody = 'User creation failed - server error!';
                    break;
                default:
            }
            alertLog(responseBody, responseType);
        }
    },
});