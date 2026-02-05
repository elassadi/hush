import { Application } from "@hotwired/stimulus"
import TurboReady from 'turbo_ready' // <- import first


TurboReady.initialize(Turbo.StreamActions) // then Add TurboReady stream actions to Turbo

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
