
//***************************
//******USER LOGIN APP*******
//***************************//
//The plugin list component, which is responsible for everything
var apiTest = new Vue({
    el: '#apiTest',
    data: {
        target:'',
        content:'',
        imgName:'',
        req: 'test',
        inputs: '',
        resp: '',
        separateVariables: false,
        newVariableName: '',
        variables:{}
    },
    methods:{
        send: function(){
            //output user inputs for testing
            this.resp = "Waiting...";

            //Data to be sent
            var data = new FormData();
            if(this.separateVariables)
                for(let name in this.variables){
                    data.append(name, this.variables[name].value);
                }
            else{
                let contentArray = this.content.split('&');
                contentArray.forEach(function(postPair, index) {
                    postPair = postPair.split('=');
                    if(postPair.length == 1)
                        postPair[1] = '';
                    data.append(postPair[0], postPair[1]);
                });
            }
            data.append('req', this.req);
            let image = document.querySelector('#uploaded1');
            let imageName = document.querySelector('#imgName');
            imageName = imageName.value? imageName.value : 'image';
            if(image.files.length>0){
                data.append(imageName, image.files[0]);
            }
            let file = document.querySelector('#uploaded2');
            if(file.files.length>0){
                data.append('file', file.files[0]);
            }
            this.inputs="Target:"+this.target+", Content:"+JSON.stringify(data);
            //Api url
            let url=document.pathToRoot+"api/"+this.target;
            //Request itself
            updateCSRFToken().then(
                function(token){
                    data.append('CSRF_token', token);
                    console.log(data);
                    fetch(url, {
                        method: 'post',
                        body: data,
                        mode: 'cors'
                    })
                        .then(function (json) {
                            return json.text();
                        })
                        .then(function (data) {
                            console.log('Request succeeded with JSON response!');
                            apiTest.resp = data;
                            alertLog(apiTest.resp);
                            if(IsJsonString(data))
                                data = JSON.parse(data);
                            console.log(data);
                        })
                        .catch(function (error) {
                            console.log('Request failed', error);
                            apiTest.resp = error;
                        });
                },
                function(reject){
                    alertLog('CSRF token expired. Please refresh the page to submit the form.','danger');
                }
            )

        },
        //Adds a new variable
        addVariable: function(newName){
            this.variables[newName] = {value:''};
            this.$forceUpdate();
        },
        //Removes a variable
        removeVariable: function(name){
            delete this.variables[name];
            this.$forceUpdate();
        },
    },
    mounted: function(){
        bindImagePreview(document.querySelector('#uploaded1'),document.querySelector('#preview1'),{
            'callback':function(){
                console.log('img2 changed!');
            },
            'bindClick':true
        });
    }
});