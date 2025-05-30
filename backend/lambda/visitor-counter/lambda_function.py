import json
import boto3
import logging
from datetime import datetime
from decimal import Decimal
from botocore.exceptions import ClientError

# Configure logging for production debugging and monitoring
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS services outside handler for connection reuse
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-counter-prod')

def lambda_handler(event, context):
    """
    Multi-endpoint visitor counter API handler
    Supports both counter increment and health check endpoints
    """
    try:
        # Extract request metadata
        path = event.get('path', '/counter')
        http_method = event.get('httpMethod', 'GET')
        cors_origin = get_cors_origin(event)  # 🔧 NEW: Use helper function

        logger.info(f"Processing request: {json.dumps({
            'requestId': context.aws_request_id,
            'path': path,
            'httpMethod': http_method,
            'origin': cors_origin,
            'userAgent': event.get('headers', {}).get('User-Agent', 'UNKNOWN')[:100]
        })}")

        # 🩺 Health Check Endpoint
        if path == '/health' or path.endswith('/health'):
            health_data = health_check()
            status_code = 200 if health_data.get('status') == 'healthy' else 503

            return build_response(
                status_code=status_code,
                body=health_data,
                cors_origin=cors_origin,
                cache_control='no-cache, max-age=0'
            )

        # 🔢 Visitor Counter Endpoint (default)
        try:
            new_count = increment_existing_counter()
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                logger.info("Counter not found, initializing for first-time visitor")
                new_count = handle_first_time_visitor()
            else:
                raise e

        response_body = {
            'count': new_count,
            'timestamp': datetime.now().isoformat(),
            'status': 'success',
            'requestId': context.aws_request_id
        }

        return build_response(
            status_code=200,
            body=response_body,
            cors_origin=cors_origin,
            cache_control='no-cache, no-store, must-revalidate',
            extra_headers={'X-Content-Type-Options': 'nosniff'}
        )

    except Exception as e:
        error_context = {
            'requestId': context.aws_request_id,
            'errorType': type(e).__name__,
            'errorMessage': str(e)[:200],
            'functionName': context.function_name
        }

        logger.error(f"Visitor counter operation failed: {json.dumps(error_context)}")

        cors_origin = get_cors_origin(event)
        error_body = {
            'status': 'error',
            'message': 'Unable to process request. Please try again.',
            'requestId': context.aws_request_id
        }

        return build_response(
            status_code=500,
            body=error_body,
            cors_origin=cors_origin
        )

def get_cors_origin(event):
    """
    Determine appropriate CORS origin based on request
    Allows both production and development origins
    """
    request_origin = event.get('headers', {}).get('origin', '')

    allowed_origins = [
        'https://www.dzresume.dev',
        'https://dzresume.dev',
        'http://localhost:1313',
        'http://127.0.0.1:1313'
    ]

    if request_origin in allowed_origins:
        logger.info(f"CORS: Allowing origin {request_origin}")
        return request_origin

    logger.info(f"CORS: Unknown origin {request_origin}, defaulting to production")
    return 'https://www.dzresume.dev'


def build_response(status_code, body, cors_origin, cache_control=None, extra_headers=None):
    """
    Build standardized API response with consistent headers
    """
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': cors_origin,
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }

    if cache_control:
        headers['Cache-Control'] = cache_control

    if extra_headers:
        headers.update(extra_headers)

    return {
        'statusCode': status_code,
        'headers': headers,
        'body': json.dumps(body)
    }

def increment_existing_counter():
    """Perform atomic increment of existing visitor counter"""
    response = table.update_item(
        Key={'counter_id': 'main_counter'},
        UpdateExpression='ADD visit_count :increment SET last_updated = :timestamp',
        ExpressionAttributeValues={
            ':increment': 1,
            ':timestamp': datetime.now().isoformat()
        },
        ReturnValues='UPDATED_NEW'
    )

    new_count = int(response['Attributes']['visit_count'])
    logger.info(f"Successfully incremented counter to {new_count}")
    return new_count

def handle_first_time_visitor():
    """Initialize visitor counter for first-time access with concurrency protection"""
    try:
        table.put_item(
            Item={
                'counter_id': 'main_counter',
                'visit_count': 1,
                'created_date': datetime.now().isoformat(),
                'last_updated': datetime.now().isoformat()
            },
            ConditionExpression='attribute_not_exists(counter_id)'
        )
        logger.info("Successfully initialized visitor counter for first-time access")
        return 1
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            logger.info("Counter already exists, proceeding with normal increment")
            return increment_existing_counter()
        else:
            logger.error(f"Unexpected error during counter initialization: {str(e)}")
            raise e

def health_check():
    """
    Health check endpoint for monitoring and load balancing
    Validates DynamoDB connectivity without modifying data
    """
    try:
        # Test database connectivity without changing data
        response = table.get_item(
            Key={'counter_id': 'main_counter'}
        )

        # Check if we can read the counter
        if 'Item' in response:
            current_count = int(response['Item']['visit_count'])
            logger.info(f"Health check successful - counter at {current_count}")

            return {
                'status': 'healthy',
                'service': 'visitor-counter',
                'database': 'connected',
                'counter_value': current_count,
                'timestamp': datetime.now().isoformat()
            }
        else:
            # Counter doesn't exist yet, but database is accessible
            logger.info("Health check successful - database accessible, counter not initialized")
            return {
                'status': 'healthy',
                'service': 'visitor-counter',
                'database': 'connected',
                'counter_value': 0,
                'timestamp': datetime.now().isoformat(),
                'note': 'counter_not_initialized'
            }

    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return {
            'status': 'unhealthy',
            'service': 'visitor-counter',
            'database': 'error',
            'error': str(e)[:100],
            'timestamp': datetime.now().isoformat()
        }
