<div class="main-app" id="login-register" :mode="currentMode">
    <h1 v-text="modes[currentMode].title"></h1>

    <div
        is="user-login"
        v-if="currentMode==='login'"
        :has-remember-me="modes.login.hasRememberMe"
        :test="test"
        :verbose="verbose"
        >
    </div>
    <div
        is="user-logout"
        v-if="currentMode==='logout'"
        :test="test"
        :verbose="verbose"
        >
    </div>

    <div
        is="user-registration"
        :can-have-username="modes.login.canHaveUsername"
        :requires-username="modes.login.requiresUsername"
         v-if="currentMode==='register'"
         :test="test"
         :verbose="verbose"
        >
    </div>

    <button v-if="modes.login.switchToRegistration && currentMode=='login'" v-text="'Register Instead'" @click.prevent="currentMode='register'"></button>
    <button v-if="modes.login.switchToRegistration && currentMode=='register'" v-text="'Login Instead'" @click.prevent="currentMode='login'"></button>

</div>