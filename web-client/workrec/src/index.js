import React from 'react';
import ReactDOM from 'react-dom';
import API from './api';

class Workrec extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      worklist: null,
    };
  }
  componentDidMount() {
    API.getWorkList().then(res => this.setState({worklist: res}));
  }

  addWork(title) {
    API.addWork(title).then(() => {
      API.getWorkList().then(res => this.setState({worklist: res}));
    });
  }

  deleteWork(id) {
    API.deleteWork(id).then(() => {
      API.getWorkList().then(res => this.setState({worklist: res}));
    });
  }


  render() {
    return (
      <div>
        {(this.state.worklist || {worksList: []}).worksList.map(w => {
          return (<div>
            <div>{w.title}</div>
            <button onClick={() => this.deleteWork(w.id)}>DELETE</button>
          </div>)
        })}
        <button onClick={() => this.addWork('Sample Work')}>ADD</button>
      </div>
    );
  }
}

ReactDOM.render(<Workrec />, document.getElementById("root"));
