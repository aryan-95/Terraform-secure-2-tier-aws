import boto3
import os
from datetime import datetime, timezone

def handler(event, context):
    ec2 = boto3.client("ec2")
    idle_minutes = int(os.environ.get("IDLE_MINUTES", 10))

   
    response = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            launch_time = instance["LaunchTime"]

          
            now = datetime.now(timezone.utc)
            running_minutes = (now - launch_time).total_seconds() / 60

            print(f"Instance {instance_id} running for {running_minutes:.1f} minutes")

            if running_minutes >= idle_minutes:
                
                ec2.create_tags(
                    Resources=[instance_id],
                    Tags=[{"Key": "Status", "Value": "unused"}]
                )
                print(f"Tagged {instance_id} as unused")

               
                ec2.stop_instances(InstanceIds=[instance_id])
                print(f"Stopped instance {instance_id}")

    return {"statusCode": 200, "body": "Cost control check complete"}