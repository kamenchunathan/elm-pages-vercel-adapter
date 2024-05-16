import assert from 'assert';

import { pathPatternToGlobPattern } from "../index.js";

describe('root', function() {
  assert.equal(pathPatternToGlobPattern("/"), "/")
})

describe('static segments', function() {
  assert.equal(pathPatternToGlobPattern("/blog"), "/blog")
})

describe('single dynamic segment', function() {
  assert.equal(pathPatternToGlobPattern("/blog/:slug"), "/blog/*")
})

describe('multiple dynamic segments', function() {
  assert.equal(pathPatternToGlobPattern("/foo/:bar/:baz"), "/foo/*/*")
})
