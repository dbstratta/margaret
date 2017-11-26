import React, { Component } from 'react';

import { Editor, EditorState } from 'draft-js';

export default class MyEditor extends Component {
  state = { editorState: EditorState.createEmpty() };

  handleChange = editorState => this.setState({ editorState });

  render() {
    return <Editor editorState={this.state.editorState} onChange={this.handleChange} />;
  }
}
