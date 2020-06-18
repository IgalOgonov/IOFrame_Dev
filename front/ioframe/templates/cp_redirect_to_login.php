<script>
    let isAdmin = <?php echo ($auth->isAuthorized(0) ? 'true' : 'false')?>;
    if(
        (!document.loggedIn && !localStorage.getItem('sesID')) ||
        (document.loggedIn && !isAdmin)
    )
        window.location = document.rootURI + 'cp/login';
</script>