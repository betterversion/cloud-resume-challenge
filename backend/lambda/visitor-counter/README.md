# Visitor Counter Lambda Function

## Purpose
Serverless function that provides atomic visitor counting for the resume website with health monitoring capabilities.

## Architecture
- **Runtime**: Python 3.11
- **Database**: DynamoDB (resume-visitor-counter table)
- **Trigger**: API Gateway (configured in Day 7)
- **Endpoints**: Multi-endpoint routing support

## API Endpoints

### `GET /counter` - Visitor Counter
- **Purpose**: Increment visitor count and return updated total
- **Response**: JSON with current count, timestamp, and request ID
- **Features**: Atomic increments, first-time visitor initialization
- **CORS**: Enabled for https://www.dzresume.dev

### `GET /health` - Health Check
- **Purpose**: Validate service and database connectivity
- **Response**: Health status with database connectivity info
- **Use Cases**: Load balancer checks, monitoring, deployment validation
- **Non-destructive**: Reads data without modifications

## Key Features
- **Atomic Operations**: Race condition safe counter increments using DynamoDB ADD expressions
- **First-time Visitor Logic**: Automatic counter initialization with concurrency protection
- **Multi-endpoint Routing**: Path-based routing within single Lambda function
- **Health Monitoring**: Non-destructive health checks for operational monitoring
- **Comprehensive Error Handling**: Graceful degradation with structured error responses
- **Structured Logging**: JSON-formatted logs for CloudWatch Insights analysis
- **CORS Integration**: Cross-origin support for web frontend integration
- **Request Correlation**: Unique request IDs for end-to-end tracing

## Response Examples

### Successful Counter Increment
```json
{
  "count": 42,
  "timestamp": "2024-01-15T10:30:00Z",
  "status": "success",
  "requestId": "abc123-def456-ghi789"
}
```

### Health Check - Healthy
```json
{
  "status": "healthy",
  "service": "visitor-counter",
  "database": "connected",
  "counter_value": 42,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Health Check - Unhealthy
```json
{
  "status": "unhealthy",
  "service": "visitor-counter",
  "database": "error",
  "error": "Unable to connect to DynamoDB",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Error Handling
- **User-friendly responses**: No technical details exposed to frontend
- **Detailed internal logging**: Comprehensive error context for debugging
- **Consistent CORS headers**: Error responses maintain cross-origin compatibility
- **Request correlation**: Error responses include request IDs for log correlation

## Performance Characteristics
- **Cold start**: ~800ms (initial environment setup)
- **Warm start**: ~50ms (connection reuse optimization)
- **Memory usage**: ~45MB (efficient resource utilization)
- **Concurrent capacity**: 1000+ simultaneous executions
- **Database latency**: <10ms for DynamoDB operations under normal conditions

## Security Implementation
- **Least Privilege IAM**: Precisely scoped permissions for required operations only
  - `dynamodb:GetItem` - Health checks and operational queries
  - `dynamodb:UpdateItem` - Atomic counter increments
  - `dynamodb:PutItem` - First-time visitor initialization
  - `logs:*` - CloudWatch logging (function-specific log group)
- **Input Validation**: Defensive programming with safe key access patterns
- **Privacy-Preserving Logging**: User-Agent truncation, no PII in logs
- **Resource Isolation**: Table-specific permissions, cannot access other DynamoDB resources

## Operational Features
- **CloudWatch Integration**: Structured JSON logs for advanced querying
- **Request Tracing**: Correlation IDs link frontend requests to backend logs
- **Performance Monitoring**: Execution time and memory usage tracking
- **Health Endpoints**: Ready for integration with load balancers and monitoring systems
- **Zero-downtime Deployments**: Serverless architecture supports rolling updates

## Local Development
This function is deployed directly to AWS Lambda via the console during development phase.
Code is maintained in version control for backup, collaboration, and documentation.

**Future Enhancement**: Infrastructure-as-Code deployment using AWS SAM/CDK for production environments.

## Dependencies
- **Runtime Dependencies**: AWS SDK (boto3) - included in Lambda Python runtime
- **External Dependencies**: None (optimized for cold start performance)
- **AWS Services**: DynamoDB, CloudWatch Logs

## Deployment Requirements
- **IAM Role**: Lambda execution role with custom DynamoDB policy
- **DynamoDB Table**: `resume-visitor-counter` with `counter_id` partition key
- **Environment**: AWS Lambda with appropriate timeout and memory configuration
- **Network**: No VPC configuration required (uses AWS service endpoints)

## Monitoring and Alerting
- **CloudWatch Logs**: `/aws/lambda/resume-visitor-counter` log group
- **Metrics**: Duration, memory usage, error rate, invocation count
- **Health Checks**: Available via `/health` endpoint for external monitoring
- **Request Tracing**: Structured logs enable correlation and analysis

## Testing
- **Unit Testing**: Individual function components tested via Lambda console
- **Integration Testing**: End-to-end testing with DynamoDB backend
- **Error Scenario Testing**: Permission failures, network issues, race conditions
- **Performance Testing**: Cold start and warm start latency validation

## Version History
- **v1.0**: Initial implementation with atomic counter operations
- **v1.1**: Added comprehensive error handling and structured logging
- **v1.2**: Implemented multi-endpoint routing and health check functionality

---
*Last Updated: Day 6 - Production-ready serverless backend with health monitoring*
