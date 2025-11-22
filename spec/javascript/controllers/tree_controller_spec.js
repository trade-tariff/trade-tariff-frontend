import {Application} from '@hotwired/stimulus';
import TreeController from '../../../app/javascript/controllers/tree_controller';
import fs from 'fs';
import path from 'path';

describe('TreeController', () => {
  const fixturePath = path.join(__dirname, '__fixtures__', 'tree_controller', 'domSnippet.html');
  const html = fs.readFileSync(fixturePath, 'utf-8');
  let application;
  let element;
  let controllerInstance;

  beforeEach(() => {
    element = document.createElement('div');
    element.setAttribute('data-controller', 'tree');
    element.innerHTML = html;

    document.body.appendChild(element);

    application = Application.start();
    application.register('tree', TreeController);
  });

  afterEach(() => {
    application.unload();
    document.body.innerHTML = '';
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
    it('initializes the tree with all nodes closed by default', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');
      expect(controllerInstance.parentNodeTargets.length).toEqual(3);
      expect(controllerInstance.commodityNodeTargets.length).toEqual(3);
      expect(controllerInstance.commodityInfoTargets.length).toEqual(5);
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('false');
        const childList = commodityNode.parentElement.querySelector('ul');
        expect(childList.getAttribute('aria-hidden')).toEqual('true');
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
    it('opens all nodes recursively', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Verify initial state is closed
      controllerInstance.commodityNodeTargets.forEach((commodityNode) => {
        expect(commodityNode.getAttribute('aria-expanded')).toEqual('false');
        const childList = commodityNode.parentElement.querySelector('ul');
        expect(childList.getAttribute('aria-hidden')).toEqual('true');
      });

      // Open all nodes recursively
      controllerInstance.openAllTarget.click();

      // Verify all nodes (including nested ones) are opened
      const allParentNodes = element.querySelectorAll('[data-tree-target="parentNode"]');
      allParentNodes.forEach((parentNode) => {
        const commodityNode = parentNode.querySelector('[data-tree-target="commodityNode"]');
        const childList = parentNode.querySelector('ul');
        if (commodityNode && childList) {
          expect(commodityNode.getAttribute('aria-expanded')).toEqual('true');
          expect(childList.getAttribute('aria-hidden')).toEqual('false');
          expect(commodityNode.classList.contains('open')).toEqual(true);
        }
      });
    });
  });

  describe('closeAll', () => {
    it('closes all nodes recursively', () => {
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'tree');

      // Open all nodes first
      controllerInstance.openAllTarget.click();
      const allParentNodesAfterOpen = element.querySelectorAll('[data-tree-target="parentNode"]');
      allParentNodesAfterOpen.forEach((parentNode) => {
        const commodityNode = parentNode.querySelector('[data-tree-target="commodityNode"]');
        const childList = parentNode.querySelector('ul');
        if (commodityNode && childList) {
          expect(commodityNode.getAttribute('aria-expanded')).toEqual('true');
          expect(childList.getAttribute('aria-hidden')).toEqual('false');
        }
      });

      // Close all nodes recursively
      controllerInstance.closeAllTarget.click();

      // Verify all nodes (including nested ones) are closed
      const allParentNodes = element.querySelectorAll('[data-tree-target="parentNode"]');
      allParentNodes.forEach((parentNode) => {
        const commodityNode = parentNode.querySelector('[data-tree-target="commodityNode"]');
        const childList = parentNode.querySelector('ul');
        if (commodityNode && childList) {
          expect(commodityNode.getAttribute('aria-expanded')).toEqual('false');
          expect(childList.getAttribute('aria-hidden')).toEqual('true');
          expect(commodityNode.classList.contains('open')).toEqual(false);
        }
      });
    });
  });
});
