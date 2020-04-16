<nav id="menu">
    <a :href="logo.url" class="logo">
        <img :src="logo.imgURL">
    </a>
    <a  v-for="item in menu" v-text="item.title" :href="item.url" :class="{selected:item.id === selected}">

    </a>
</nav>