const hudDIV = $(".hud");

(() => {
    Hud = {};

    Hud.Show = function(data) {
        // print("HJII")
        if (data.toggle) {
            hudDIV.css("display", "block");
        } else {
            hudDIV.css("display", "none");
        }
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case "show":
                    Hud.Show(event.data);
                    break;
            }
        })
    }

})();