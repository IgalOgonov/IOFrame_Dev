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
                :class="[index,{selected:(currentOperation===index)}]"
                >
                <div v-text="item.title"></div>
                <img :src="sourceURL() + '/img/icons/' + index + '-icon.svg'">
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
        <button :class="{negative:(currentOperation === 'deleteMultiple')}" @click="confirmOperation" >
            <div v-text="'Confirm'"></div>
            <img :src="sourceURL() + '/img/icons/confirm-icon.svg'">
        </button>
        <button class="cancel" @click="cancelOperation" >
            <div v-text="'Cancel'"></div>
            <img :src="sourceURL() + '/img/icons/cancel-icon.svg'">
        </button>
    </div>

    <div v-if="needViewer">
        <div is="media-viewer"
             :url="url"
             :target="target"
             :multiple-targets="deleteTargets"
             :select-multiple="currentOperation==='deleteMultiple'"
             :display-elements="view1Elements"
             :initiate="!view1UpToDate"
             :verbose="verbose"
             :test="test"
             identifier="viewer1"
            ></div>

        <h2 v-if="secondTitle!==''" v-text="secondTitle"></h2>
        <div is="media-viewer"
             :url="view2URL"
             :target="view2Target"
             :display-elements="view2Elements"
             :initiate="!view2UpToDate"
             :test="test"
             :verbose="verbose"
             :only-folders="true"
             identifier="viewer2"
             v-if="needSecondViewer"
            >
        </div>
    </div>

    <div  v-if="currentMode==='upload'"
          is="media-uploader"
          :url="url"
          :test="test"
          :verbose="verbose"
          identifier="uploader"
        >
    </div>

    <div is="media-editor"
         v-if="currentMode==='edit'"
         :url="url"
         :target="target"
         :image="view1Elements[(url==='')? target : url+'/'+target]"
         :verbose="verbose"
         :test="test"
         identifier="editor">
        </div>
    </div>
</div>