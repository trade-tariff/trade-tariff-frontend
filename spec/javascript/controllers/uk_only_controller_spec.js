import { Application } from '@hotwired/stimulus' ;
import UkOnlyController from 'uk_only_controller.js' ;

describe('UkOnlyController', () => {
  const template = `
    <div>
      <p class="pre">Some Content</p>

      <div data-controller="uk-only">
        <p class="to-hide">Hidden Content</p>
      </div>
    </div>
  `

  const application = Application.start()
  application.register('uk-only', UkOnlyController)

  beforeEach(() => document.body.innerHTML = template)

  describe('visibility', () => {
    describe('when in UK', () => {
      beforeEach(() => {
        jest.spyOn(UkOnlyController.prototype, 'timeZone')
            .mockImplementationOnce(() => 'Europe/London')
      })

      it('shows pre content', () => {
        expect(document.querySelector('p.pre').textContent).toBe('Some Content')
      })

      it('shows content to hide', () => {
        expect(document.querySelector('p.to-hide').textContent).toBe('Hidden Content')
      })
    })

    describe('when outside UK', () => {
      beforeEach(() => {
        jest.spyOn(UkOnlyController.prototype, 'timeZone')
            .mockImplementationOnce(() => 'Europe/Paris')
      })

      it('shows pre content', () => {
        expect(document.querySelector('p.pre').textContent).toBe('Some Content')
      })

      it('hides content to hide', () => {
        expect(document.querySelector('p.to-hide')).toBeNull()
      })
    })
  })
})
