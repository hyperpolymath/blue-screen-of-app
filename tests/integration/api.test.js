const request = require('supertest');
const app = require('../../src/server');

describe('API Routes Integration Tests', () => {
  describe('GET /api/error', () => {
    test('should return random error data', async () => {
      const response = await request(app)
        .get('/api/error')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('stopCode');
      expect(response.body.data).toHaveProperty('description');
      expect(response.body.data).toHaveProperty('technicalDetail');
      expect(response.body.data).toHaveProperty('percentage');
    });

    test('should return different errors on multiple requests', async () => {
      const responses = await Promise.all([
        request(app).get('/api/error'),
        request(app).get('/api/error'),
        request(app).get('/api/error'),
        request(app).get('/api/error'),
        request(app).get('/api/error'),
      ]);

      const codes = responses.map(r => r.body.data.stopCode);
      const uniqueCodes = new Set(codes);

      // Should get at least some variety
      expect(uniqueCodes.size).toBeGreaterThan(1);
    });
  });

  describe('GET /api/error/:code', () => {
    test('should return specific error by code', async () => {
      const response = await request(app)
        .get('/api/error/COFFEE_NOT_FOUND')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data.stopCode).toBe('COFFEE_NOT_FOUND');
    });

    test('should handle lowercase codes', async () => {
      const response = await request(app)
        .get('/api/error/coffee-not-found')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data.stopCode).toBe('COFFEE_NOT_FOUND');
    });

    test('should return 404 for invalid code', async () => {
      const response = await request(app)
        .get('/api/error/INVALID_CODE_XYZ')
        .expect(404)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeTruthy();
      expect(response.body.availableCodes).toBeTruthy();
    });
  });

  describe('GET /api/codes', () => {
    test('should return list of error codes', async () => {
      const response = await request(app)
        .get('/api/codes')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data.codes).toBeInstanceOf(Array);
      expect(response.body.data.codes.length).toBeGreaterThan(0);
      expect(response.body.data.count).toBeGreaterThan(0);
    });

    test('should include humorous codes', async () => {
      const response = await request(app)
        .get('/api/codes')
        .expect(200);

      expect(response.body.data.codes).toContain('COFFEE_NOT_FOUND');
      expect(response.body.data.codes).toContain('PRODUCTION_DEPLOYMENT_ON_FRIDAY');
    });
  });

  describe('GET /api/styles', () => {
    test('should return list of available styles', async () => {
      const response = await request(app)
        .get('/api/styles')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data.styles).toBeInstanceOf(Array);
      expect(response.body.data.styles).toContain('win10');
      expect(response.body.data.styles).toContain('winxp');
      expect(response.body.data.default).toBe('win10');
    });
  });

  describe('GET /api/analytics', () => {
    test('should return analytics summary', async () => {
      const response = await request(app)
        .get('/api/analytics')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('totalVisits');
      expect(response.body.data).toHaveProperty('apiCalls');
      expect(response.body.data).toHaveProperty('uptime');
    });

    test('should track API calls', async () => {
      // Make a few API calls
      await request(app).get('/api/error');
      await request(app).get('/api/error');

      const response = await request(app).get('/api/analytics');

      expect(response.body.data.apiCalls).toBeGreaterThan(0);
    });
  });

  describe('GET /api/health', () => {
    test('should return health status', async () => {
      const response = await request(app)
        .get('/api/health')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body.success).toBe(true);
      expect(response.body.status).toBe('healthy');
      expect(response.body.timestamp).toBeTruthy();
      expect(response.body.uptime).toBeTruthy();
      expect(response.body.version).toBeTruthy();
    });
  });

  describe('GET /api/metrics', () => {
    test('should return Prometheus-style metrics', async () => {
      const response = await request(app)
        .get('/api/metrics')
        .expect(200)
        .expect('Content-Type', /text\/plain/);

      expect(response.text).toContain('bsod_total_visits');
      expect(response.text).toContain('bsod_api_calls');
      expect(response.text).toContain('bsod_uptime_seconds');
    });
  });

  describe('POST /api/analytics/reset', () => {
    test('should not work in production', async () => {
      const oldEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'production';

      const response = await request(app)
        .post('/api/analytics/reset')
        .expect(403);

      expect(response.body.success).toBe(false);

      process.env.NODE_ENV = oldEnv;
    });

    test('should work in development', async () => {
      const oldEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'development';

      const response = await request(app)
        .post('/api/analytics/reset')
        .expect(200);

      expect(response.body.success).toBe(true);

      process.env.NODE_ENV = oldEnv;
    });
  });
});
