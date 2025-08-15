#!/usr/bin/env python3
import uuid
import psutil
import sys

DATA_IPS_FILE = "../storage_data_ips.txt"
MGMT_IPS_FILE = "../storage_mgmt_ips.txt"
SECRETS_FILE = "../secrets.env"
ENVS_FILE = "./mgx-env"


# Collect all IPv4 addresses from all interfaces
def get_all_ips():
    local_ips = set()
    for iface, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
            if addr.family.name == 'AF_INET':  # IPv4
                local_ips.add(addr.address)
    return local_ips


def mgx_id():
    # Read the storage data IPs
    with open(DATA_IPS_FILE, "r") as f:
        data_ips = [line.strip() for line in f if line.strip()]

    # Compare and generate UUID5 for matching IP
    for ip in data_ips:
        if ip in get_all_ips():
            node_uuid = uuid.uuid5(uuid.NAMESPACE_DNS, ip)
            print(f"{node_uuid}")


def mgx_hosts():
    # Read the storage data IPs
    with open(MGMT_IPS_FILE, "r") as f:
        mgmt_ips = "\n".join([line.strip() for line in f if line.strip()])

        print(f"{mgmt_ips}")


def read_env_file(path):
    env_vars = {}
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                env_vars[k.strip()] = v.strip().strip('"')
    return env_vars


def mgx_env():

    # Load env files
    base_env = read_env_file(ENVS_FILE)
    secrets_env = read_env_file(SECRETS_FILE)

    # Merge with secrets taking precedence
    merged_env = {**base_env, **secrets_env}

    # Detect current node's management IP
    local_ips = get_all_ips()
    with open(MGMT_IPS_FILE, "r") as f:
        mgmt_ips = [line.strip() for line in f if line.strip()]

    iface = None
    current_mgmt_ip = None

    for iface_name, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
            if addr.family.name == 'AF_INET' and addr.address in mgmt_ips:
                iface = iface_name
                current_mgmt_ip = addr.address
                break
        if iface:
            break

    # If found, set MGX_IFACE
    if iface:
        merged_env["MGX_IFACE"] = iface
        merged_env["CASS_RPC_ADDR"] = current_mgmt_ip
    else:
        raise Exception("iface not found")

    # Set MGX_CASS_CREDS using CASS_USER and CASS_PASSWD
    cass_user = merged_env.get("CASS_USER", "<CASS_USER>")
    cass_pass = merged_env.get("CASS_PASSWD", "<CASS_PASSWD>")
    merged_env["MGX_CASS_CREDS"] = f"{cass_user}:{cass_pass}"

    # Output final merged env
    for k, v in merged_env.items():
        print(f"{k}={v}")


def mgx_cass_seeds():
    # Read the first two IPs from MGMT_IPS_FILE
    with open(MGMT_IPS_FILE, "r") as f:
        mgmt_ips = [line.strip() for line in f if line.strip()]

    # Prepare seeds string
    seeds_value = f'{mgmt_ips[0]}:7000,{mgmt_ips[1]}:7000'

    print(seeds_value)

if __name__ == "__main__":
        
    op = sys.argv[1]

    try:

        if op == "mgx-id":
            mgx_id()
        elif op == "mgx-hosts":
            mgx_hosts()
        elif op == "mgx-env":
            mgx_env()
        elif op == "mgx-cass-seeds":
            mgx_cass_seeds()

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
