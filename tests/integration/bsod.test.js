const request = require('supertest');
const app = require('../../src/server');

describe('BSOD Routes Integration Tests', () => {
  describe('GET /', () => {
    test('should render BSOD page with default style', async () => {
      const response = await request(app)
        .get('/')
        .expect(200)
        .expect('Content-Type', /html/);

      expect(response.text).toContain(':(');
    });

    test('should accept style parameter', async () => {
      const styles = ['win10', 'win11', 'win7', 'winxp'];

      for (const style of styles) {
        const response = await request(app)
          .get(`/?style=${style}`)
          .expect(200);

        expect(response.text).toBeTruthy();
      }
    });

    test('should accept custom error code', async () => {
      const response = await request(app)
        .get('/?code=COFFEE_NOT_FOUND')
        .expect(200);

      expect(response.text).toContain('COFFEE_NOT_FOUND');
    });

    test('should accept custom message', async () => {
      const customMessage = 'This is a custom error message';
      const response = await request(app)
        .get(`/?message=${encodeURIComponent(customMessage)}`)
        .expect(200);

      expect(response.text).toContain(customMessage);
    });

    test('should accept custom technical detail', async () => {
      const customTech = 'Custom technical detail';
      const response = await request(app)
        .get(`/?technical=${encodeURIComponent(customTech)}`)
        .expect(200);

      expect(response.text).toContain(customTech);
    });

    test('should accept custom percentage', async () => {
      const response = await request(app)
        .get('/?percentage=75')
        .expect(200);

      expect(response.text).toContain('75');
    });

    test('should handle multiple parameters', async () => {
      const response = await request(app)
        .get('/?style=win10&code=COFFEE_NOT_FOUND&percentage=42')
        .expect(200);

      expect(response.text).toContain('COFFEE_NOT_FOUND');
      expect(response.text).toContain('42');
    });
  });

  describe('GET /random', () => {
    test('should redirect to a style', async () => {
      const response = await request(app)
        .get('/random')
        .expect(302);

      expect(response.header.location).toMatch(/\?style=(win10|win11|win7|winxp)/);
    });

    test('should redirect to different styles', async () => {
      const redirects = await Promise.all([
        request(app).get('/random'),
        request(app).get('/random'),
        request(app).get('/random'),
        request(app).get('/random'),
        request(app).get('/random'),
      ]);

      const locations = redirects.map(r => r.header.location);
      const uniqueLocations = new Set(locations);

      // With 5 tries, we should get at least some variety
      // (unless we're very unlucky with a 4-choice random)
      expect(uniqueLocations.size).toBeGreaterThan(1);
    });
  });

  describe('404 handling', () => {
    test('should return 404 for unknown routes', async () => {
      const response = await request(app)
        .get('/unknown-route')
        .expect(404)
        .expect('Content-Type', /json/);

      expect(response.body.error).toBeTruthy();
    });
  });
});
