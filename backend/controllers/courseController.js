const mongoose = require('mongoose');
const Course = require('../models/Course');

function getCourseInput(body) {
  const { title, description, instructor, duration } = body;

  if (
    typeof title !== 'string' ||
    !title.trim() ||
    typeof instructor !== 'string' ||
    !instructor.trim()
  ) {
    return null;
  }

  if (
    (description !== undefined && typeof description !== 'string') ||
    (duration !== undefined && typeof duration !== 'string')
  ) {
    return null;
  }

  return {
    title: title.trim(),
    instructor: instructor.trim(),
    ...(description !== undefined && { description: description.trim() }),
    ...(duration !== undefined && { duration: duration.trim() }),
  };
}

async function getCourses(req, res, next) {
  try {
    const courses = await Course.find().sort({ createdAt: -1 });
    res.json(courses);
  } catch (error) {
    next(error);
  }
}

async function getCourseById(req, res, next) {
  if (!mongoose.isValidObjectId(req.params.id)) {
    return res.status(404).json({ error: 'Course not found' });
  }

  try {
    const course = await Course.findById(req.params.id);

    if (!course) {
      return res.status(404).json({ error: 'Course not found' });
    }

    return res.json(course);
  } catch (error) {
    return next(error);
  }
}

async function createCourse(req, res, next) {
  const courseInput = getCourseInput(req.body);

  if (!courseInput) {
    return res.status(400).json({
      error: 'title and instructor are required strings; description and duration must be strings',
    });
  }

  try {
    const course = await Course.create(courseInput);
    return res.status(201).json(course);
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({ error: 'Invalid course data' });
    }

    return next(error);
  }
}

module.exports = {
  getCourses,
  getCourseById,
  createCourse,
};
