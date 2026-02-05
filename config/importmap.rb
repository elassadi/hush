# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"



# Avo custom JS entrypoint
pin "avo.custom", preload: true
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"

pin "turbo_ready", to: "https://ga.jspm.io/npm:turbo_ready@0.1.2/app/javascript/index.js"
pin "@alpinejs/morph", to: "https://ga.jspm.io/npm:@alpinejs/morph@3.10.5/dist/module.esm.js"
pin "alpinejs", to: "https://ga.jspm.io/npm:alpinejs@3.10.5/dist/module.esm.js"

# pin "jquery", to: "library/jquery.js"  #"https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js"
# pin "jquery-ui-dist", to: "library/jquery.js"  #"https://ga.jspm.io/npm:jquery-ui-dist@1.13.1/jquery-ui.js"
# pin "jqtree", to: "https://ga.jspm.io/npm:jqtree@1.6.2/lib/tree.jquery.js"
# only for patternlock
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.js"
# pin "patternlock", to: "https://cdn.jsdelivr.net/npm/@garyliao/pattern-lock-js-advanced@1.0.1/patternlock.min.js"
pin "patternlock", to: "patternlock.min.js"



#pin "tui-calendar", to: "https://cdn.jsdelivr.net/npm/tui-calendar@1.15.3/dist/tui-calendar.min.js"
# pin "calendar", to: "https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"
#pin "tui-time-picker", to: "https://ga.jspm.io/npm:tui-time-picker@latest/dist/tui-time-picker.js"
#pin "flatpickr", to: "https://cdn.skypack.dev/flatpickr"
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js"

# pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@5.1.1/dist/tailwindcss-stimulus-components.module.js"
pin "sweetalert2", to: "https://ga.jspm.io/npm:sweetalert2@11.6.15/dist/sweetalert2.all.js"
