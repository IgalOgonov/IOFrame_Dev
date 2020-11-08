if (eventHub === undefined)
    var eventHub = new Vue();

/** Common functions
 * **/
const IOFrameCommons = {
    methods: {
        /** Sends a request to an API, given form data. Then emits an event with the returned data
         * @param data An instance of FormData with the required information
         * @param apiName Name of the API. E.G 'api/orders
         * @param eventName Name of thew event that will be emitted once the request resolves
         * @param params Of the form: {
         *                             parseJSON: bool, Parses result if it is a valid json string
         *                             identifier: string, if set, the emitted event will be of the form:
         *                                  {
         *                                   from: <identifier>
         *                                   content: <response>
         *                                  }
         *                             extraEvents: object, extra events to emit - the key is the name of the
         *                                          event, the value is bool - whether to include API response
         *                             urlPrefix: string, defaults to document.rootURI - prefix of the URL,
         *                             ignoreCSRF: bool, default false - whether to ignore requesting/sending the CSRF token.
         *                            }
         *
         * */
        apiRequest: function(data,apiName,eventName,params = {}){
            let verbose = params.verbose || false;
            let ignoreCSRF = params.ignoreCSRF || false;
            let urlPrefix = params.urlPrefix === undefined ? document.rootURI : params.urlPrefix;
            let apiURL = urlPrefix + apiName;
            let context = this;
            if(verbose)
                console.log('Sending API request to '+apiURL);
            if(!ignoreCSRF){
                updateCSRFToken().then(
                    function(token){
                        data.append('CSRF_token', token);
                        context._apiRequest(data,apiURL,eventName,params);
                    },
                    function(reject){
                        alertLog('CSRF token expired. Please refresh the page to submit the form.','error');
                    }
                );
            }
            else{
                this._apiRequest(data,apiURL,eventName,params);
            }
        },
        //The api reqeust itself, since the one before is a wrapper
        _apiRequest: function(data,apiURL,eventName,params){
            let verbose = params.verbose || false;
            let parseJSON = params.parseJSON || false;
            let identifier = params.identifier || false;
            let extraEvents = params.extraEvents || false;
            fetch(
                apiURL,
                {
                    method: 'post',
                    body: data,
                    mode: 'cors'
                }
            )
                .then(function (json) {
                    return json.text();
                })
                .then(function (data) {
                    let response;

                    //A valid response would be a JSON
                    if(parseJSON && IsJsonString(data)){
                        response = JSON.parse(data);
                        if(response.length === 0)
                            response = {};
                    }
                    //Any non-json response is invalid
                    else
                        response = data;

                    if(verbose)
                        console.log('Request data',response);

                    let request;
                    if(identifier)
                        request = {
                            from:identifier,
                            content:response
                        };
                    else
                        request = response;

                    if(verbose)
                        console.log('Emitting ',eventName);
                    eventHub.$emit(eventName,request);

                    if(extraEvents){
                        for(let secondaryEventName in extraEvents){
                            if(extraEvents[secondaryEventName])
                                eventHub.$emit(secondaryEventName,request);
                            else
                                eventHub.$emit(secondaryEventName);
                        }
                    }
                })
                .catch(function (error) {
                    alertLog('Could not reach API '+apiName+', error ',error);
                });
        }
    }
};
