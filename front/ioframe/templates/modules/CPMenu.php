<nav id="menu" :class="{open:open}">
    <div class="button-wrapper">
        <button @click.prevent="open = !open" :class="{open:open}">  </button>
    </div>
    <a :href="logo.url" class="logo">
        <picture>
            <source :srcset="extractImageAddress(logo,true)">
            <source :srcset="extractImageAddress(logo)">
            <img :src="extractImageAddress(logo,true)">
        </picture>
    </a>

    <a  v-for="item in menu" :href="item.disabled ? '#':item.url" :class="{selected:item.id === selected,disabled:item.disabled}">
        <picture v-if="item.icon">
            <source :srcset="extractImageAddress(item,true)">
            <source :srcset="extractImageAddress(item)">
            <img :src="extractImageAddress(item,true)">
        </picture>
        <span  v-text="item.title"></span>
    </a>

    <a v-if="otherCP.url" :href="otherCP.url" class="other-cp">
        <picture v-if="item.icon">
            <source :srcset="extractImageAddress(otherCP,true)">
            <source :srcset="extractImageAddress(otherCP)">
            <img :src="extractImageAddress(otherCP,true)">
        </picture>
        <span v-else="" v-text="otherCP.title"></span>
    </a>
</nav>