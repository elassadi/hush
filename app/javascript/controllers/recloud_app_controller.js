import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = []
  static values = {
    view: String
  }

  static localizedIntroJsLabels = {
    en: {
      nextLabel: 'Next',
      prevLabel: 'Back',
      doneLabel: 'Done',
    },
    de: {
      nextLabel: 'Weiter',
      prevLabel: 'Zurück',
      doneLabel: 'Fertig'
    }
  }

  static currentLang = "de"

  connect() {
    this.invokeTourBasedOnPath();
  }

  recloudData () {
    return window.globalRecloudData;
  }

  invokeTourBasedOnPath() {
    const path = window.location.pathname;
    const methodName = this.getMethodNameFromPath(path);



    if (this[methodName] && !this.hasSeenTour(methodName, this.viewValue)) {
    //if (this[methodName]) {
      this[methodName]();
      this.markTourAsSeen(methodName, this.viewValue);
    }
  }

  invokeTourBasedOnName(methodName) {

    if (this[methodName] && !this.hasSeenTour(methodName, this.viewValue)) {
    //if (this[methodName]) {
      this[methodName]();
      this.markTourAsSeen(methodName, this.viewValue);
    }
  }

  getMethodNameFromPath(path) {

    var recloudData = window.globalRecloudData;
    let postfix = "Tour"

    if (recloudData.on_boarding || !recloudData.active_account)
      postfix =  'OnboardingTour';


    postfix = this.capitalize(this.viewValue) + postfix;

    return path
      .split('/')
      .filter(part => part && isNaN(part)) // Filter out numeric parts (IDs)
      .map((part, index) => index === 0 ? part : this.capitalize(part))
      .join('') + postfix;
  }

  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  hasSeenTour(tourName, view) {
    const seenTours = JSON.parse(localStorage.getItem('seenTours')) || {};
    return seenTours[tourName] && seenTours[tourName].includes(view);
  }

  markTourAsSeen(tourName, view) {
    // Retrieve seen tours from localStorage
    const seenTours = JSON.parse(localStorage.getItem('seenTours')) || {};

    // Initialize the array for the tour if it doesn't exist
    if (!seenTours[tourName]) {
      seenTours[tourName] = [];
    }

    // Add the view to the list of seen views if not already present
    if (!seenTours[tourName].includes(view)) {
      seenTours[tourName].push(view);
    }

    // Save the updated seen tours back to localStorage
    localStorage.setItem('seenTours', JSON.stringify(seenTours));
  }





 /* onboarding tours */

  dashboardsCockpitShowOnboardingTour() {
    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Willkommen bei ReCloud!',
          intro: "Hier können Sie Ihre Geschäftsprozesse effizient verwalten und optimieren. Klicken Sie bitte auf 'Weiter', um fortzufahren."
        },
        {
          title: 'Wichtige Informationen',
          element: document.querySelector('a[href^="/resources/merchants"]'),
          intro: "Um weiter mit ReCloud zu arbeiten, müssen Sie zunächst Ihre Geschäftsinformationen vervollständigen. Klicken Sie bitte auf 'Weiter', um fortzufahren."
        },
        {
          title: '',
          element: document.querySelector('a[href^="/resources/merchants"]')
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).onchange(function(targetElement) {


      if (this._currentStep === 2) {


        this._introItems[2].element.click();
      }
    }).start();
  }
  resourcesMerchantsIndexOnboardingTour() {
    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Sie Sind als Master Händler im System angelegt',
          element: document.querySelector('a[data-target="control:view"][href^="/resources/merchants/"]'),
          intro: "Wir benötigen noch Ihre Adresse, um Ihr Konto zu vervollständigen. Wir zeigen Ihnen, wie Sie Ihre Adresse hinzufügen können. Klicken Sie bitte auf 'Weiter', um fortzufahren."
        },
        {
          title: '',
          element: document.querySelector('a[data-target="control:view"][href^="/resources/merchants/"]'),
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).onchange(function(targetElement) {
      if (this._currentStep === 1) {
        this._introItems[1].element.click();
      }
    }).start();
  }

  showDelayedResourcesMerchantsEditOnboardingTour() {
    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Hier legen Sie hier Ihre Adresse fest',
          element: document.querySelector('a[href^="/resources/addresses/new"]'),
          intro: "Klicke hier, um eine neue Adresse hinzuzufügen. "
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).onchange(function(targetElement) {
      if (this._currentStep === 1) {
        //this._introItems[1].element.click();
      }
    }).start();
  }

  resourcesMerchantsShowOnboardingTour() {
    setTimeout(() => {
      this.showDelayedResourcesMerchantsEditOnboardingTour();
    }, 1000); // 3000 milliseconds = 3 seconds
  }

 /* end onboarding tours */



  /* cockpit tours */
  dashboardsCockpitShowTour() {
    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Übersicht über das Cockpit-Dashboard',
          element: document.querySelector('a[href^="/dashboards/cockpit"]'),
          intro: "Willkommen im Cockpit-Dashboard! Hier erhalten Sie einen umfassenden Überblick über wichtige Leistungskennzahlen und aktuelle Metriken, die Ihnen helfen, fundierte Entscheidungen zu treffen. Nutzen Sie diese Übersicht, um die Effizienz Ihrer Abläufe auf einen Blick zu erkennen."
        },
        {
          title: 'Anzahl nicht bestätigter Kalendereinträge',
          element: document.querySelector('#cockpit_calendar_entries_metric'),
          intro: "Achtung: Nicht bestätigte Termine könnten potenziellen Umsatzverlust bedeuten. Wenn Termine nicht rechtzeitig bestätigt werden, besteht die Gefahr, dass Kunden zur Konkurrenz abwandern. Achten Sie darauf, diesen Wert so niedrig wie möglich zu halten, um Ihre Kundenzufriedenheit und Ihren Umsatz zu sichern."
        },
        {
          title: 'Auftragseingänge vs. Erledigte Aufträge',
          element: document.querySelector('#cockpit_issue_area_chart'),
          intro: "Dieser Bereich zeigt einen Vergleich zwischen den neuen Auftragseingängen und den abgeschlossenen Aufträgen. Nutzen Sie diese Visualisierung, um den Fortschritt und die Produktivität Ihres Teams effektiv zu überwachen und zu analysieren."
        },
        {
          title: '',
          element: document.querySelector('#cockpit_revenue_chart'),
          intro: "Die Umsatzentwicklung zeigt Ihnen, wie sich Ihr Umsatz im Zeitverlauf entwickelt. Nutzen Sie diese Informationen, um Trends zu erkennen und Ihre Geschäftsstrategie entsprechend anzupassen."
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).start();
  }




  /* archive tours */
  startTour() {

    let hasSeenShowTour = localStorage.getItem('hasSeenShowTour');
    if (this.viewValue === 'show' && !hasSeenShowTour) {
      this.startShowTour()
      localStorage.setItem('hasSeenShowTour', 'true');
    }

    let hasSeenEditTour = localStorage.getItem('hasSeenEditTour');

    if (this.viewValue === 'edit' && !hasSeenEditTour) {
      this.startEditTour()
      localStorage.setItem('hasSeenEditTour', 'true');
    }
  }

  startShowTour() {

    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Neues Feature: Kundenaddresse bearbeiten',
          element: document.querySelector('a.button-component[href^="/resources/issues/"][href$="/edit"]'),
          intro: "Das Editieren des Auftrags ermöglicht es, Kundendaten und Adresse effizient zu aktualisieren. Klicken Sie auf ‘Bearbeiten’, und ich führe Sie durch den Vorgang."
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).start();
  }

  startEditTour() {
    introJs().setOptions({
      ...this.constructor.localizedIntroJsLabels[this.constructor.currentLang],
      steps: [
        {
          title: 'Neues Feature: Kundenaddresse bearbeiten',
          element: document.querySelector('div[data-issue-resource-target="customerBelongsToWrapper"] .button-component[id*="edit_button_"]'),
          intro: "Der ausgewählte Kunde kann jetzt direkt bearbeitet werden. Sie müssen nicht mehr zur Kundenansicht wechseln, um die Adresse zu ändern. Klicken Sie auf ‚Weiter‘, um die Funktion auszuprobieren."
        },
        {
          title: 'Adresse bearbeiten',
          element: document.querySelector('input[name="customer[street]"]'),
          intro: "Sie können die Adresse hier bearbeiten.",
          position: 'left'
        }
      ],
      showStepNumbers: true,
      exitOnOverlayClick: false,
      showProgress: true
    }).onchange(function(targetElement) {
      // Check if we are on the specific step to trigger the click
      if (this._currentStep === 1) {
        this._introItems[0].element.click();
      }
      //targetElement.click();

    }).start();
  }
}
