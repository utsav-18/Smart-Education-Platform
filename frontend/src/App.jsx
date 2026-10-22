import React, { useEffect, useState } from 'react';

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000';

function App() {
  const [courses, setCourses] = useState([]);
  const [status, setStatus] = useState('loading');
  const [error, setError] = useState('');

  useEffect(() => {
    async function loadCourses() {
      try {
        const response = await fetch(`${apiBaseUrl}/api/courses`);
        if (!response.ok) {
          throw new Error(`Request failed with status ${response.status}`);
        }

        setCourses(await response.json());
        setStatus('ready');
      } catch (requestError) {
        console.error(requestError);
        setError('Courses are unavailable right now. Please try again later.');
        setStatus('error');
      }
    }

    loadCourses();
  }, []);

  return (
    <div className="app-shell">
      <header className="site-header">
        <div>
          <p className="eyebrow">Learn. Grow. Succeed.</p>
          <h1>Smart Education Platform</h1>
        </div>
        <span className="status-indicator" aria-label="Platform status">
          Local dashboard
        </span>
      </header>

      <main>
        <section className="summary-card" aria-labelledby="summary-title">
          <div>
            <p className="eyebrow">Your learning dashboard</p>
            <h2 id="summary-title">Available courses</h2>
          </div>
          <strong className="course-count">
            {status === 'ready' ? courses.length : '--'}
          </strong>
        </section>

        <section className="courses-section" aria-labelledby="courses-title">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Explore your options</p>
              <h2 id="courses-title">Course catalogue</h2>
            </div>
          </div>

          {status === 'loading' && (
            <p className="message" role="status">
              Loading courses...
            </p>
          )}

          {status === 'error' && (
            <p className="message error-message" role="alert">
              {error}
            </p>
          )}

          {status === 'ready' && courses.length === 0 && (
            <p className="message">
              No courses are available yet. Check back soon for new learning
              opportunities.
            </p>
          )}

          {status === 'ready' && courses.length > 0 && (
            <div className="course-grid">
              {courses.map((course) => (
                <article className="course-card" key={course._id}>
                  <div className="course-card-top">
                    <span className="course-tag">Course</span>
                    {course.duration && (
                      <span className="duration">{course.duration}</span>
                    )}
                  </div>
                  <h3>{course.title}</h3>
                  <p className="instructor">With {course.instructor}</p>
                  <p className="description">
                    {course.description || 'Build practical skills for your future.'}
                  </p>
                </article>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;
