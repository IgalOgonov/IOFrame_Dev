<div id="auth" class="main-app">
    <div class="loading-cover" v-if="!initiated">
    </div>

    <div class="types">
        <button
            v-for="(item,index) in types"
            v-text="item.title"
            @click="switchTypeTo(index)"
            :class="[{selected:(currentType===index)},(item.button? item.button : ' positive-3')]"
            class="type"
            >
        </button>
    </div>

    <h1 v-if="title!==''" v-text="title"></h1>

    <div class="modes">
        <button
            v-for="(item,index) in modes"
            v-if="shouldDisplayMode(index)"
            v-text="item.title"
            @click="switchModeTo(index)"
            :class="[{selected:(currentMode===index)},(item.button? item.button : ' positive-3')]"
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
        <label :for="currentOperation" v-text="currentOperationText" v-if="currentOperation === 'create'"></label>
        <input
            v-if="currentOperationHasInput"
            :name="currentOperation"
            :placeholder="currentOperationPlaceholder"
            v-model:value="operationInput"
            type="text"
        >
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
         :api-action="currentAction"
         :extra-params="extraParams"
         :page="page"
         :limit="limit"
         :total="total"
         :items="items"
         :initiate="!initiated"
         :columns="currentColumns"
         :filters="filters"
         :selected="selected"
         :test="test"
         :verbose="verbose"
         identifier="search"
    ></div>

    <div is="auth-actions-editor"
         v-if="currentType==='actions' && currentMode==='create'"
         identifier="actions-creator"
         :test="test"
         :verbose="verbose"
        ></div>

    <div is="auth-groups-editor"
         v-if="currentType==='groups' && currentMode==='create'"
         mode="create"
         identifier="groups-creator"
         :test="test"
         :verbose="verbose"
        ></div>

    <div is="auth-groups-editor"
         v-if="currentType==='groups' && currentMode==='edit'"
         mode="update"
         identifier="groups-editor"
         :id="selectedId"
         :test="test"
         :verbose="verbose"
        ></div>

    <div is="auth-users-editor"
         v-if="currentType==='users' && currentMode==='edit'"
         :id="selectedId"
         identifier="users-editor"
         :test="test"
         :verbose="verbose"
        ></div>
</div>