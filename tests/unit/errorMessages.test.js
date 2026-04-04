const { getRandomError, getErrorByCode, errorMessages } = require('../../src/utils/errorMessages');

describe('Error Messages Utility', () => {
  describe('getRandomError', () => {
    test('should return a valid error object', () => {
      const error = getRandomError();

      expect(error).toHaveProperty('stopCode');
      expect(error).toHaveProperty('description');
      expect(error).toHaveProperty('technicalDetail');
      expect(error).toHaveProperty('qrMessage');
      expect(error).toHaveProperty('percentage');
    });

    test('should return percentage between 0 and 100', () => {
      const error = getRandomError();

      expect(error.percentage).toBeGreaterThanOrEqual(0);
      expect(error.percentage).toBeLessThanOrEqual(100);
    });

    test('should return a valid stop code from the list', () => {
      const error = getRandomError();

      expect(errorMessages.stopCodes).toContain(error.stopCode);
    });

    test('should return different errors on multiple calls', () => {
      const errors = Array.from({ length: 10 }, () => getRandomError());
      const uniqueCodes = new Set(errors.map(e => e.stopCode));

      // With 10 calls, we should get at least a few different codes
      // (unless we're very unlucky)
      expect(uniqueCodes.size).toBeGreaterThan(1);
    });
  });

  describe('getErrorByCode', () => {
    test('should return correct error for valid code', () => {
      const code = 'COFFEE_NOT_FOUND';
      const error = getErrorByCode(code);

      expect(error).not.toBeNull();
      expect(error.stopCode).toBe(code);
    });

    test('should handle lowercase and dashes', () => {
      const error = getErrorByCode('coffee-not-found');

      expect(error).not.toBeNull();
      expect(error.stopCode).toBe('COFFEE_NOT_FOUND');
    });

    test('should return null for invalid code', () => {
      const error = getErrorByCode('INVALID_CODE_XYZ');

      expect(error).toBeNull();
    });

    test('should return description for known codes', () => {
      const error = getErrorByCode('COFFEE_NOT_FOUND');

      expect(error.description).toBeTruthy();
      expect(typeof error.description).toBe('string');
    });
  });

  describe('errorMessages data structure', () => {
    test('should have humorous error codes', () => {
      expect(errorMessages.stopCodes).toContain('COFFEE_NOT_FOUND');
      expect(errorMessages.stopCodes).toContain('STACKOVERFLOW_COPY_PASTE_ERROR');
      expect(errorMessages.stopCodes).toContain('PRODUCTION_DEPLOYMENT_ON_FRIDAY');
    });

    test('should have descriptions for custom codes', () => {
      expect(errorMessages.descriptions).toHaveProperty('COFFEE_NOT_FOUND');
      expect(errorMessages.descriptions).toHaveProperty('NPM_INSTALL_TIMEOUT');
    });

    test('should have multiple technical details', () => {
      expect(errorMessages.technicalDetails.length).toBeGreaterThan(0);
      expect(Array.isArray(errorMessages.technicalDetails)).toBe(true);
    });

    test('should have QR messages', () => {
      expect(errorMessages.qrMessages.length).toBeGreaterThan(0);
      expect(Array.isArray(errorMessages.qrMessages)).toBe(true);
    });
  });
});
