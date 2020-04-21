<span id="apiTest">
    <button @click.prevent="separateVariables = !separateVariables"> Toggle Separate Variables Mode</button>
    <form novalidate>


        <input type="text" id="target" name="target" placeholder="target API" v-model="target" required>
        <span v-if="separateVariables" id="variables">
            <div v-for="(content, name) in variables">
                <button @click.prevent="removeVariable(name)"> X </button>
                <input type="text" v-model:value="name">
                <textarea class="content" name="content" placeholder="content" v-model="content.value"></textarea>
            </div>
            <div>
                <input type="text" v-model:value="newVariableName">
                <button @click.prevent="addVariable(newVariableName)"> Add Variable </button>
            </div>
        </span>
        <textarea v-else="" class="content" name="content" placeholder="content" v-model="content"></textarea>
        <span class="form-group">
            <input type="text" id="imgName" name="imgName" placeholder="Upload POST name" v-model="imgName">
            <img id="preview1" src="" style="height: 100px;width: 100px;cursor: pointer;">
            <input id="uploaded1" name="uploaded1" type="file" style="display:none;">
        </span>
        <span class="form-group">
            <input id="uploaded2" name="uploaded2" type="file" style="display: inline">
        </span>
        <select id="req_log" name="req" v-model="req" value="test" required>
            <option value="real" selected>Real</option>
            <option value="test">Test</option>
        </select>

        <button @click.prevent="send">Send</button>

    </form>
    <div>inputs = {{ inputs }}</div>

    <div>{{ resp }}</div>
</span>