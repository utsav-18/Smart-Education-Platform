export function getCoursesUrl(apiBaseUrl) {
  if (!apiBaseUrl) {
    return '/api/courses';
  }

  const normalizedBaseUrl = apiBaseUrl.replace(/\/+$/, '');

  if (normalizedBaseUrl.endsWith('/api')) {
    return `${normalizedBaseUrl}/courses`;
  }

  return `${normalizedBaseUrl}/api/courses`;
}
