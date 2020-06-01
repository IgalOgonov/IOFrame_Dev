<script>
    if(!document.loggedIn && !localStorage.getItem('sesID'))
        window.location = document.rootURI + 'cp/login';
</script>