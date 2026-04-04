const Analytics = require('../../src/utils/analytics');

// Mock the config
jest.mock('../../src/config', () => ({
  features: {
    analytics: true,
  },
}));

// Mock the logger
jest.mock('../../src/utils/logger', () => ({
  debug: jest.fn(),
  info: jest.fn(),
}));

describe('Analytics Utility', () => {
  beforeEach(() => {
    // Reset analytics before each test
    Analytics.reset();
  });

  describe('trackVisit', () => {
    test('should increment total visits', () => {
      Analytics.trackVisit();
      const summary = Analytics.getSummary();

      expect(summary.totalVisits).toBe(1);
    });

    test('should track style views', () => {
      Analytics.trackVisit('win10');
      Analytics.trackVisit('win10');
      Analytics.trackVisit('winxp');

      const summary = Analytics.getSummary();

      expect(summary.styleViews.win10).toBe(2);
      expect(summary.styleViews.winxp).toBe(1);
    });

    test('should track error code views', () => {
      Analytics.trackVisit('win10', 'COFFEE_NOT_FOUND');
      Analytics.trackVisit('win10', 'COFFEE_NOT_FOUND');
      Analytics.trackVisit('win10', 'NPM_INSTALL_TIMEOUT');

      const summary = Analytics.getSummary();

      expect(summary.errorCodeViews.COFFEE_NOT_FOUND).toBe(2);
      expect(summary.errorCodeViews.NPM_INSTALL_TIMEOUT).toBe(1);
    });

    test('should track custom messages', () => {
      Analytics.trackVisit('win10', null, true);
      Analytics.trackVisit('win10', null, true);
      Analytics.trackVisit('win10', null, false);

      const summary = Analytics.getSummary();

      expect(summary.customMessageCount).toBe(2);
    });
  });

  describe('trackApiCall', () => {
    test('should increment API calls', () => {
      Analytics.trackApiCall();
      Analytics.trackApiCall();

      const summary = Analytics.getSummary();

      expect(summary.apiCalls).toBe(2);
    });
  });

  describe('getSummary', () => {
    test('should return complete summary', () => {
      Analytics.trackVisit('win10', 'COFFEE_NOT_FOUND', true);
      Analytics.trackApiCall();

      const summary = Analytics.getSummary();

      expect(summary).toHaveProperty('totalVisits');
      expect(summary).toHaveProperty('styleViews');
      expect(summary).toHaveProperty('errorCodeViews');
      expect(summary).toHaveProperty('customMessageCount');
      expect(summary).toHaveProperty('apiCalls');
      expect(summary).toHaveProperty('uptime');
    });

    test('should include uptime information', () => {
      const summary = Analytics.getSummary();

      expect(summary.uptime).toHaveProperty('ms');
      expect(summary.uptime).toHaveProperty('seconds');
      expect(summary.uptime).toHaveProperty('minutes');
      expect(summary.uptime).toHaveProperty('hours');
      expect(summary.uptime).toHaveProperty('human');
    });

    test('should have valid uptime values', () => {
      const summary = Analytics.getSummary();

      expect(summary.uptime.ms).toBeGreaterThanOrEqual(0);
      expect(summary.uptime.seconds).toBeGreaterThanOrEqual(0);
      expect(typeof summary.uptime.human).toBe('string');
    });
  });

  describe('reset', () => {
    test('should reset all counters', () => {
      Analytics.trackVisit('win10', 'COFFEE_NOT_FOUND', true);
      Analytics.trackApiCall();

      Analytics.reset();

      const summary = Analytics.getSummary();

      expect(summary.totalVisits).toBe(0);
      expect(summary.apiCalls).toBe(0);
      expect(summary.customMessageCount).toBe(0);
      expect(Object.keys(summary.styleViews).length).toBe(0);
      expect(Object.keys(summary.errorCodeViews).length).toBe(0);
    });
  });
});
