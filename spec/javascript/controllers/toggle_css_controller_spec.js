import { Application } from 'stimulus' ;
import ToggleCssController from 'toggle_css_controller.js' ;

describe('ToggleCssController', () => {
  const template = `
    <div data-controller="toggle-css" data-toggle-css-toggle-class="show">
      <button type="button" data-action="toggle-css#toggle"></button>

      <div data-toggle-css-target="toggleable" id="panel">
        This panel can shown or hidden
      </div>
    </div>
  `

  const application = Application.start()
  application.register('toggle-css', ToggleCssController) ;

  beforeEach(() => document.body.innerHTML = template)

  describe('initial state', () => {
    it("should not have the class", () => {
      expect(document.getElementById('panel').classList).not.toContain('show')
    })
  })

  describe('toggle', () => {
    beforeEach(() => { document.querySelector('button').click() })

    it('should have the open class', () => {
      expect(document.getElementById('panel').classList.contains('show')).toBe(true)
    })

    it('should not have the class after a second click', () => {
      document.querySelector('button').click()

      expect(document.getElementById('panel').classList).not.toContain('show')
    })
  })
})
