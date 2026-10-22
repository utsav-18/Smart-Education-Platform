require('dotenv').config();

const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Course = require('../models/Course');

const sampleCourses = [
  {
    title: 'Full-Stack Web Development',
    description:
      'Build responsive web applications with modern JavaScript, React, Node.js, and Express.',
    instructor: 'Dr. Priya Sharma',
    duration: '12 weeks',
  },
  {
    title: 'Data Structures and Algorithms',
    description:
      'Strengthen problem-solving skills by learning core data structures, algorithms, and complexity analysis.',
    instructor: 'Prof. Arjun Mehta',
    duration: '10 weeks',
  },
  {
    title: 'Cloud Computing Fundamentals',
    description:
      'Understand cloud architecture, virtual infrastructure, storage, networking, and deployment fundamentals.',
    instructor: 'Dr. Neha Kapoor',
    duration: '8 weeks',
  },
  {
    title: 'Applied Machine Learning',
    description:
      'Explore supervised learning, model evaluation, feature engineering, and practical machine learning workflows.',
    instructor: 'Prof. Rohan Iyer',
    duration: '14 weeks',
  },
  {
    title: 'Cybersecurity Essentials',
    description:
      'Learn the principles of secure systems, common vulnerabilities, identity management, and incident response.',
    instructor: 'Dr. Kavita Rao',
    duration: '8 weeks',
  },
];

async function seedCourses() {
  await connectDB();
  await mongoose.connection.db.admin().ping();
  console.log('MongoDB connection verified');

  const operations = sampleCourses.map((course) => ({
    updateOne: {
      filter: {
        title: course.title,
        instructor: course.instructor,
      },
      update: { $set: course },
      upsert: true,
    },
  }));

  const result = await Course.bulkWrite(operations);
  console.log(
    `Seed complete: ${result.upsertedCount} inserted, ${result.modifiedCount} updated, ${result.matchedCount} already current`,
  );
}

seedCourses()
  .catch((error) => {
    console.error('Course seed failed:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.disconnect();
  });
