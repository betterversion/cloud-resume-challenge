# 🌐 Day 7: API Gateway Deep Dive - From Lambda Function to Professional API

## 🎯 The Missing Link Problem

I had a working Lambda function that could handle visitor counting and health checks, but it was basically invisible to the outside world. Lambda functions don't get public URLs by default - they're just code waiting to be triggered by something else.

Enter API Gateway, the service that turns serverless functions into proper web APIs. What I thought would be a simple "connect Lambda to internet" task turned into a comprehensive lesson in REST API design, CORS security, SSL certificates, and enterprise monitoring.

Time to build an API that wouldn't embarrass me in front of hiring managers.

---

## 🏗️ REST API Architecture: One Gateway, Multiple Endpoints

My first design decision was API structure. I could create separate API Gateways for the counter and health endpoints, but that felt like overkill. Instead, I built a single REST API with logical resource hierarchy:

```
resume-visitor-api-prod
├── /counter  (visitor counter business logic)
└── /health   (operational monitoring)
```

Both endpoints route to the same Lambda function using **Lambda Proxy Integration**. The function already had path-based routing logic, so API Gateway just needed to pass the path information along:

```python
def lambda_handler(event, context):
    path = event.get('path', '/counter')

    if path == '/health' or path.endswith('/health'):
        return handle_health_check()

    return handle_counter_request()
```

This approach reduces infrastructure complexity while maintaining clean API design. One function, one API Gateway, multiple endpoints - efficient and maintainable.

---

## 🔒 CORS Configuration: Security That Actually Works

CORS (Cross-Origin Resource Sharing) is one of those topics that sounds complicated but becomes essential when you're building real web applications. My resume site needs to call the API from a browser, which means cross-origin requests.

My first instinct was to use the wildcard approach:

```python
'Access-Control-Allow-Origin': '*'
```

But that's amateur security. A professional API should restrict access to specific domains. I implemented domain-specific CORS:

```python
def get_cors_origin(event):
    request_origin = event.get('headers', {}).get('origin', '')

    allowed_origins = [
        'https://www.dzresume.dev',
        'https://dzresume.dev',
        'http://localhost:1313'  # For local development
    ]

    if request_origin in allowed_origins:
        return request_origin

    return 'https://www.dzresume.dev'  # Default fallback
```

The security headers include cache control and content type protection:

```python
'headers': {
    'Access-Control-Allow-Origin': cors_origin,
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'X-Content-Type-Options': 'nosniff'
}
```

These headers prevent browsers from caching dynamic data and protect against MIME type confusion attacks.

---

## 🧪 Testing CORS: Browser vs Command Line

Here's something that confused me initially: CORS enforcement only happens in browsers, not command-line tools like curl. When I tested with curl, everything worked regardless of CORS configuration:

```bash
curl -X GET https://ae348o36ad.execute-api.us-east-1.amazonaws.com/prod/counter
# Always works - no browser CORS enforcement
```

But browser testing showed the security working correctly:

```javascript
// From allowed domain - works
fetch('https://api-url/counter').then(r => r.json()).then(console.log)

// From disallowed domain - blocked by browser
// CORS policy error
```

This taught me that CORS is a browser security feature, not a server security feature. The server always returns the headers, but only browsers enforce the restrictions.

---

## 🚀 Production Deployment: More Than Just Staging

API Gateway stages are like environments, but with more configuration options than I expected. The production stage needed specific settings for enterprise operation:

- **CloudWatch Logging**: INFO level for debugging without excessive detail
- **Detailed Metrics**: Enabled for comprehensive monitoring
- **Cache Settings**: Disabled for dynamic counter data
- **Request/Response Logging**: Full logging for troubleshooting

But the real production consideration was cost protection. I implemented a usage plan with throttling:

```
Rate Limit: 100 requests/second
Burst Capacity: 200 requests
Daily Quota: 10,000 requests
```

These limits prevent runaway automation from generating surprise bills while allowing normal usage patterns. It's the kind of defensive configuration that prevents production incidents.

---

## 📊 Executive Dashboard Engineering

This is where I got creative. Instead of just monitoring API Gateway metrics, I built business intelligence extraction using CloudWatch Insights queries:

```sql
-- Hourly visitor activity pattern
fields @timestamp
| filter @message like /visitor_counter_success/
| stats count() as requests by bin(1h)
| sort @timestamp desc
| limit 168

-- Daily growth trend analysis
fields @timestamp, @message
| parse @message /counter to (?<visitor_count>\d+)/
| stats max(visitor_count) as daily_total by bin(1d)
| sort @timestamp desc
| limit 30
```

These queries transform application logs into business metrics that executives could actually understand. Instead of just "API response times," I created "visitor activity patterns" and "daily growth trends."

The three-layer monitoring approach covers the complete request lifecycle:
- **API Gateway Layer**: Request counts, latency, error rates
- **Lambda Layer**: Function duration, concurrent executions, throttling
- **DynamoDB Layer**: Capacity utilization, operation latency

This provides complete visibility from user request to database operation.

---

## 🌍 SSL Certificates: The ACM Adventure

Getting SSL certificates through AWS Certificate Manager (ACM) should be straightforward, but domain validation requires precise DNS configuration. I requested certificates for:

- `api.dzresume.dev` (primary domain)
- `*.api.dzresume.dev` (future subdomain support)

ACM generated validation CNAME records that I needed to add to Cloudflare:

```dns
Type: CNAME
Name: _acme-challenge.api
Target: [long AWS validation string]
Proxy Status: DNS only  # Critical - must be DNS only for validation
```

The tricky part was the proxy status. Cloudflare's orange cloud proxying interferes with ACM validation, so I had to disable it temporarily. After 5-10 minutes, ACM validated the certificate and marked it as "Issued."

This process taught me that SSL certificate automation still requires careful DNS coordination between providers.

---

## 🔧 Custom Domain Integration: Professional URLs

The API Gateway custom domain feature eliminates those ugly AWS-generated URLs. Instead of:

```
https://ae348o36ad.execute-api.us-east-1.amazonaws.com/prod/counter
```

I got:

```
https://api.dzresume.dev/counter
```

The configuration required:
- **Domain**: api.dzresume.dev
- **Certificate**: Link to the validated ACM certificate
- **Security Policy**: TLS 1.2 minimum
- **Endpoint Type**: Regional (cost-effective for single region)

API mapping connects the custom domain to the production stage:

```
api.dzresume.dev/counter → prod stage /counter
api.dzresume.dev/health → prod stage /health
```

The result is professional, branded API endpoints that hide internal AWS infrastructure complexity.

---

## 🌐 Cloudflare Integration: CDN for APIs

The final piece was connecting the custom domain through Cloudflare DNS. I created a CNAME record pointing to the API Gateway target domain:

```dns
Type: CNAME
Name: api
Target: d-abc123xyz.execute-api.us-east-1.amazonaws.com
Proxy Status: Proxied (orange cloud enabled)
```

Enabling Cloudflare proxy provides several benefits:
- **Global CDN**: API responses cached at edge locations worldwide
- **DDoS Protection**: Cloudflare shields the backend from attacks
- **HTTP/2 Support**: Modern protocol optimization
- **Analytics**: Additional traffic insights beyond AWS metrics

The complete request flow becomes: DNS → CDN → API Gateway → Lambda → DynamoDB

---

## 🧪 End-to-End Professional Validation

The final testing confirmed everything worked correctly:

```bash
# Professional domain with SSL
curl -i https://api.dzresume.dev/counter
HTTP/2 200
access-control-allow-origin: https://www.dzresume.dev
{"count": 21, "timestamp": "2025-05-30T20:43:27.132270", "status": "success"}

# Health monitoring endpoint
curl -i https://api.dzresume.dev/health
HTTP/2 200
{"status": "healthy", "service": "visitor-counter", "database": "connected"}
```

Performance characteristics were excellent:
- **Protocol**: HTTP/2 automatic with valid SSL
- **Response Time**: ~50ms average
- **SSL**: Valid certificate for api.dzresume.dev
- **CDN**: Cloudflare edge optimization active

Browser CORS testing confirmed the security restrictions worked correctly - requests from allowed domains succeeded while requests from other domains were blocked.

---

## 💭 API Gateway Lessons and Surprises

Day 7 taught me that API Gateway is much more than a simple "Lambda to HTTP" converter. It's a full-featured API management platform with sophisticated routing, security, monitoring, and deployment capabilities.

The CORS configuration was more nuanced than expected. Understanding that CORS is browser-enforced, not server-enforced, changes how you think about API security testing and implementation.

Custom domain integration requires coordination across multiple AWS services and external DNS providers. The process works well once you understand the pieces, but getting the configuration right requires attention to detail.

Most importantly, I learned that professional APIs need more than just functional endpoints. They need monitoring, security, performance optimization, and operational visibility. The executive dashboard work demonstrated how to extract business value from technical metrics.

The transformation from ugly AWS URLs to professional branded endpoints made the whole API feel production-ready. When someone calls `https://api.dzresume.dev/counter`, they're interacting with a properly architected, monitored, and secured API that could handle enterprise workloads.

Time to connect this professional backend to the polished frontend and see the complete application come together.
