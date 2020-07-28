<nav id="menu" :class="{open:open}">
    <div class="button-wrapper">
        <button @click.prevent="open = !open" :class="{open:open}">  </button>
    </div>
    <a :href="logo.url" class="logo">
        <img :src="logo.imgURL">
    </a>

    <a  v-for="item in menu" :href="item.disabled ? '#':item.url" :class="{selected:item.id === selected,disabled:item.disabled}">
        <img v-if="item.icon" :src="sourceURL()+'img/'+item.icon">
        <span  v-text="item.title"></span>
    </a>

    <a v-if="otherCP.url" :href="otherCP.url" class="other-cp">
        <img v-if="otherCP.imgURL" :src="otherCP.imgURL">
        <span v-else="" v-text="otherCP.title"></span>
    </a>
</nav>