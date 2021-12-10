import { Application } from 'stimulus' ;
import HelloController from 'hello_controller.js' ;

describe('HelloController', () => {
  const template = `
    <div data-controller="hello">
      <h1 data-hello-target="output"></h1>
    </div>
  `

  const application = Application.start()
  application.register('hello', HelloController) ;

  beforeEach(() => document.body.innerHTML = template)

  describe("initialising behaviour", () => {
    it("should Set name", () => {
      const h1 = document.querySelector('h1')

      expect(h1.textContent).toBe('Hello, Stimulus!')
    })
  })
})
