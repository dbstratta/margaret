import { DangerDSLType, warn } from 'danger';

declare const danger: DangerDSLType;

const warnIfLockfileNotUpdated = () => {
  const packageChanged = danger.git.modified_files.includes('package.json');
  const lockfileChanged = danger.git.modified_files.includes('yarn.lock');

  if (packageChanged && !lockfileChanged) {
    const message = 'Changes were made to package.json, but not to yarn.lock';
    const idea = 'Perhaps you need to run `yarn install`?';

    warn(`${message} - <em>${idea}</em>`);
  }
};

warnIfLockfileNotUpdated();
