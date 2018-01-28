import React, { Component } from 'react';
import { Editor, EditorState, convertToRaw, convertFromRaw } from 'draft-js';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { branch, renderComponent } from 'recompose';
import PropTypes from 'prop-types';

const getInitialEditorState = content =>
  EditorState.createWithContent(convertFromRaw(JSON.parse(content)));

const StoryContentQuery = gql`
  query StoryContent($uniqueHash: String!) {
    story(uniqueHash: $uniqueHash) {
      id
      content
    }
  }
`;

const withStoryContent = graphql(StoryContentQuery);

const UpdateStoryMutation = gql`
  mutation UpdateStory($storyId: ID!, $content: JSON!) {
    updateStory(input: { storyId: $storyId, content: $content }) {
      story {
        id
      }
    }
  }
`;

const withUpdateStoryMutation = graphql(UpdateStoryMutation, {
  props: ({ mutate, data: { story: { id: storyId } } }) => ({
    updateStoryContent: content => mutate({ variables: { content, storyId } }),
  }),
});

const withLoadingSpinner = branch(props => props.data.loading, renderComponent(() => 'loading'));

@withStoryContent
@withUpdateStoryMutation
@withLoadingSpinner
export default class StoryEditor extends Component {
  static propTypes = {
    data: PropTypes.object.isRequired,
    updateStoryContent: PropTypes.func.isRequired,
  };

  state = { editorState: getInitialEditorState(this.props.data.story.content) };

  handleChange = (editorState) => {
    this.setState({ editorState });

    // TODO: Debounce these calls.
    const content = convertToRaw(editorState.getCurrentContent());
    this.props.updateStoryContent(content);
  };

  render() {
    return <Editor editorState={this.state.editorState} onChange={this.handleChange} />;
  }
}
