import { head } from 'ramda';

/**
 * We have problems with syntax highlighting and code formatting
 * in GraphQL template literals.
 * Existing tools only recognize literals as GraphQL if they are called
 * with `gql` or `Relay.QL` functions, so export our function that
 * returns only the string from the template literal and we improve our
 * developer experience.
 */
export default head;
