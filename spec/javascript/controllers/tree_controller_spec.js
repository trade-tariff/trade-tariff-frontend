import {
  Application,
} from '@hotwired/stimulus';
import TreeController from 'tree_controller';
import CookieManager from 'cookie-manager';
import fs from 'fs';
import path from 'path';

describe('TreeController', () => {
  const fixturePath = path.join(__dirname, '__fixtures__', 'tree_controller', 'domSnippet.html');
  const html = fs.readFileSync(fixturePath, 'utf-8');
  let application;
  let cookieManager;
  let element;
  let controllerInstance;

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
    document.body.removeChild(element);
  });

  describe('connect', () => {
    it('initializes the tree and marks all nodes as open by default', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      expect(controllerInstance.parentNodeTargets.length).toEqual(1);
      expect(controllerInstance.branchSwitchTargets.length).toEqual(2);
      expect(controllerInstance.commodityInfoTargets.length).toEqual(3);
      controllerInstance.branchSwitchTargets.forEach((branchSwitch) => {
        expect(branchSwitch.getAttribute('aria-expanded')).toEqual('true');
      });
    });
  });

  describe('toggleNode', () => {
    it('enables toggling opening and closing of nodes', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const branchSwitch = controllerInstance.branchSwitchTargets[0];
      const childList = branchSwitch.parentElement.querySelector('ul');
      expect(childList.getAttribute('aria-hidden')).toEqual('false');
      branchSwitch.click();
      expect(childList.getAttribute('aria-hidden')).toEqual('true');
    });
  });

  describe('hoverOnNode', () => {
    it('adds a class to the hovered node', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const branchSwitch = controllerInstance.branchSwitchTargets[0];
      expect(branchSwitch.classList.contains('description-hover')).toEqual(false);
      branchSwitch.dispatchEvent(new MouseEvent('mouseenter'));
      expect(branchSwitch.classList.contains('description-hover')).toEqual(true);
    });
  });

  describe('hoverOffNode', () => {
    it('removes a class from the hovered node', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      const branchSwitch = controllerInstance.branchSwitchTargets[0];
      branchSwitch.classList.add('description-hover');
      expect(branchSwitch.classList.contains('description-hover')).toEqual(true);
      branchSwitch.dispatchEvent(new MouseEvent('mouseleave'));
      expect(branchSwitch.classList.contains('description-hover')).toEqual(false);
    });
  });

  describe('openAll', () => {
    it('opens all nodes', async () => { // Declare the test function as async
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Close all nodes
      controllerInstance.closeAllTarget.click();
      await new Promise((resolve) => setTimeout(resolve, 100));
      expect(cookieManager.shouldOpenTree()).toEqual(false);
      controllerInstance.branchSwitchTargets.forEach((branchSwitch) => {
        expect(branchSwitch.getAttribute('aria-expanded')).toEqual('false');
      });

      // Open all nodes
      controllerInstance.openAllTarget.click();
      await new Promise((resolve) => setTimeout(resolve, 100));
      expect(cookieManager.shouldOpenTree()).toEqual(true);
      controllerInstance.branchSwitchTargets.forEach((branchSwitch) => {
        expect(branchSwitch.getAttribute('aria-expanded')).toEqual('true');
      });
    });
  });

  describe('closeAll', () => {
    it('closes all nodes', async () => { // Declare the test function as async
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Open all nodes
      controllerInstance.openAllTarget.click();
      await new Promise((resolve) => setTimeout(resolve, 100));
      expect(cookieManager.shouldOpenTree()).toEqual(true);
      controllerInstance.branchSwitchTargets.forEach((branchSwitch) => {
        expect(branchSwitch.getAttribute('aria-expanded')).toEqual('true');
      });

      // Close all nodes
      controllerInstance.closeAllTarget.click();
      await new Promise((resolve) => setTimeout(resolve, 100));
      expect(cookieManager.shouldOpenTree()).toEqual(false);
      controllerInstance.branchSwitchTargets.forEach((branchSwitch) => {
        expect(branchSwitch.getAttribute('aria-expanded')).toEqual('false');
      });
    });
  });
});
