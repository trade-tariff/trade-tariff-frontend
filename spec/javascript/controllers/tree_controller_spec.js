import {Application} from '@hotwired/stimulus';
import TreeController from '../../../app/javascript/controllers/tree_controller';
import CookieManager from '../../../app/javascript/src/cookie-manager';
import fs from 'fs';
import path from 'path';
import Cookies from 'js-cookie';

describe('TreeController', () => {
  const fixturePath = path.join(__dirname, '__fixtures__', 'tree_controller', 'domSnippet.html');
  const html = fs.readFileSync(fixturePath, 'utf-8');
  let application;
  let cookieManager;
  let element;
  let controllerInstance;

  function resetCookies() {
    const allCookies = Cookies.get();
    for (const cookieName in allCookies) {
      if (Object.prototype.hasOwnProperty.call(allCookies, cookieName)) {
        Cookies.remove(cookieName);
      }
    }
  }

  beforeEach(() => {
    cookieManager = new CookieManager();

    element = document.createElement('div');
    element.setAttribute('data-controller', 'tree');
    element.innerHTML = html;

    document.body.appendChild(element);

    application = Application.start();
    application.register('tree', TreeController);
    cookieManager.setCookiesPolicy();
  });

  afterEach(() => {
    application.unload();
    document.body.innerHTML = '';
    resetCookies();
  });

  describe('toggleNode', () => {
    it('enables toggling opening and closing of nodes', async () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const commodityNode = controllerInstance.commodityNodeTargets[0];
      const childList = commodityNode.parentElement.querySelector('ul');
      childList.setAttribute('aria-hidden', 'true');
      expect(childList.getAttribute('aria-hidden')).toEqual('true');
      commodityNode.click();
      expect(childList.getAttribute('aria-hidden')).toEqual('false');
    });
  });

  describe('connect', () => {
    it('initializes the tree and marks all nodes as open by default', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      expect(controllerInstance.parentNodeTargets.length).toEqual(3);
      expect(controllerInstance.commodityNodeTargets.length).toEqual(3);
      expect(controllerInstance.commodityInfoTargets.length).toEqual(5);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('true');
      });
    });
  });

  describe('hoverOnNode', () => {
    it('adds a class to the hovered node', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const commodityNode = controllerInstance.commodityNodeTargets[0];
      expect(commodityNode.classList.contains('description-hover')).toEqual(false);
      commodityNode.dispatchEvent(new MouseEvent('mouseenter'));
      expect(commodityNode.classList.contains('description-hover')).toEqual(true);
    });
  });

  describe('hoverOffNode', () => {
    it('removes a class from the hovered node', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const commodityNode = controllerInstance.commodityNodeTargets[0];
      commodityNode.classList.add('description-hover');
      expect(commodityNode.classList.contains('description-hover')).toEqual(true);
      commodityNode.dispatchEvent(new MouseEvent('mouseleave'));
      expect(commodityNode.classList.contains('description-hover')).toEqual(false);
    });
  });

  describe('openAll', () => {
    it('opens all nodes', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Close all nodes
      controllerInstance.closeAllTarget.click();
      expect(cookieManager.shouldOpenTree()).toEqual(false);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('false');
      });

      // Open all nodes
      controllerInstance.openAllTarget.click();
      expect(cookieManager.shouldOpenTree()).toEqual(true);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('true');
      });
    });
  });

  describe('closeAll', () => {
    it('closes all nodes', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Open all nodes
      controllerInstance.openAllTarget.click();
      expect(cookieManager.shouldOpenTree()).toEqual(true);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('true');
      });

      // Close all nodes
      controllerInstance.closeAllTarget.click();
      expect(cookieManager.shouldOpenTree()).toEqual(false);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('false');
      });
    });
  });
});
