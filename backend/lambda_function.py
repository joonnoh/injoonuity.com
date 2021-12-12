import os, boto3

# Update and get visitorCount from DynamoDB table using Boto3 resource

DBtable = os.environ['DBtable']
table = boto3.resource('dynamodb').Table(DBtable)

def lambda_handler(event, context):
    response = table.update_item(
        Key = {
            'targetValue': 'visitorCount'
        },
        ExpressionAttributeNames = {
            '#count': 'count'
        },
        ExpressionAttributeValues = {
            ':increase': 1
        },
        #UpdateExpression = 'SET #count = #count + :increase',
        UpdateExpression = 'ADD #count :increase', 
        ReturnValues = 'UPDATED_NEW'
    )
    
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Headers" : "*",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET"
        },
        'body': response['Attributes']['count']
    }

'''
# FOR TESTING: Get visitorCount from DynamoDB table using Boto3 client
client = boto3.client('dynamodb')
DBtable = os.environ['DBtable']
def lambda_handler(event, context):
    response = client.get_item(
        TableName = DBtable,
        Key = {
            'targetValue': {
                'S': 'visitorCount'
            }
        }    
    )
    print("The current count is " + response['Item']['count']['N'])
    
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Headers" : "*",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET"
        },
        'body': response['Item']['count']['N']
    }
'''
