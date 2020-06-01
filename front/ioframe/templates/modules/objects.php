<div id="object-manager" class="main-app">

    <div class="types">
        <button
            v-for="(item,type) in types"
            v-text="item.title"
            @click.prevent="currentAction = type"
            :class="{selected:(currentAction===type)}"
            class="type positive-3"
            >
        </button>
    </div>

    <form class="c" novalidate v-if="currentAction == 'c'">
        <h1>Create object</h1>
        <label> <div>Object:</div> <textarea v-model="c.obj"></textarea> </label>
        <label> Minimum rank to view: <input type="number" v-model="c.minV" min="-1" max="10000"></label>
        <label> Minimum rank to modify: <input type="number"  v-model="c.minM" min="0" max="10000">  </label>
        <label> Group (optional):  <input type="text" v-model="c.group" > </label>
        <label> Test Query?  <input type="checkbox" v-model="c.test"> </label>
        <button class="positive-3" @click.prevent="cSubmit" v-text="'Create Object'"></button>
    </form>

    <form class="r" novalidate v-if="currentAction == 'r'">
        <h1>Read objects</h1>
        <table>
            <thead>
            <tr>
                <th>Object ID</th>
                <th>Last Updated</th>
                <th>Group Name</th>
                <th>Remove Object</th>
            </tr>
            </thead>
            <tbody>
            <tr
                is="objectRequestDiv"
                v-for="(value, key) in r.requestObjects"
                v-bind:key="key"
                v-bind:object-id="key"
                v-bind:time-updated="value[0]"
                v-bind:group-name="value[1]"
                ></tr>
            </tbody>
        </table>
        <div>
            <label>Object ID: <input type="number" v-model="r.newObjID"></label>
            <label>Time Updated: <input type="number" v-model="r.newObjTimeUpdated" min="0" max="10000000000"></label>
            <label>Group: <input type="text" v-model="r.newObjGroup"></label>
            <button class="positive-1" v-text="'Add To Request'" @click.prevent="addObj"></button>
        </div>
        <label> Test Query?  <input type="checkbox" v-model="r.test"> </label>
        <button class="positive-3" @click.prevent="rSubmit" v-text="'Read Objects'"></button>
    </form>

    <form class="rg" novalidate v-if="currentAction == 'rg'">
        <h1>Read object groups</h1>
        <label> Group:  <input type="text" v-model="rg.group" > </label>
        <label> Test Query?  <input type="checkbox" v-model="rg.test"> </label>
        <button class="positive-3" @click.prevent="rgSubmit" v-text="'Read Object Group'"></button>
    </form>

    <form class="u" novalidate v-if="currentAction == 'u'">
        <h1>Update object </h1>
        <label> Object ID: <input type="number"  v-model="u.objID" min="0" required></label>
        <label> <div>Object (optional):</div> <textarea v-model="u.obj"></textarea> </label>
        <label> Group (optional):  <input type="text" v-model="u.group" > </label>
        <label> Minimum rank to view (optional): <input type="number" v-model="u.minV" min="-1" max="10000"></label>
        <label> Minimum rank to modify (optional): <input type="number" v-model="u.minM" min="0" max="10000">  </label>
        <label> Change Main Owner (optional): <input type="number" v-model="u.mainO" min="0"></label>
        <label> Add secondary Owner (optional): <input type="number" v-model="u.addSecO" min="0"></label>
        <label> Remove secondary Owner (optional): <input type="number" v-model="u.remSecO" min="0"></label>
        <label> Test Query?  <input type="checkbox" v-model="u.test"> </label>
        <button class="positive-3" @click.prevent="uSubmit" v-text="'Update Object'"></button>
    </form>

    <form class="d" novalidate v-if="currentAction == 'd'">
        <h1>Delete object</h1>
        <label> Object ID: <input type="number"  v-model="d.objID"></label>
        <label> Test Query?  <input type="checkbox" v-model="d.test"> </label>
        <button class="positive-3" @click.prevent="dSubmit" v-text="'Delete Object'"></button>
    </form>

    <form class="ga" novalidate v-if="currentAction == 'ga'">
        <h1>Get object-page assignments</h1>
        <label> Page Name: <input type="text"  v-model="ga.pageName"></label>
        <label> Time Updated: <input type="number" v-model="ga.date" min="0" max="10000000000"></label>
        <label> Test Query?  <input type="checkbox" v-model="ga.test"> </label>
        <button class="positive-3" @click.prevent="gaSubmit" v-text="'Get Assignment'"></button>
    </form>

    <form class="a" novalidate v-if="currentAction == 'a'">
        <h1>Assign object to page / Remove Assignment</h1>
        <label> Object ID: <input type="number" v-model="a.objID" min="0"></label>
        <label> Page Name: <input type="text" v-model="a.pageName"></label>
        <label> Remove? (default = assign) <input type="checkbox" v-model="a.rem"> </label>
        <label> Test Query?  <input type="checkbox" v-model="a.test"> </label>
        <button class="positive-3" @click.prevent="aSubmit" v-text="'Assign'"></button>
    </form>

    <p>inputs = {{inputs}}</p>

    <p>request = {{request}}</p>

    <br>
</div>