"""
This is the main module for auto-generating deployment secrets
for the Genesys Private Edition Public Repo

We're using the Google Pylintrc found in their style guide here:
https://google.github.io/styleguide/pyguide.html in section 2.1

Direct Link: https://google.github.io/styleguide/pylintrc
"""

import argparse
import logging
import os
import sys

from libs.secret_generator import Generator

LOGLEVEL = 'DEBUG'

logging.basicConfig(level=LOGLEVEL)
log = logging.getLogger(__name__)
sh = logging.StreamHandler()
log.setLevel(LOGLEVEL)
sh.setFormatter(
    logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
log.addHandler(sh)
log.propagate = False


class Main():
    """Main class"""
    def __init__(self):
        self.method_choice = 0
        self.method_choice_dict = {
            1: 'service',
            2: 'environment'
        }
        self.method = ''
        self.service_choice = 0
        self.service_choice_dict = {
            1: 'global-deployment-secrets',
            2: 'bds',
            3: 'cxc',
            4: 'designer',
            5: 'gauth',
            # TODO - FIX GWS gws_client_secret
            6: 'gcxi',
            7: 'ges',
            8: 'gim',
            9: 'gsp',
            10: 'gvp',
            11: 'gws',
            12: 'iwd',
            13: 'iwddm',
            14: 'iwdem',
            15: 'ixn',
            16: 'nexus',
            17: 'pulse',
            18: 'strms',
            19: 'tlm',
            20: 'ucsx',
            21: 'voice'
        }
        self.service = ''

    def method_choose(self) -> str:
        while self.method_choice not in self.method_choice_dict:
            try:
                self.method_choice = int(input('Deployment methods:\n\n1. '
                    'Specific (individual) service\n2. Entire lab environment '
                    '(all defaults)\n\n'
                    'Please pick a deployment method (1 or 2): '))
                log.debug('self.method_choice = %s', self.method_choice)
                if self.method_choice in self.method_choice_dict:
                    continue
                else:
                    print(f'\nChosen option {self.method_choice} is not in '
                        'the range of valid options. Please choose again.\n')
            except ValueError:
                print('Not a valid option.\nChoices again are: '
                f'{self.method_choice_dict}')
        self.method = self.method_choice_dict[self.method_choice]
        log.debug('self.method = %s', self.method)
        return self.method

    def service_choose(self) -> str:
        print('\nService Choices\n---\n')
        for key, value in self.service_choice_dict.items():
            print(key,': ',value)
        print('\n')
        while self.service_choice not in self.service_choice_dict:
            try:
                self.service_choice = input(
                        'Please pick a service to configure '
                        'from the the options provided. You can type the '
                        'number or the service name: ')
                log.debug('self.service_choice = %s', self.service_choice)
                if self.service_choice in self.service_choice_dict.values():
                    self.service = self.service_choice
                    break
                elif int(self.service_choice) in self.service_choice_dict:
                    self.service_choice = int(self.service_choice)
                    self.service = self.service_choice_dict[self.service_choice]
                    break
                else:
                    print(f'\nChosen option {self.service_choice} is not in '
                        'the range of valid options. Please choose again.\n')
            except ValueError:
                print('Not a valid option.\nChoices again are: '
                f'{self.service_choice_dict}')
        log.debug('self.service = %s', self.service)
        print(f'\nConfiguring the {self.service} service.\n')
        return self.service


def app():
    'Main app function'
    try:
        os.mkdir('./output')
    except FileExistsError:
        pass # directory already exists
    except OSError as error:
        log.error('error creating output directory: %s', error)
    print('\n\nWelcome to the Genesys Private Edition Configurator!\n\n'
        'This script will generate deployment-secrets (as yaml and json files) '
        'for you to deploy in your Genesys Private Edition kubernetes '
        'environments.\n')
    app_main = Main()
    match dep_method:
        case 'environment':
            method = 'environment'
        case 'service':
            method = 'service'
        case _:
            method = app_main.method_choose()
    try:
        assert method in ['service', 'environment']
    except AssertionError as error:
        log.error('Assertion Error: %s', error)
        sys.exit(1)
    log.debug('method = %s', method)
    match method:
        case 'service':
            if dep_service:
                service_name = dep_service
                log.debug('service = %s', service_name)
            else:
                service_name = app_main.service_choose()
                log.debug('service = %s', service_name)
            service = Generator(service_name)
            service.plaintext_offer()
            print(f'\nStarting {service_name} variable selection run')
            service.run()
            print(f'Finalizing {service_name} deployment-secrets files')
            service.finalize_individual()
        case 'environment':
            env = Generator('all')
            if plaintext:
                env.pt = True
            else:
                env.plaintext_offer()
            env.finalize_all()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query Parameters')
    parser.add_argument('-s',
                        '--service',
                        dest='service',
                        type=str,
                        required=False)
    parser.add_argument('-m',
                        '--method',
                        dest='method',
                        type=str,
                        required=False)
    parser.add_argument('-p',
                        '--plaintext',
                        dest='plaintext',
                        action='store_true',
                        required=False)
    args = parser.parse_args()
    dep_service = args.service
    dep_method = args.method
    plaintext = args.plaintext
    app()
