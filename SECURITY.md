# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Blue Screen of App seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Where to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of these methods:

1. **Preferred**: Use GitHub's private vulnerability reporting feature
2. **Email**: Send details to [security contact - update with actual email]
3. **Security.txt**: See `.well-known/security.txt` for additional contact methods

### What to Include

Please include the following information in your report:

- Type of vulnerability (e.g., XSS, injection, authentication bypass)
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days
  - Low: 60-90 days

### What to Expect

1. **Acknowledgment**: We'll confirm receipt of your vulnerability report
2. **Investigation**: We'll investigate and validate the report
3. **Resolution**: We'll develop and test a fix
4. **Disclosure**: We'll coordinate disclosure timing with you
5. **Credit**: We'll credit you in the security advisory (unless you prefer anonymity)

## Security Measures

### Current Security Features

1. **Helmet.js**: Security headers (XSS protection, MIME sniffing prevention)
2. **Rate Limiting**: API endpoints limited to 100 requests per 15 minutes per IP
3. **CORS**: Configurable cross-origin resource sharing
4. **Input Validation**: All query parameters sanitized
5. **Error Handling**: No sensitive information leaked in error responses
6. **Dependencies**: Zero npm dependencies, pure Deno
7. **Container Security**: Rootless Podman, minimal base image
8. **No Secrets**: No hardcoded credentials or API keys

### Security Best Practices

When using this application:

1. **Environment Variables**: Never commit `.env` files with secrets
2. **HTTPS**: Always use HTTPS in production
3. **Updates**: Keep Deno updated (`deno upgrade`)
4. **Logging**: Review logs regularly for suspicious activity
5. **Rate Limiting**: Adjust rate limits based on your traffic patterns
6. **CORS**: Restrict origins in production environments

## Known Security Considerations

### Non-Issues (By Design)

1. **No Authentication**: This is a public demo application
2. **Open CORS**: Default allows all origins (configure for production)
3. **No Data Storage**: No user data is stored or transmitted
4. **Humorous Content**: Error messages are jokes, not real system errors

### Potential Risks

1. **Phishing**: Could be used in social engineering attacks
   - **Mitigation**: Clear documentation that this is a demo/joke app

2. **Resource Exhaustion**: API calls could consume server resources
   - **Mitigation**: Rate limiting enabled by default

3. **XSS in Custom Messages**: Custom error messages rendered in HTML
   - **Mitigation**: EJS auto-escapes all variables

## Security Audit History

| Date | Auditor | Scope | Findings | Status |
|------|---------|-------|----------|--------|
| 2025-01-15 | Internal | Initial Security Review | 0 Critical, 0 High | Resolved |

## Compliance

- **OWASP Top 10**: Addressed in design
- **CWE Top 25**: No known vulnerabilities
- **RFC 9116**: security.txt implemented

## Attribution

We follow coordinated disclosure and will credit security researchers who report vulnerabilities responsibly.

### Hall of Fame

_(No reports yet - this section will be updated as security researchers contribute)_

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)

## Policy Updates

This security policy is reviewed quarterly and updated as needed. Last update: 2025-01-15

---

**Remember**: This is a demonstration application for humorous purposes. While we take security seriously, please use common sense when deploying or customizing it.
