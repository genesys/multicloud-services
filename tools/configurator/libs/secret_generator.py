'''
Secret generator module based on dictionary.json template
'''
import base64
import json
import logging
import os
import sys

import bcrypt
import yaml

LOGLEVEL = 'DEBUG'

logging.basicConfig(level=LOGLEVEL)
log = logging.getLogger(__name__)
sh = logging.StreamHandler()
sh.setLevel(LOGLEVEL)
sh.setFormatter(
    logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
log.addHandler(sh)
log.propagate = False

class Generator():
    """Class for deployment-secrets generation"""
    def __init__(self, service: str):
        self.service: str = service
        with open('templates/dictionary.json',
                  'r',
                  encoding='utf-8') as secrets_dict:
            json_data: dict = secrets_dict.read()
            self.ds: dict = json.loads(json_data)
        with open('templates/descriptions.json',
                  'r',
                  encoding='utf-8') as descriptions_dict:
            json_data2: dict = descriptions_dict.read()
            self.desc: dict = json.loads(json_data2)
        self.namespace = self.service
        self.service_list = list(self.ds.keys())
        self.kind = 'Secret'
        self.type = 'Opaque'
        self.api_version = 'v1'
        self.plaintext_dict = {self.service: {}}

    def run(self) -> None:
        try:
            assert self.service in self.service_list
        except AssertionError as error:
            log.error('%s\n%s not a supported service', error, self.service)
            sys.exit(1)
        for i in list(self.ds[self.service]):
            if i == 'gauth_jks_key' and self.service == 'gauth':
                # This is done so as not to try attempting to
                # base64 decode a keystore file. The generated
                # yaml is also represented as plaintext stringData
                # which is then encoded properly into the deployment-secrets
                print('\nA default gauth_jks_key has been generated, '
                'and is in the dictionary.json and the generated '
                'gauth-deployment-secrets as gauth_jks_key. The user '
                'and pass for the keystore are "genesys" by default.'
                'This corresponds to what you entered for '
                '"gauth_jks_keyPassword" and "gauth_jks_keyStorePassword\n')
                if self.pt:
                    self.plaintext_dict[self.service].update(
                        {i: self.ds[self.service][i]})
            else:
                self.var_prompt(i)

    def finalize_individual(self) -> None:
        if self.service == 'gauth':
            self.ds['stringData'] = (
                {'gauth_jks_key': self.ds[self.service]['gauth_jks_key']})
            del self.ds[self.service]['gauth_jks_key']
            self.ds['data'] = self.ds[self.service]
        else:
            self.ds['data'] = self.ds[self.service]
        for x in self.service_list:
            del self.ds[x]
        self.ds['kind'] = self.kind
        self.ds['apiVersion'] = self.api_version
        if self.service == 'global-deployment-secrets':
            self.ds['metadata'] = {'name': self.service,
                                   'namespace': 'default'}
        else:
            self.ds['metadata'] = {'name': 'deployment-secrets',
                                   'namespace': self.namespace}
        self.ds['type'] = self.type
        try:
            os.remove(f'./output/{self.service}/deployment-secrets.json')
            os.remove(f'./output/{self.service}/deployment-secrets.yaml')
            os.remove(
                f'./output/{self.service}/deployment-secrets-plaintext.json')
            os.rmdir(f'./output/{self.service}')
        except FileExistsError:
            pass # directory already exists
        except OSError as error:
            log.debug('Cannot delete non-existant files: %s', error)
        try:
            os.mkdir(f'./output/{self.service}')
        except FileExistsError:
            pass # directory already exists
        except OSError as error:
            log.error('error creating output directory: %s', error)
        with open(f'output/{self.service}/deployment-secrets.yaml',
                  'w',
                  encoding='utf-8') as new_secrets_yaml:
            yaml.dump(self.ds, new_secrets_yaml)
        with open(f'output/{self.service}/deployment-secrets.json',
                  'w',
                  encoding='utf-8') as new_secrets_json:
            json.dump(
                self.ds,
                new_secrets_json,
                indent=2,
                sort_keys=True)
        if hasattr(self, 'pt') and self.pt:
            with open(f'output/{self.service}/deployment-secrets-'
                'plaintext.json',
                'w',
                encoding='utf-8') as new_secrets_pt_json:
                json.dump(
                    self.plaintext_dict,
                    new_secrets_pt_json,
                    indent=2,
                    sort_keys=True)

    def finalize_all(self) -> None:
        if os.path.exists('output/deployment-secrets.yaml'):
            os.remove('output/deployment-secrets.yaml')
        if os.path.exists('output/deployment-secrets.json'):
            os.remove('output/deployment-secrets.json')
        if os.path.exists('output/deployment-secrets-plaintext.json'):
            os.remove('output/deployment-secrets-plaintext.json')
        for index, service_name in enumerate(self.service_list):
            if service_name == 'global-deployment-secrets':
                self.namespace = 'default'
                secret_name = 'global-deployment-secrets'
            else:
                self.namespace = service_name
                secret_name = 'deployment-secrets'
            if service_name == 'gauth':
                new_ds = {'kind': self.kind,
                          'apiVersion': self.api_version,
                          'metadata':
                          {'name': secret_name,
                          'namespace': self.namespace},
                          'type': self.type,
                          'data': self.ds[service_name],
                          'stringData': {'gauth_jks_key': \
                            self.ds[service_name]['gauth_jks_key']}}
                del new_ds['data']['gauth_jks_key']
            else:
                new_ds = {'kind': self.kind,
                          'apiVersion': self.api_version,
                          'metadata':
                          {'name': secret_name,
                          'namespace': self.namespace},
                          'type': self.type,
                          'data': self.ds[service_name]}
            self.write_ds_yaml('output/deployment-secrets.yaml',
                               new_ds,
                               index)
            self.write_ds_json('output/deployment-secrets.json',
                               new_ds,
                               index)
            self.write_pt_json('output/deployment-secrets-plaintext.json',
                               new_ds)

    def write_ds_yaml(self, directory, ds_dict, index):
        with open(directory, 'a', encoding='utf-8') as new_secrets_yaml:
            yaml.dump(ds_dict, new_secrets_yaml)
            if index in range(len(self.service_list)-1):
                # Don't insert separator + newline on last
                # iteration of the loop
                new_secrets_yaml.writelines('---\n')

    def write_ds_json(self, directory, ds_dict, index):
        with open(directory, 'a', encoding='utf-8') as new_secrets_json:
            json.dump(ds_dict, new_secrets_json, indent=2, sort_keys=True)
            if index in range(len(self.service_list)-1):
                # Don't insert separator + newline on last
                # iteration of the loop
                new_secrets_json.write(',\n')

    def write_pt_json(self, directory, ds_dict):
        if hasattr(self, 'pt') and self.pt:
            for i in ds_dict['data']:
                ds_dict['data'][i] = (
                    base64.b64decode(
                        ds_dict['data'][i]).decode())
            with open(directory, 'a', encoding='utf-8') as new_secrets_pt_json:
                json.dump(
                    ds_dict,
                    new_secrets_pt_json,
                    indent=2,
                    sort_keys=True)

    def plaintext_offer(self) -> None:
        offer = input('Generate secrets (also) in a plaintext '
            'file? Default - No. (y/n): ')
        log.debug('offer value: %s', offer)
        match offer:
            case 'y' | 'yes' | 'Y' | 'YES' | 't' | 'true' | 'T' | 'TRUE':
                self.pt = True
            case 'n' | 'no' | 'N' | 'NO' | 'f' |'false' | 'F' | 'FALSE' | '':
                self.pt = False
        log.debug('plaintext value: %s', self.pt)

    def var_prompt(self, var: str) -> None:
        print('-------------------\n\n')
        print(f'\nDescription: {self.desc[self.service][var]}\n')
        j = input(f'Please input your variable for {var} \nDefault: "'
              f'{base64.b64decode(self.ds[self.service][var]).decode()}"'
              f'\n{var}: ')
        if j == '':
            if self.service == 'gauth':
                if self.pt:
                    self.plaintext_dict[self.service].update(
                        {var: base64.b64decode(
                            self.ds[self.service][var]).decode()})
                log.debug('plaintext: %s = %s', var,
                          base64.b64decode(self.ds[self.service][var]).decode())
                log.debug('base64encoded: %s = %s\n',
                          var,
                          self.ds[self.service][var])
            else:
                j = self.ds[self.service][var]
                if self.pt:
                    self.plaintext_dict[self.service].update(
                        {var: base64.b64decode(j).decode()})
                log.debug('plaintext: %s = %s', var,
                          base64.b64decode(j).decode())
                log.debug('base64encoded: %s = %s\n', var, j)
        else:
            if var in ['gauth_admin_password', 'gws_ops_pass_encr']:
                passwd = j.encode('utf-8')
                salt = bcrypt.gensalt()
                hashed = bcrypt.hashpw(passwd, salt)
                db_b64 = base64.b64encode(hashed)
                self.ds[self.service][var] = db_b64.decode()
                if self.pt:
                    self.plaintext_dict[self.service].update(
                        {var: db_b64.decode()})
                log.debug('plaintext: %s = %s', var, j)
                if bcrypt.checkpw(passwd, hashed):
                    log.debug('bcrypted: %s = %s', var, hashed.decode())
                else:
                    log.error('There was a serious bcrypt error, exiting')
                    sys.exit(1)
                log.debug('base64encoded: %s = %s\n', var, db_b64.decode())
            else:
                db_b64 = base64.b64encode(bytes(j, 'utf-8'))
                self.ds[self.service][var] = db_b64.decode()
                if self.pt:
                    self.plaintext_dict[self.service].update({var: j})
                log.debug('plaintext: %s = %s', var, j)
                log.debug('base64encoded: %s = %s\n', var, db_b64.decode())
