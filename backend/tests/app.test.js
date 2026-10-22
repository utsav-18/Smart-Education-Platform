const test = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');

const app = require('../app');
const Course = require('../models/Course');

test('GET /health returns HTTP 200', async () => {
  const response = await request(app).get('/health');

  assert.equal(response.status, 200);
  assert.deepEqual(response.body, { status: 'ok' });
});

test('GET /api/courses returns courses from the model', async () => {
  const originalFind = Course.find;
  const courses = [
    { _id: 'course-1', title: 'Web Development', instructor: 'A. Teacher' },
  ];

  Course.find = () => ({
    sort: async () => courses,
  });

  try {
    const response = await request(app).get('/api/courses');

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, courses);
  } finally {
    Course.find = originalFind;
  }
});

test('GET /api/courses/:id returns HTTP 404 for a nonexistent course', async () => {
  const originalFindById = Course.findById;
  Course.findById = async () => null;

  try {
    const response = await request(app).get(
      '/api/courses/507f1f77bcf86cd799439011',
    );

    assert.equal(response.status, 404);
    assert.equal(response.body.error, 'Course not found');
  } finally {
    Course.findById = originalFindById;
  }
});

test('POST /api/courses rejects invalid course data', async () => {
  const response = await request(app).post('/api/courses').send({
    title: '',
    instructor: 42,
  });

  assert.equal(response.status, 400);
  assert.match(response.body.error, /required strings/);
});
