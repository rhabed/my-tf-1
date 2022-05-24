import json
import boto3
import logging
import random

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
EC2_CLIENT = boto3.client("ec2")
AVAILABILITY_ZONE = ["ap-southeast-2a", "ap-southeast-2b"]
MAX_NUMBER_OF_HOSTS = 3


def ec2_host_scale_out(availability_zone, quantity):
    try:
        LOGGER.info("Scale out for %s host(s) in AZ: %s", quantity,
                    availability_zone)
        response = EC2_CLIENT.allocate_hosts(
            AutoPlacement="on",
            AvailabilityZone=AVAILABILITY_ZONE[random.randint(0, 1)],
            ClientToken="idempotency_consideration",
            InstanceFamily="a1",
            Quantity=quantity,
            TagSpecifications=[
                {
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "anzx-dedicated-host"
                        },
                    ]
                },
            ],
            HostRecovery="off",
        )
        LOGGER.info(response)
    except Exception as e:
        LOGGER.error("Request Exception: %s", e)


def ec2_host_scale_in(host_id):
    LOGGER.info("Scale in for host_id: %s", host_id)
    try:
        response = EC2_CLIENT.release_hosts(HostIds=[host_id])
    except Exception as e:
        LOGGER.error("Request Exception: %s", e)
    pass


def check_host_status(new_runner=False):
    response = {}
    new_runner_instance = new_runner
    number_hosts = 0
    try:
        response = EC2_CLIENT.describe_hosts()
        if not response["Hosts"]:
            LOGGER.warning(
                "No EC2 Hosts is currently deployed in the AWS Environment")
            LOGGER.info("Creating new AWS EC2 Hosts")
            ec2_host_scale_out("ap-southeast-2a", 1)
        else:
            hosts = response["Hosts"]
            for host in hosts:
                # for MAC instances: change 4 to 0 --> as 1 instance per MAC
                if (host["AvailableCapacity"]["AvailableInstanceCapacity"][4]
                    ["AvailableCapacity"] == host["AvailableCapacity"]
                    ["AvailableInstanceCapacity"][4]["TotalCapacity"]):
                    LOGGER.info(
                        "There are no instances running on this Hosts - Releasing..."
                    )
                    if new_runner_instance:
                        LOGGER.info(
                            "There are no instances running on this Hosts - Requesting new runner host..."
                        )
                        new_runner_instance = False
                    else:  # Scale In
                        ec2_host_scale_in(host["HostId"])
                elif (host["AvailableCapacity"]["AvailableInstanceCapacity"][4]
                      ["AvailableCapacity"] < host["AvailableCapacity"]
                      ["AvailableInstanceCapacity"][4]["TotalCapacity"]):
                    LOGGER.info(
                        "There's an instance running on the the host %s",
                        host["HostId"])
            if new_runner_instance and len(hosts) < MAX_NUMBER_OF_HOSTS:
                LOGGER.info("Creating new AWS EC2 Hosts")
                ec2_host_scale_out("ap-southeast-2a", 1)
                LOGGER.info(
                    "There are no instances running on this Hosts - Requesting new runner host..."
                )
    except Exception as e:
        LOGGER.error("Request Exception: %s", e)

    return response


def lambda_handler(event, context):
    # TODO implement
    print(random.randint(0, 1))
    check_host_status()
