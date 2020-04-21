<div id="settings" class="main-app">
    <div class="loading" v-if="!initiated">
    </div>

    <h4 v-if="currentMode==='search'" class="message message-error-2">
        The settings found here affect the <u>whole system</u>.<br>
        It is possible to cause temporary, and sometimes <u>irreversible system damage</u> with even a simple typo.<br>
        Please <u>do not use this module</u> unless are you <u>absolutely familiar</u> with how the specific settings you are editing work.<br>
    </h4>

    <h1 v-if="title!==''" v-text="title"></h1>

    <div class="modes">
        <button
            v-for="(item,index) in modes"
            v-if="shouldDisplayMode(index)"
            v-text="item.title"
            @click="switchModeTo(index)"
            :class="{selected:(currentMode===index)}"
            class="positive-3"
        >
        </button>
    </div>

    <div class="operations-container" v-if="currentModeHasOperations">
        <div class="operations-title" v-text="'Actions'"></div>
        <div class="operations" v-if="currentOperation===''">
            <button
                v-if="shouldDisplayOperation(index)"
                v-for="(item,index) in modes[currentMode].operations"
                @click="operation(index)"
                :class="[index,{selected:(currentOperation===index)},(item.button? item.button : 'positive-3')]"
            >
                <div v-text="item.title"></div>
            </button>
        </div>
    </div>

    <div class="operations" v-if="currentModeHasOperations && currentOperation !==''">
        <button
            :class="(currentOperation === 'delete' ? 'negative-1' : 'positive-1')"
            @click="confirmOperation">
            <div v-text="'Confirm'"></div>
        </button>
        <button class="cancel-1" @click="cancelOperation">
            <div v-text="'Cancel'"></div>
        </button>
    </div>

    <div is="search-list"
         v-if="currentMode==='search'"
         :api-url="url"
         api-action="getSettingsMeta"
         :extra-classes="extraClasses"
         :items="items"
         :initiate="!initiated"
         :columns="columns"
         :filters="filters"
         :selected="selected"
         :test="test"
         :verbose="verbose"
         identifier="search"
    ></div>

    <div is="settings-editor"
         v-if="currentMode==='edit'"
         identifier="editor"
         :item="items[selected]"
         :id="selectedId"
         :test="test"
         :verbose="verbose"
        ></div>
</div>