import jQuery from 'jquery'
window.jQuery = jQuery

import { Application } from 'stimulus' ;
import StepByStepNavController from 'step_by_step_nav_controller.js' ;


describe('StepByStepNavController', () => {
  const template = `
    <div id="step-by-step-navigation" class="app-step-nav" data-controller="step-by-step-nav" data-show-text="Show" data-hide-text="Hide" data-show-all-text="Show all" data-hide-all-text="Hide all">
      <ol class="app-step-nav__steps">
        <li class="app-step-nav__step js-step" id="check-youre-allowed-to-drive" >
          <div class="app-step-nav__header js-toggle-panel" data-position="1">
            <h3 class="app-step-nav__title">
              <span class="app-step-nav__circle app-step-nav__circle--number">
                <span class="app-step-nav__circle-inner">
                  <span class="app-step-nav__circle-background">
                    <span class="govuk-visually-hidden">Step</span> 1
                  </span>
                </span>
              </span>

              <span class="js-step-title">
                Check you're allowed to drive
              </span>
            </h3>
          </div>

          <div class="app-step-nav__panel js-panel js-hidden" id="step-panel-check-youre-allowed-to-drive-1">
            <p class="app-step-nav__paragraph">Most people can start learning to drive when they’re 17.</p>

            <ol class="app-step-nav__list " data-length="3">
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="1.1" class="app-step-nav__link" href="#">Check what age you can drive </a>
              </li>
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="1.2" class="app-step-nav__link" href="#">Requirements for driving legally </a>
              </li>
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="1.3" class="app-step-nav__link" href="#">Driving eyesight rules </a>
              </li>
            </ol>
          </div>
        </li>

        <li class="app-step-nav__step js-step" id="get-a-provisional-licence" >
          <div class="app-step-nav__header js-toggle-panel" data-position="2">
            <h3 class="app-step-nav__title">
              <span class="app-step-nav__circle app-step-nav__circle--number">
                <span class="app-step-nav__circle-inner">
                  <span class="app-step-nav__circle-background">
                    <span class="govuk-visually-hidden">Step</span> 2
                  </span>
                </span>
              </span>

              <span class="js-step-title">
                Get a provisional licence
              </span>
            </h3>
          </div>

          <div class="app-step-nav__panel js-panel js-hidden" id="step-panel-get-a-provisional-licence-2">
            <ol class="app-step-nav__list " data-length="1">
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="2.1" class="app-step-nav__link" href="#">Apply for your first provisional driving licence <span class="app-step-nav__context">£34 to £43</span></a>
              </li>
            </ol>
          </div>
        </li>

        <li class="app-step-nav__step js-step" id="driving-lessons-and-practice" >
          <div class="app-step-nav__header js-toggle-panel" data-position="3">
            <h3 class="app-step-nav__title">
              <span class="app-step-nav__circle app-step-nav__circle--number">
                <span class="app-step-nav__circle-inner">
                  <span class="app-step-nav__circle-background">
                    <span class="govuk-visually-hidden">Step</span> 3
                  </span>
                </span>
              </span>

              <span class="js-step-title">
                Driving lessons and practice
              </span>
            </h3>
          </div>

          <div class="app-step-nav__panel js-panel js-hidden" id="step-panel-driving-lessons-and-practice-3">
            <p class="app-step-nav__paragraph">You need a provisional driving licence to take lessons or practice.</p>

            <ol class="app-step-nav__list " data-length="4">
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="3.1" class="app-step-nav__link" href="#">The Highway Code </a>
              </li>
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="3.2" class="app-step-nav__link" href="#">Taking driving lessons </a>
              </li>
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="3.3" class="app-step-nav__link" href="#">Find driving schools, lessons and instructors </a>
              </li>
              <li class="app-step-nav__list-item js-list-item ">
                <a data-position="3.4" class="app-step-nav__link" href="#">Practise vehicle safety questions </a>
              </li>
            </ol>
          </div>
        </li>
      </ol>
    </div>
  `

  const application = Application.start()
  application.register('step-by-step-nav', StepByStepNavController) ;

  beforeEach(() => document.body.innerHTML = template)

  describe('initial state', () => {
    it("instantiates the step by step nav library", () => {
      const el = document.getElementById('step-by-step-navigation')

      expect(el.classList).toContain('app-step-nav--active')
    })

    it("adds the show/hide controls", () => {
      const el = document.getElementById('step-by-step-navigation')

      expect(el.querySelector('.app-step-nav__controls')).not.toBeNull()
    })
  })
})
