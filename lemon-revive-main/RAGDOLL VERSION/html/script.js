window.addEventListener('message', function(event) {
    if (event.data.action === 'show') {
        document.getElementById('death-ui').style.display = 'block';
    } else if (event.data.action === 'hide') {
        document.getElementById('death-ui').style.display = 'none';
    }
});



window.addEventListener('message', function(event) {
    if (event.data.action === 'show') {
        document.getElementById('death-ui2').style.display = 'block';
    } else if (event.data.action === 'hide') {
        document.getElementById('death-ui2').style.display = 'none';
    }
});