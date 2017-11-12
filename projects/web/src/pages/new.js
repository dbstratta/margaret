import React from 'react';
import Link from 'next/link';

export const New = () => (
  <h1>
    New Story
    <Link href="/">
      <a>Home</a>
    </Link>
  </h1>
);

export default New;
