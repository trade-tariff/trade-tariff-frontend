// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import '@stimulus/polyfills';
import {Application} from 'stimulus';
import {definitionsFromContext} from 'stimulus/webpack-helpers';

const application = Application.start();
const context = require.context('controllers', true, /_controller\.js$/);
application.load(definitionsFromContext(context));

// enable Stimulus debug mode in development
application.debug = process.env.NODE_ENV === 'development';
