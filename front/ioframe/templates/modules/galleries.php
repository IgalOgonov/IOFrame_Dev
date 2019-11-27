<div id="galleries" class="main-app">
    <div class="loading" v-if="isLoading">
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
        <div class="operations-title">Actions</div>
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
        <button
            :class="{negative:(currentOperation === 'remove' || currentOperation === 'delete'), positive:(currentOperation === 'add')}"
            @click="confirmOperation" >
            <div v-text="'Confirm'"></div>
            <img :src="sourceURL() + '/img/icons/confirm-icon.svg'">
        </button>
        <button class="cancel" @click="cancelOperation" >
            <div v-text="'Cancel'"></div>
            <img :src="sourceURL() + '/img/icons/cancel-icon.svg'">
        </button>
    </div>

    <div  v-if="currentMode==='search'"
          is="search-list"
          :api-url="mediaURL"
          api-action="getGalleries"
          :page="page"
          :limit="limit"
          :total="total"
          :items="galleries"
          :initiate="!galleriesInitiated"
          :columns="columns"
          :filters="filters"
          :selected="selected"
          :test="test"
          :verbose="verbose"
          identifier="search"
        >
    </div>

    <div  v-if="currentMode==='edit'"
          is="gallery-editor"
          :gallery="getSelectedGallery"
          :current-operation="currentOperation"
          :selected="selectedGalleryMembers"
          :gallery-members="galleryMembers"
          :initiated="galleryInitiated"
          :view-elements="viewElements"
          :view-selected="viewSelected"
          :view-up-to-date="viewUpToDate"
          :target="target"
          :url="url"
          :test="test"
          :verbose="verbose"
          identifier="editor"
        >
    </div>
</div>