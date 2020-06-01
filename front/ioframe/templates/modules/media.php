<div id="media" class="main-app">
    <div class="loading-cover" v-if="isLoading">
    </div>

    <h1 v-if="title!==''" v-text="title"></h1>

    <div class="modes">
        <button
            v-for="(item,index) in modes"
            v-if="shouldDisplayMode(index)"
            @click="switchModeTo(index)"
            v-text="item.title"
            :class="{selected:(currentMode===index)}"
            class="positive-3"
            >
        </button>
    </div>
    <div class="operations-container"  v-if="currentModeHasOperations">
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

    <div class="operations" v-if="currentModeHasOperations && currentOperation !== ''">
        <label :for="currentOperation" v-text="currentOperationText"></label>
        <input
            v-if="currentOperationHasInput"
            :name="currentOperation"
            v-model:value="operationInput"
            type="text"
            >
        <button :class="(currentOperation === 'deleteMultiple' || currentOperation === 'delete')? 'negative-1':'positive-1'" @click="confirmOperation" >
            <div v-text="'Confirm'"></div>
            <img :src="sourceURL() + '/img/icons/confirm-icon.svg'">
        </button>
        <button class="cancel-1" @click="cancelOperation" >
            <div v-text="'Cancel'"></div>
            <img :src="sourceURL() + '/img/icons/cancel-icon.svg'">
        </button>
    </div>

    <div v-if="needViewer">
        <div is="media-viewer"
             :url="view1.url"
             :target="view1.target"
             :multiple-targets="view1.deleteTargets"
             :select-multiple="currentOperation==='deleteMultiple'"
             :display-elements="view1.elements"
             :initiate="!view1.upToDate"
             :verbose="verbose"
             :test="test"
             identifier="viewer1"
            ></div>

        <h2 v-if="secondTitle!==''" v-text="secondTitle"></h2>
        <div is="media-viewer"
             :url="view2.url"
             :target="view2.target"
             :display-elements="view2.elements"
             :initiate="!view2.upToDate"
             :test="test"
             :verbose="verbose"
             :only-folders="true"
             identifier="viewer2"
             v-if="needSecondViewer"
            >
        </div>
    </div>

    <div v-if="currentMode==='view-db'">
        <div  is="search-list"
              :_functions="searchList.functions"
              :api-url="mediaURL"
              :extra-params="searchList.extraParams"
              :extra-classes="searchList.extraClasses"
              api-action="getImages"
              :page="searchList.page"
              :limit="searchList.limit"
              :total="searchList.total"
              :items="searchList.items"
              :initiate="!searchList.initiated"
              :columns="searchList.columns"
              :filters="searchList.filters"
              :selected="searchList.selected"
              :test="test"
              :verbose="verbose"
              identifier="search"
            >
        </div>
    </div>

    <div  v-if="currentMode==='upload'"
          is="media-uploader"
          :type="lastMode === 'view'? 'local' : 'remote'"
          :url="view1.url"
          :test="test"
          :verbose="verbose"
          identifier="uploader"
        >
    </div>

    <div is="media-editor"
         v-if="currentMode==='edit'"
         :type="lastMode === 'view'? 'local' : 'remote'"
         :url="view1.url"
         :target="lastMode==='view' ? view1.target : searchList.items[searchList.selected[0]].identifier"
         :image="lastMode==='view' ? view1.elements[(view1.url==='')? view1.target : view1.url+'/'+view1.target] : searchList.items[searchList.selected[0]]"
         :verbose="verbose"
         :test="test"
         identifier="editor">
        </div>
    </div>
</div>