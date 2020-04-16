<div id="mails">
    <h2>Mails</h2>
    <div class="container">
        <div class="templates">
            <div class="actions">
                <button class="positive-1" v-text="'Create new template'" @click="createTemplate"></button>
                <button class="negative-1" v-text="'Delete template'" v-if="templateEdit.ID" @click="removeTemplate"></button>
            </div>

            <div class='title' :class={selected:index===templateEdit.ID}
                 v-for="(temp,index) in templates"
                 v-text="temp.Title"
                 @click="templateSelect(temp)">
            </div>
        </div>

        <div class="edit" v-if="action==='updateTemplate' || action==='createTemplate'">
            <h3>Title</h3>
            <input type='text' v-model="templateEdit.Title.value">
            <h3>Editor</h3>
            <textarea v-model="templateEdit.Content.value"></textarea>
            <h3>Preview</h3>
            <div class="preview" v-html="templateEdit.Content.value" ></div>
            <button class="positive-1" v-text="action==='updateTemplate'?'Update':'Create'" @click="sendAction" v-if="showActionButton"></button>
        </div>
    </div>

</div>