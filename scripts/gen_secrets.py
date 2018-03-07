#!/usr/bin/env python3

import os


def get_path(namespace: str) -> str:
    project_root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    k8s_path = os.path.join(project_root, 'k8s')
    k8s_dev_path = os.path.join(k8s_path, 'development')
    k8s_prod_path = os.path.join(k8s_path, 'production')

    filename = 'secrets.yaml'

    if namespace == 'dev' or namespace == 'development':
        dirname = k8s_dev_path
    elif namespace == 'prod' or namespace == 'production':
        dirname = k8s_prod_path

    return os.path.join(dirname, filename)


def gen_string(**kwargs) -> str:
    """
    Generates the string to put in the secrets file.
    """

    return f"""\
    apiVersion: v1
    kind: Secret
    metadata:
      name: keys
      namespace: {kwargs['namespace']}
    type: Opaque
    data:
      github_client_secret: {kwargs.get('github_client_secret')}
    """


def gen_secrets() -> None:
    """
    Creates and populates the Kubernetes yaml file for the secrets.
    """

    path = get_path(namespace)

    with open(path, 'w') as f:
        content = gen_string()

        f.write(content)

    print(f'Secrets file successfully created at {path}')


if __name__ == '__main__':
    gen_secrets()
