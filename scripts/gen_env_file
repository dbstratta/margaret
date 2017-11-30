#!/usr/bin/env python3

import os
import shutil


def main():
    """Copies `.env.example` to `.env`."""

    project_root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    src = os.path.join(project_root, '.env.example')
    dst = os.path.join(project_root, '.env')

    shutil.copy2(src, dst)


if __name__ == '__main__':
    main()
