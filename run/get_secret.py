import requests
import json

# Replace with your Vault address and token
VAULT_ADDR = 'http://127.0.0.1:8200'
VAULT_TOKEN = 'your-vault-token'

# Replace with your secret path
SECRET_PATH = 'secret/data/mysecret'

def get_vault_secret(vault_addr, token, secret_path):
    headers = {
        'X-Vault-Token': token
    }
    url = f"{vault_addr}/v1/{secret_path}"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        return data['data']['data']
    else:
        print(f"Error {response.status_code}: {response.text}")
        return None

if __name__ == "__main__":
    secret = get_vault_secret(VAULT_ADDR, VAULT_TOKEN, SECRET_PATH)
    if secret:
        print("Retrieved secret:")
        print(json.dumps(secret, indent=2))
