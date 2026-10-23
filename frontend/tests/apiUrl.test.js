import test from 'node:test';
import assert from 'node:assert/strict';
import { getCoursesUrl } from '../src/apiUrl.js';

test('uses the same-origin API path when no base URL is configured', () => {
  assert.equal(getCoursesUrl(undefined), '/api/courses');
});

test('uses the local backend URL for development', () => {
  assert.equal(
    getCoursesUrl('http://localhost:5000'),
    'http://localhost:5000/api/courses',
  );
});

test('does not duplicate the API path', () => {
  assert.equal(getCoursesUrl('/api'), '/api/courses');
  assert.equal(
    getCoursesUrl('https://api.example.com/api/'),
    'https://api.example.com/api/courses',
  );
});
